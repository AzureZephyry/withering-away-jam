extends Node2D
## Ground mist reads the shared clock and an existing ground-receiver mask.

@export_node_path("Sprite2D") var map_path: NodePath = ^"../Map"
@export_node_path("Node2D") var lighting_path: NodePath = ^".."
@export_node_path("SubViewport") var ground_mask_path: NodePath = ^"../SunShadowPrototype/Mask"
@export var mask_origin := Vector2i.ZERO
## Source-map centers/radii and strengths shape one continuous ground field.
@export var density_pockets: PackedVector4Array = []
@export var pocket_strengths: PackedFloat32Array = []
## Optical depth before regional shape weighting, rather than final overlay alpha.
@export var phase_densities: PackedFloat32Array = [0.24, 0.002, 0.004, 0.08, 0.22, 0.44, 0.72]
@export var phase_colors: PackedColorArray = [
	Color("b9c5ce"), Color("abb7bf"), Color("a8b3bc"), Color("a9b5c0"),
	Color("a1b0c2"), Color("a3b4c5"), Color("c3cbd2"),
]
@export var phase_velocities: PackedVector2Array = [
	Vector2(0.80, -0.16), Vector2(0.50, -0.10), Vector2(0.55, -0.12),
	Vector2(0.75, -0.15), Vector2(1.00, -0.20), Vector2(1.20, -0.24), Vector2(1.35, -0.22),
]
@export var warm_lamp_paths: Array[NodePath] = []

@export_group("Development preview")
@export var preview_fog_enabled: bool = true:
	set(value):
		if not OS.is_debug_build() and is_node_ready():
			return
		preview_fog_enabled = value
		if is_node_ready():
			_update_fog()

@onready var clock: Node = get_node("/root/GameClock")
@onready var lighting: Node = get_node(lighting_path)
@onready var _map: Sprite2D = get_node(map_path)
@onready var _ground_mask: SubViewport = get_node(ground_mask_path)

var current_density: float = 0.0
var current_color := Color.WHITE
var current_velocity := Vector2.ZERO
var drift_offset := Vector2.ZERO
var _material: ShaderMaterial
var _override_started_msec: int = -1
var _from_density: float = 0.0
var _from_color: Color
var _from_velocity: Vector2
var _last_motion_msec: int = 0

func _ready() -> void:
	if phase_densities.size() != 7 or phase_colors.size() != 7 or phase_velocities.size() != 7 or not lighting.timeline_is_valid():
		push_error("Ground fog needs seven profiles matching the lighting timeline.")
		hide()
		set_process(false)
		return
	if density_pockets.is_empty() or density_pockets.size() > 8 or density_pockets.size() != pocket_strengths.size():
		push_error("Ground fog needs one to eight matching density pockets and strengths.")
		hide()
		set_process(false)
		return
	_material = material as ShaderMaterial
	global_transform = _map.global_transform
	var inverse: Transform2D = _map.global_transform.affine_inverse()
	_material.set_shader_parameter("map_inverse_x", Vector3(inverse.x.x, inverse.y.x, inverse.origin.x))
	_material.set_shader_parameter("map_inverse_y", Vector3(inverse.x.y, inverse.y.y, inverse.origin.y))
	_material.set_shader_parameter("ground_mask", _ground_mask.get_texture())
	_material.set_shader_parameter("mask_origin", mask_origin)
	var pockets: PackedVector4Array = density_pockets.duplicate()
	var strengths: PackedFloat32Array = pocket_strengths.duplicate()
	_material.set_shader_parameter("density_pocket_count", pockets.size())
	pockets.resize(8)
	strengths.resize(8)
	_material.set_shader_parameter("density_pockets", pockets)
	_material.set_shader_parameter("pocket_strengths", strengths)
	var lamp_positions := PackedVector2Array()
	for path: NodePath in warm_lamp_paths:
		if lamp_positions.size() >= 5:
			break
		var lamp: PointLight2D = get_node(path) as PointLight2D
		lamp_positions.append(inverse * (lamp.global_transform * lamp.offset))
	_material.set_shader_parameter("lamp_count", lamp_positions.size())
	lamp_positions.resize(5)
	_material.set_shader_parameter("lamp_positions", lamp_positions)
	clock.time_overridden.connect(_on_time_overridden)
	_last_motion_msec = Time.get_ticks_msec()
	_update_fog()

func sample_at(minutes: float) -> Dictionary:
	var starts: PackedFloat32Array = lighting.phase_start_minutes
	var time: float = fposmod(minutes, 1440.0)
	for index in range(7):
		var next: int = (index + 1) % 7
		var duration: float = fposmod(starts[next] - starts[index], 1440.0)
		var elapsed: float = fposmod(time - starts[index], 1440.0)
		if elapsed >= duration:
			continue
		# Mist accumulates and dissipates across the whole phase, without hard edges.
		var t: float = elapsed / duration
		var weight: float = t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
		return {"density": lerpf(phase_densities[index], phase_densities[next], weight),
			"color": phase_colors[index].lerp(phase_colors[next], weight),
			"velocity": phase_velocities[index].lerp(phase_velocities[next], weight)}
	return {}

func _on_time_overridden(_previous: float, _current: float) -> void:
	_override_started_msec = Time.get_ticks_msec()
	_from_density = current_density
	_from_color = current_color
	_from_velocity = current_velocity

func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_msec()
	var elapsed: float = maxf(0.0, float(now - _last_motion_msec) / 1000.0)
	_last_motion_msec = now
	_update_fog()
	drift_offset += current_velocity * elapsed
	_material.set_shader_parameter("drift_offset", drift_offset)

func _update_fog() -> void:
	var state: Dictionary = sample_at(clock.get_minutes())
	current_density = state.density
	current_color = state.color
	current_velocity = state.velocity
	if _override_started_msec >= 0:
		var duration: float = lighting.override_blend_seconds
		var elapsed: float = float(Time.get_ticks_msec() - _override_started_msec) / 1000.0
		var weight: float = smoothstep(0.0, 1.0, minf(1.0, elapsed / duration))
		current_density = lerpf(_from_density, current_density, weight)
		current_color = _from_color.lerp(current_color, weight)
		current_velocity = _from_velocity.lerp(current_velocity, weight)
		if elapsed >= duration:
			_override_started_msec = -1
	visible = current_density >= 0.003 and (preview_fog_enabled or not OS.is_debug_build())
	_material.set_shader_parameter("fog_density", current_density)
	_material.set_shader_parameter("fog_color", current_color)
	_material.set_shader_parameter("lamp_strength", lighting.current_light_strength)
