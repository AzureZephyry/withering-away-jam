extends CanvasLayer
## Bedroom objectives and departure stay separate from the introduction.

signal scene_completed

const Introduction = preload("res://scripts/bedroom_intro.gd")
const InteractionController = preload("res://scripts/overworld_interaction.gd")
const Interactable = preload("res://scripts/overworld_interactable.gd")
const DialoguePanel = preload("res://scripts/dialogue_panel.gd")
const Typewriter = preload("res://scripts/text_Type.gd")
const SCHEDULE_FLAG: String = "bedroom_schedule_checked"
const PREPARATION_FLAGS: Array[String] = [SCHEDULE_FLAG, "bedroom_id_checked", "bedroom_medal_checked"]
const PREPARATION_LABELS: Array[String] = [
	"Check your schedule.",
	"Check your student ID.",
	"Examine your graduation medal.",
]
const FIRST_NOTEBOOK_LINES: PackedStringArray = [
	"New semester. New schedule.",
	"Shouldn't be too different.",
]
const REPEAT_NOTEBOOK_LINES: PackedStringArray = ["I already checked it."]
const DOOR_RADIUS: float = 72.0
const FADE_SECONDS: float = 0.35

@onready var introduction: Introduction = get_parent()
@onready var interactions: InteractionController = get_node("../Laboratory/OverworldInteraction")
@onready var notebook: Interactable = get_node("../Laboratory/Bedroom/Decoration/Notebook/Interaction")
@onready var student_id: Interactable = get_node("../Laboratory/Bedroom/Props/Dresser/Card/Interaction")
@onready var medal: Interactable = get_node("../Laboratory/Bedroom/Decoration/GraduationMedal/Interaction")
@onready var preparation_targets: Array[Interactable] = [notebook, student_id, medal]
@onready var objective_markers: Array[Node2D] = [
	notebook.get_parent().get_node("ObjectiveMarker"),
	student_id.get_parent().get_node("ObjectiveMarker"),
	medal.get_parent().get_node("ObjectiveMarker"),
]
@onready var exit_objective_marker: Node2D = get_node("../Laboratory/Bedroom/Decoration/ClosedDoorPanel/ObjectiveMarker")
@onready var objective: Label = $Screen/Objective
@onready var checklist_boxes: Array[Panel] = [$Screen/Objective/ScheduleCheck, $Screen/Objective/IDCheck, $Screen/Objective/MedalCheck]
@onready var player: CharacterBody2D = get_node("../Laboratory/Player")
@onready var door_marker: Marker2D = get_node("../Laboratory/Bedroom/DoorRight")
@onready var door_prompt: Label = $Screen/DoorPrompt
@onready var door_panel: DialoguePanel = $Screen/DoorPanel
@onready var door_body: Typewriter = $Screen/DoorPanel/Margin/Content/Body
@onready var choices: HBoxContainer = $Screen/DoorPanel/Choices
@onready var yes_button: Button = $Screen/DoorPanel/Choices/Yes
@onready var not_yet_button: Button = $Screen/DoorPanel/Choices/NotYet
@onready var fade: ColorRect = $Screen/Fade
@onready var endpoint: Control = $Screen/Endpoint
@onready var _choice_normal_style: StyleBox = yes_button.get_theme_stylebox("normal")
@onready var _choice_selected_style: StyleBox = yes_button.get_theme_stylebox("focus")

var mode: StringName = &"exploration"
var selected_choice: int = 1
var endpoint_count: int = 0
var _exploration_ready: bool = false
var _environment_busy: bool = false
var _door_control_owned: bool = false
var _movement_was_processing: bool = true
var _interactions_were_suspended: bool = false
var _held_keys: Dictionary = {}
var _wait_for_release: bool = false
var _last_input_frame: int = -1
var _fade_tween: Tween
var _layout_queued: bool = false

func _ready() -> void:
	objective.hide()
	introduction.introduction_finished.connect(_on_introduction_finished)
	interactions.interaction_started.connect(_on_interaction_started)
	interactions.interaction_finished.connect(_on_interaction_finished)
	interactions.prompt.visibility_changed.connect(_update_objective_visibility)
	interactions.prompt.item_rect_changed.connect(_update_objective_visibility)
	GameState.flag_changed.connect(_on_flag_changed)
	door_body.set_process_unhandled_key_input(false)
	door_body.clear_line()
	door_panel.hide()
	door_prompt.hide()
	endpoint.hide()
	fade.hide()
	door_panel.resized.connect(_queue_door_layout)
	$Screen.resized.connect(_queue_door_layout)
	door_body.line_revealed.connect(_update_choices)
	yes_button.pressed.connect(_on_choice_pressed.bind(0))
	not_yet_button.pressed.connect(_on_choice_pressed.bind(1))
	yes_button.mouse_entered.connect(_set_choice.bind(0))
	not_yet_button.mouse_entered.connect(_set_choice.bind(1))
	$Screen/Endpoint/ReturnButton.pressed.connect(_return_to_bedroom)
	get_window().focus_exited.connect(_on_focus_exited)
	_update_notebook()
	# The parent decides whether to run or skip the introduction in its _ready().
	_initialize_exploration.call_deferred()
	_queue_door_layout()

