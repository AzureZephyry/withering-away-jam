extends CanvasLayer
## Scene 03 guidance uses the shared checklist and existing session flags.

const ObjectivePanel = preload("res://scripts/objective_panel.gd")
const InteractionController = preload("res://scripts/overworld_interaction.gd")
const Interactable = preload("res://scripts/overworld_interactable.gd")
const FLAGS: Array[String] = ["school_arnel_intro_completed", "school_notice_board_discovered"]
const ENTRIES: PackedStringArray = [
	"Ask the campus guard for directions (optional)",
	"Check the first-year class assignments (required)",
]

@export_range(64.0, 640.0, 16.0) var marker_range: float = 320.0
@export_range(4.0, 24.0, 1.0) var marker_clearance_pixels: float = 12.0

@onready var objective: ObjectivePanel = $Screen/Objective
@onready var interactions: InteractionController = get_node("../GuardInteraction")
@onready var player: CharacterBody2D = get_node("../Player")
@onready var targets: Array[Interactable] = [
	get_node("../MangArnel/Interaction"), get_node("../SchoolNoticeBoard/Interaction"),
]
@onready var markers: Array[Node2D] = [
	get_node("../GuardObjectiveMarker"), get_node("../BoardObjectiveMarker"),
]
@onready var clock_frame: Control = get_node("../TimeHUD/Screen/Frame")
@onready var sanity_frame: Control = get_node("../SanityHUD/Screen/Frame")

var _arrival_host: Node
var _busy: bool = false

func _ready() -> void:
	var wrapper := get_parent().get_parent()
	if wrapper.has_method("_finish_arrival"):
		_arrival_host = wrapper
	GameState.flag_changed.connect(_on_flag_changed)
	interactions.interaction_started.connect(_on_interaction_started)
	interactions.interaction_finished.connect(_on_interaction_finished)
	_refresh()
	_update_presentation()

func objective_complete() -> bool:
	return GameState.get_flag(FLAGS[1]) == true

func _refresh() -> void:
	var completed: Array[bool] = [GameState.get_flag(FLAGS[0]) == true, objective_complete()]
	if objective_complete():
		objective.present("Class assignments checked.", PackedStringArray(), [])
	else:
		objective.present("Find your classroom", ENTRIES, completed)

func _on_flag_changed(flag_name: String, _value: bool) -> void:
	if flag_name in FLAGS:
		_refresh()

func _on_interaction_started(_target: Interactable) -> void:
	_busy = true
	_update_presentation()

func _on_interaction_finished(_target: Interactable, _completed: bool) -> void:
	if not is_inside_tree():
		return
	_busy = false
	_refresh()
	_update_presentation()

func _exit_tree() -> void:
	if GameState.flag_changed.is_connected(_on_flag_changed):
		GameState.flag_changed.disconnect(_on_flag_changed)
	if is_instance_valid(interactions):
		if interactions.interaction_started.is_connected(_on_interaction_started):
			interactions.interaction_started.disconnect(_on_interaction_started)
		if interactions.interaction_finished.is_connected(_on_interaction_finished):
			interactions.interaction_finished.disconnect(_on_interaction_finished)

func _process(_delta: float) -> void:
	_update_presentation()

func _available() -> bool:
	return not _busy and not interactions.dialogue_open and not interactions._closing and not interactions.suspended and not (is_instance_valid(_arrival_host) and _arrival_host.arrival_active)

func _hud_rects() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for control: Control in [clock_frame, sanity_frame]:
		if control.is_visible_in_tree() and control.modulate.a > 0.01:
			result.append(control.get_global_rect().grow(8.0))
	return result

func _update_presentation() -> void:
	var view := get_viewport().get_visible_rect()
	var available := _available()
	objective.size.x = minf(480.0, view.size.x - 48.0)
	var clock_rect := clock_frame.get_global_rect()
	var beneath_clock := Rect2(Vector2(clock_rect.position.x, clock_rect.end.y + 16.0), objective.size)
	# Keep the fallback fixed when the adaptive clock leaves the top band.
	if clock_rect.position.y > 24.5 or not view.grow(-16.0).encloses(beneath_clock) or beneath_clock.intersects(sanity_frame.get_global_rect().grow(8.0)):
		var top: float = 24.0 + maxf(clock_frame.size.y, sanity_frame.size.y) + 16.0
		beneath_clock.position = Vector2(24, minf(top, view.size.y - 24.0 - objective.size.y))
	objective.position = beneath_clock.position.round()
	var hud_rects := _hud_rects()
	var clear := view.encloses(objective.get_global_rect())
	for rect in hud_rects:
		clear = clear and not rect.intersects(objective.get_global_rect())
	if interactions.prompt.is_visible_in_tree():
		clear = clear and not interactions.prompt.get_global_rect().grow(8.0).intersects(objective.get_global_rect())
	objective.visible = available and clear
	for index in targets.size():
		var target := targets[index]
		var marker := markers[index]
		marker.hide()
		if not available or GameState.get_flag(FLAGS[index]) == true:
			continue
		if player.global_position.distance_to(target.global_position) > marker_range:
			continue
		if target.in_range and not target.available():
			continue
		if interactions._selected == target and interactions.prompt.is_visible_in_tree():
			continue
		var bounds := target.screen_bounds()
		var screen_scale := marker.get_global_transform_with_canvas().get_scale().abs()
		var center := Vector2(bounds.get_center().x, bounds.position.y - marker_clearance_pixels - 3.0 * screen_scale.y).round()
		marker.position = marker.get_parent().get_global_transform_with_canvas().affine_inverse() * center
		var footprint: Rect2 = marker.get_global_transform_with_canvas() * Rect2(-4, -3, 8, 6)
		var marker_clear := view.encloses(footprint)
		for rect in hud_rects:
			marker_clear = marker_clear and not rect.intersects(footprint)
		if objective.visible:
			marker_clear = marker_clear and not objective.get_global_rect().grow(4.0).intersects(footprint)
		if interactions.prompt.is_visible_in_tree():
			marker_clear = marker_clear and not interactions.prompt.get_global_rect().grow(4.0).intersects(footprint)
		marker.visible = marker_clear
