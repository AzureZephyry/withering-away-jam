extends Node2D
## School atmosphere reads the shared clock without changing story state.

const PHASE_NAMES: PackedStringArray = ["Morning", "Noon", "Afternoon", "Sunset", "Evening", "Night", "Dawn"]

@export_group("Seven-phase timeline")
@export var phase_start_minutes: PackedFloat32Array = [390, 720, 900, 1080, 1170, 1260, 300]
@export var phase_colors: PackedColorArray = [
	Color("c7d2db"), Color("fff2de"), Color("e5c69e"), Color("cd9296"),
	Color("8585af"), Color("566784"), Color("a5a0bf"),
]
## Saturation, contrast and authored-shadow strength for the same seven phases.
@export var phase_grading: PackedVector3Array = [
	Vector3(0.97, 1.02, 0.95), Vector3(1.04, 1.03, 1.10),
	Vector3(1.07, 1.035, 1.00), Vector3(1.02, 1.045, 0.86),
	Vector3(0.90, 1.055, 0.70), Vector3(0.82, 1.065, 0.58),
	Vector3(0.92, 1.025, 0.74),
]
@export var phase_light_strengths: PackedFloat32Array = [0, 0, 0, 0.25, 0.85, 1, 0.45]
@export_range(1.0, 120.0, 1.0) var transition_minutes: float = 60.0
@export_range(0.0, 2.0, 0.05) var maximum_lamp_energy: float = 1.5
@export_range(0.0, 2.0, 0.05) var maximum_headlight_energy: float = 0.9
@export_range(0.0, 1.0, 0.01) var maximum_window_alpha: float = 0.78
@export var interior_light_material: ShaderMaterial
@export_range(0.0, 1.0, 0.01) var maximum_interior_alpha: float = 0.42
@export_range(0.0, 1.0, 0.01) var maximum_guard_spill_energy: float = 0.28
@export_range(0.4, 0.8, 0.05) var override_blend_seconds: float = 0.6

@export_group("Development preview")
@export_enum("Morning", "Noon", "Afternoon", "Sunset", "Evening", "Night", "Dawn") var preview_phase_index: int = 0
@export var preview_now: bool = false:
	set(value):
		preview_now = false
		if value and is_node_ready():
			preview_phase(preview_phase_index)

@onready var clock: Node = get_node("/root/GameClock")
@onready var ambient: CanvasModulate = $Lighting/Ambient
@onready var streetlights: Node2D = $Lighting/Streetlights
@onready var windows: Node2D = $Lighting/Windows
@onready var headlights: Node2D = $Lighting/Headlights
@onready var guard_spills: Node2D = $Lighting/GuardSpills

var current_phase_index: int = 0
var current_light_strength: float = 0.0
var _override_started_msec: int = -1
var _override_color: Color
var _override_strength: float = 0.0
var _current_grading := Vector3.ONE
var _override_grading := Vector3.ONE
var _applied_grading := Vector3(-1, -1, -1)
var _grading_materials: Array[ShaderMaterial] = []

func _ready() -> void:
	if not timeline_is_valid():
		push_error("School lighting needs seven phase times in cyclic order, with matching colors, strengths and grading profiles.")
		set_process(false)
		return
	clock.time_overridden.connect(_on_time_overridden)
	_collect_grading_materials()
	_update_lighting()

func timeline_is_valid() -> bool:
	if phase_start_minutes.size() != 7 or phase_colors.size() != 7 or phase_light_strengths.size() != 7 or phase_grading.size() != 7:
		return false
	var span: float = 0.0
	for index in range(7):
		var start: float = phase_start_minutes[index]
		if start < 0.0 or start >= 1440.0:
			return false
		var duration: float = fposmod(phase_start_minutes[(index + 1) % 7] - start, 1440.0)
		if duration <= 0.0 or phase_light_strengths[index] < 0.0 or phase_light_strengths[index] > 1.0:
			return false
		span += duration
	return is_equal_approx(span, 1440.0)