func _physics_process(_delta: float) -> void:
	if _wait_for_release and not _confirmation_is_pressed():
		_wait_for_release = false
		_last_input_frame = Engine.get_process_frames() + 1
	door_prompt.visible = _can_open_door() and not _wait_for_release
	if door_prompt.visible:
		var point: Vector2 = door_marker.get_global_transform_with_canvas().origin
		door_prompt.size = door_prompt.get_combined_minimum_size().max(Vector2(120, 36))
		door_prompt.position = (point - Vector2(door_prompt.size.x + 8.0, 120.0 + door_prompt.size.y + 8.0)).clamp(
			Vector2(8, 8), get_viewport().get_visible_rect().size - door_prompt.size - Vector2(8, 8))

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if not event.pressed:
		_held_keys.erase(key)
		if _door_control_owned:
			get_viewport().set_input_as_handled()
		return
	if mode == &"exploration":
		if not event.is_action(&"dialogue_advance") or not _can_open_door():
			return
		get_viewport().set_input_as_handled()
		if not _accept_key(event, key):
			return
		_open_door()
		return
	if not _door_control_owned:
		return
	get_viewport().set_input_as_handled()
	if not _accept_key(event, key):
		return
	if mode == &"door" and event.is_action(&"ui_up"):
		_set_choice(0)
	elif mode == &"door" and event.is_action(&"ui_down"):
		_set_choice(1)
	elif event.is_action(&"dialogue_advance") or key in [KEY_ENTER, KEY_KP_ENTER]:
		_advance_door()

func _accept_key(event: InputEventKey, key: int) -> bool:
	if event.echo or _held_keys.has(key):
		return false
	_held_keys[key] = true
	return not _wait_for_release and _accept_press()

func _accept_press() -> bool:
	var frame: int = Engine.get_process_frames()
	if frame <= _last_input_frame:
		return false
	_last_input_frame = frame
	return true

func _confirmation_is_pressed() -> bool:
	return Input.is_action_pressed(&"dialogue_advance") or Input.is_physical_key_pressed(KEY_ENTER) or Input.is_physical_key_pressed(KEY_KP_ENTER)

func _begin_input_barrier() -> void:
	_held_keys.clear()
	for key in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_W, KEY_S, KEY_UP, KEY_DOWN]:
		if Input.is_physical_key_pressed(key):
			_held_keys[key] = true
	_wait_for_release = true
	_last_input_frame = Engine.get_process_frames() + 1

func _can_open_door() -> bool:
	if not _exploration_ready or mode != &"exploration" or introduction.introduction_active:
		return false
	if _environment_busy or interactions.dialogue_open or interactions.suspended:
		return false
	var door_center: Vector2 = door_marker.global_position - Vector2(8, 0)
	return player.global_position.distance_squared_to(door_center) <= DOOR_RADIUS * DOOR_RADIUS

func _open_door() -> void:
	if not _can_open_door():
		return
	_interactions_were_suspended = interactions.suspended
	if not interactions.set_suspended(true):
		return
	_door_control_owned = true
	_movement_was_processing = player.is_physics_processing()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.get_node("AnimatedSprite2D").show_idle()
	mode = &"door" if preparations_complete() else &"reminder"
	selected_choice = 1
	door_prompt.hide()
	door_panel.speaker_name = ""
	door_panel.hint.text = "W / S or arrows: choose    E / Space / Enter: confirm" if mode == &"door" else "E / Space / Enter"
	choices.visible = mode == &"door"
	door_body.present_line("Would you like to leave your dorm?" if mode == &"door" else "Finish getting ready before leaving.")
	_update_choices()
	_layout_door()
	door_panel.show()
	_begin_input_barrier()
	_update_objective_visibility()

func _advance_door() -> void:
	if mode in [&"door", &"reminder"]:
		if door_body.is_typing:
			door_body.reveal_line()
		elif mode == &"reminder" or selected_choice == 1:
			_close_door()
		else:
			_complete_scene()
	elif mode == &"endpoint":
		_return_to_bedroom()

func _set_choice(index: int) -> void:
	if mode != &"door":
		return
	selected_choice = clampi(index, 0, 1)
	_update_choices()

func _update_choices() -> void:
	for index in range(2):
		var button: Button = yes_button if index == 0 else not_yet_button
		button.disabled = door_body.is_typing
		var style: StyleBox = _choice_selected_style if index == selected_choice else _choice_normal_style
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)

func _on_choice_pressed(index: int) -> void:
	if mode != &"door" or door_body.is_typing or _wait_for_release or not _accept_press():
		return
	_set_choice(index)
	if selected_choice == 0:
		_complete_scene()
	else:
		_close_door()

func _close_door() -> void:
	door_body.clear_line()
	door_panel.hide()
	_release_door_control()
	mode = &"exploration"
	_begin_input_barrier()
	_update_objective()