func sample_at(minutes: float) -> Dictionary:
	if not timeline_is_valid():
		return {}
	var time: float = fposmod(minutes, 1440.0)
	for index in range(7):
		var next: int = (index + 1) % 7
		var duration: float = fposmod(phase_start_minutes[next] - phase_start_minutes[index], 1440.0)
		var elapsed: float = fposmod(time - phase_start_minutes[index], 1440.0)
		if elapsed >= duration:
			continue
		# Hold the phase, then blend through the final hour into the next one.
		var blend_length: float = minf(transition_minutes, duration)
		var t: float = clampf((elapsed - duration + blend_length) / blend_length, 0.0, 1.0)
		# Match both the slope and curvature where phases meet.
		var weight: float = t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
		return {"index": index, "name": PHASE_NAMES[index],
			"ambient": phase_colors[index].lerp(phase_colors[next], weight),
			"grading": phase_grading[index].lerp(phase_grading[next], weight),
			"light_strength": lerpf(phase_light_strengths[index], phase_light_strengths[next], weight)}
	return {}

func _process(_delta: float) -> void:
	_update_lighting()

func _on_time_overridden(previous: float, current: float) -> void:
	var distance: float = minf(fposmod(current - previous, 1440.0), fposmod(previous - current, 1440.0))
	_override_started_msec = Time.get_ticks_msec() if distance >= 2.0 else -1
	_override_color = ambient.color
	_override_strength = current_light_strength
	_override_grading = _current_grading

func _update_lighting() -> void:
	var state: Dictionary = sample_at(clock.get_minutes())
	if state.is_empty():
		return
	current_phase_index = state.index
	current_light_strength = state.light_strength
	ambient.color = state.ambient
	_current_grading = state.grading
	if _override_started_msec >= 0:
		var elapsed: float = float(Time.get_ticks_msec() - _override_started_msec) / 1000.0
		var weight: float = smoothstep(0.0, 1.0, minf(1.0, elapsed / override_blend_seconds))
		ambient.color = _override_color.lerp(state.ambient, weight)
		current_light_strength = lerpf(_override_strength, state.light_strength, weight)
		_current_grading = _override_grading.lerp(state.grading, weight)
		if elapsed >= override_blend_seconds:
			_override_started_msec = -1
	_apply_grading()
	for light: PointLight2D in streetlights.get_children():
		light.energy = maximum_lamp_energy * current_light_strength
		light.enabled = light.energy > 0.001
	windows.modulate.a = maximum_window_alpha * current_light_strength
	windows.visible = current_light_strength > 0.001
	if interior_light_material != null:
		interior_light_material.set_shader_parameter("interior_strength", maximum_interior_alpha * current_light_strength)
	for light: PointLight2D in guard_spills.get_children():
		light.energy = maximum_guard_spill_energy * current_light_strength
		light.enabled = light.energy > 0.001
	var headlight_strength: float = smoothstep(0.25, 1.0, current_light_strength)
	for light: PointLight2D in headlights.get_children():
		light.energy = maximum_headlight_energy * headlight_strength
		light.enabled = light.energy > 0.001

func _collect_grading_materials() -> void:
	_grading_materials.assign([$Map.material, $OcclusionUnderlay.material])
	for object in $Occluders.get_children():
		_grading_materials.append(object.get_node("Artwork").material)

func _apply_grading() -> void:
	if _current_grading.distance_to(_applied_grading) < 0.0005:
		return
	for grade_material in _grading_materials:
		grade_material.set_shader_parameter("grade_saturation", _current_grading.x)
		grade_material.set_shader_parameter("grade_contrast", _current_grading.y)
		grade_material.set_shader_parameter("shadow_strength", _current_grading.z)
	_applied_grading = _current_grading

func get_phase_name() -> String:
	return PHASE_NAMES[current_phase_index]

func preview_phase(index: int) -> bool:
	if not OS.is_debug_build() or index < 0 or index >= 7 or not timeline_is_valid():
		return false
	var minutes: int = roundi(phase_start_minutes[index])
	if not clock.set_time(floori(minutes / 60.0), minutes % 60):
		return false
	_update_lighting()
	return true