func _release_door_control() -> void:
	if not _door_control_owned:
		return
	_door_control_owned = false
	if is_instance_valid(player):
		player.velocity = Vector2.ZERO
		player.set_physics_process(_movement_was_processing)
	if is_instance_valid(interactions):
		interactions.set_suspended(_interactions_were_suspended)

func _complete_scene() -> void:
	if mode != &"door":
		return
	mode = &"ending"
	endpoint_count += 1
	door_body.clear_line()
	door_panel.hide()
	_begin_input_barrier()
	fade.color.a = 0.0
	fade.show()
	_fade_tween = create_tween()
	_fade_tween.tween_property(fade, "color:a", 1.0, FADE_SECONDS)
	_fade_tween.tween_callback(_show_endpoint)
	# Scene 03 can replace the temporary endpoint behind this handoff later.
	scene_completed.emit()

func _show_endpoint() -> void:
	if mode != &"ending":
		return
	mode = &"endpoint"
	endpoint.show()
	_begin_input_barrier()

func _return_to_bedroom() -> void:
	if mode != &"endpoint" or _wait_for_release:
		return
	endpoint.hide()
	fade.hide()
	_release_door_control()
	mode = &"exploration"
	_begin_input_barrier()
	_update_objective()

func _queue_door_layout() -> void:
	if _layout_queued:
		return
	_layout_queued = true
	_layout_door.call_deferred()

func _layout_door() -> void:
	_layout_queued = false
	door_panel.position.y = 40.0
	var width: float = minf(480.0, maxf(80.0, door_panel.size.x - 48.0))
	choices.position = Vector2((door_panel.size.x - width) * 0.5, maxf(96.0, door_panel.size.y - 120.0))
	choices.size = Vector2(width, 48)

func _on_focus_exited() -> void:
	_begin_input_barrier()

func _exit_tree() -> void:
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
	_release_door_control()

func _initialize_exploration() -> void:
	_exploration_ready = not introduction.introduction_active and introduction.stage == &"exploration"
	_environment_busy = interactions.dialogue_open
	_update_objective()

func _on_introduction_finished(_branch: int) -> void:
	_exploration_ready = true
	_update_objective()

func _on_interaction_started(_target: Interactable) -> void:
	_environment_busy = true
	_update_objective_visibility()

func _on_interaction_finished(target: Interactable, completed: bool) -> void:
	if completed and is_instance_valid(target):
		for index in range(preparation_targets.size()):
			if is_instance_valid(preparation_targets[index]) and target == preparation_targets[index]:
				GameState.set_flag(PREPARATION_FLAGS[index], true)
				break
	_environment_busy = false
	_update_notebook()
	_update_objective()

func _on_flag_changed(flag_name: String, _value: bool) -> void:
	if flag_name in PREPARATION_FLAGS:
		_update_notebook()
		_update_objective()

func _update_notebook() -> void:
	if not is_instance_valid(notebook):
		return
	# Do not replace lines while their conversation is still using them.
	if interactions.active == notebook:
		return
	notebook.lines = REPEAT_NOTEBOOK_LINES if GameState.get_flag(SCHEDULE_FLAG) == true else FIRST_NOTEBOOK_LINES
	notebook.speakers = PackedStringArray(["Albert", "Albert"])

func _update_objective() -> void:
	if preparations_complete():
		objective.text = "Head out for school."
	else:
		var lines: PackedStringArray = ["Get ready for your first day."]
		for index in range(PREPARATION_FLAGS.size()):
			lines.append("   " + PREPARATION_LABELS[index])
		objective.text = "\n".join(lines)
	objective.size.y = maxf(66.0, objective.get_combined_minimum_size().y)
	var line_height: float = objective.get_line_height()
	var line_step: float = line_height + objective.get_theme_constant("line_spacing")
	for index in range(checklist_boxes.size()):
		var checkbox: Panel = checklist_boxes[index]
		checkbox.visible = not preparations_complete()
		checkbox.position = Vector2(14, 8 + (index + 1) * line_step + (line_height - 12) * 0.5)
		checkbox.get_node("Fill").visible = GameState.get_flag(PREPARATION_FLAGS[index]) == true
	_update_objective_visibility()

func preparations_complete() -> bool:
	for flag_name in PREPARATION_FLAGS:
		if GameState.get_flag(flag_name) != true:
			return false
	return true

func _update_objective_visibility() -> void:
	var available: bool = _exploration_ready and mode == &"exploration" and not _environment_busy
	available = available and not introduction.introduction_active and not interactions.suspended
	for index in range(objective_markers.size()):
		if is_instance_valid(objective_markers[index]):
			objective_markers[index].visible = available and GameState.get_flag(PREPARATION_FLAGS[index]) != true
	if is_instance_valid(exit_objective_marker):
		exit_objective_marker.visible = available and preparations_complete()
	if available and interactions.prompt.is_visible_in_tree():
		available = not objective.get_global_rect().intersects(interactions.prompt.get_global_rect().grow(8.0))
	objective.visible = available
