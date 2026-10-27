extends Node2D
## The Bedroom story owns input until the final reflection is dismissed.

signal introduction_finished(branch: int)
signal audio_cued(cue_id: StringName)

enum EntryContext { STORY, REENTRY, DEVELOPER_TEST }

const DialoguePanel = preload("res://scripts/dialogue_panel.gd")
const Typewriter = preload("res://scripts/text_type.gd")
const PhoneConversation = preload("res://scripts/phone_conversation.gd")
const OverworldInteraction = preload("res://scripts/overworld_interaction.gd")
const COMPLETION_FLAG: String = "bedroom_intro_completed"
const WAKEUP_LINES: PackedStringArray = [
	"What…the….",
	"*sigh* what was that weird dream...",
	"It felt… more vivid than usual..?",
]
const REFLECTIONS: Array[Array] = [
	["Okay, big day."],
	["I got this.", "..."],
	["...It's fine, it's just the first day."],
]

@export var entry_context: EntryContext = EntryContext.STORY
@export var bedside_position: Vector2 = Vector2(144, 176)
@export var entrance_position: Vector2 = Vector2(464, 304)
@export_range(0.0, 1.0, 0.05) var arrival_fade_seconds: float = 0.35
@export_range(0.1, 0.6, 0.01) var buzz_seconds: float = 0.32
@export_range(0.0, 4.0, 0.1) var shake_strength: float = 1.5

@onready var player: CharacterBody2D = $Laboratory/Player
@onready var camera: Camera2D = $Laboratory/Camera2D
@onready var interactions: OverworldInteraction = $Laboratory/OverworldInteraction
@onready var panel: DialoguePanel = $StoryLayer/DialoguePanel
@onready var body: Typewriter = $StoryLayer/DialoguePanel/Margin/Content/Body
@onready var phone: PhoneConversation = $StoryLayer/PhoneConversation
@onready var clock: Label = $StoryLayer/Clock
@onready var arrival_fade: ColorRect = $StoryLayer/ArrivalFade

var stage: StringName = &"arrival"
var introduction_active: bool = false
var line_index: int = 0
var selected_branch: int = 0
var _movement_was_processing: bool = true
var _interactions_were_suspended: bool = false
var _camera_offset: Vector2
var _buzz_elapsed: float = 0.0
var _held_keys: Dictionary = {}
var _mouse_held: bool = false
var _last_input_frame: int = -1
var _arrival_tween: Tween
var _phone_decision_applied: bool = false

func configure_entry(context: EntryContext, entry_position: Vector2) -> void:
	# Future room transitions configure the instance before adding it to the tree.
	if is_node_ready():
		push_warning("Configure Bedroom entry before adding the scene to the tree.")
		return
	entry_context = context
	entrance_position = entry_position

func _ready() -> void:
	body.set_process_unhandled_key_input(false)
	body.clear_line()
	panel.hide()
	phone.hide()
	get_window().focus_exited.connect(_clear_held_inputs)
	var run_intro: bool = entry_context == EntryContext.DEVELOPER_TEST
	if not run_intro:
		run_intro = GameState.get_flag(COMPLETION_FLAG) == false
	$Laboratory/TimeHUD.set_gameplay_active(not run_intro)
	if not run_intro:
		player.position = entrance_position
		clock.hide()
		arrival_fade.hide()
		stage = &"exploration"
		set_process_input(false)
		return
	_interactions_were_suspended = interactions.suspended
	if not interactions.set_suspended(true):
		push_error("Bedroom introduction could not acquire environmental input.")
		arrival_fade.hide()
		clock.hide()
		set_process_input(false)
		return
	_movement_was_processing = player.is_physics_processing()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.position = bedside_position
	player.get_node("AnimatedSprite2D").show_idle()
	_camera_offset = camera.offset
	introduction_active = true
	_seed_held_inputs()
	if entry_context == EntryContext.DEVELOPER_TEST:
		audio_cued.emit(&"alarm_0630")
	clock.show()
	arrival_fade.show()
	_arrival_tween = create_tween()
	_arrival_tween.tween_property(arrival_fade, "color:a", 0.0, arrival_fade_seconds)
	_arrival_tween.tween_callback(_begin_wakeup)

func _begin_wakeup() -> void:
	arrival_fade.hide()
	stage = &"wakeup"
	line_index = 0
	_present_line(WAKEUP_LINES[0])

func _present_line(text: String) -> void:
	panel.speaker_name = "Albert"
	panel.show()
	body.present_line(text)

func _process(delta: float) -> void:
	if stage != &"buzz":
		return
	_buzz_elapsed += delta
	var progress: float = minf(_buzz_elapsed / buzz_seconds, 1.0)
	var wave := Vector2(sin(progress * TAU * 4.0), sin(progress * TAU * 5.0))
	camera.offset = _camera_offset + wave * shake_strength * (1.0 - progress)
	camera.force_update_scroll()
	if progress >= 1.0:
		camera.offset = _camera_offset
		camera.force_update_scroll()
		stage = &"reaction"
		_present_line("!!!")

func _input(event: InputEvent) -> void:
	if not introduction_active:
		return
	if event is InputEventMouseMotion:
		if stage == &"phone" and phone.is_choosing():
			phone.hover_choice(event.position)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if not event.pressed:
			_held_keys.erase(key)
			return
		if event.echo or _held_keys.has(key):
			return
		_held_keys[key] = true
		if stage == &"phone" and phone.is_choosing():
			if event.is_action(&"ui_up") and _accept_press():
				phone.move_selection(-1)
			elif event.is_action(&"ui_down") and _accept_press():
				phone.move_selection(1)
			elif key in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE] and _accept_press():
				phone.confirm_selection()
		elif event.is_action(&"dialogue_advance") and _accept_press():
			_advance_story()
		return
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not event.pressed:
			_mouse_held = false
			return
		if _mouse_held:
			return
		_mouse_held = true
		if not get_viewport_rect().has_point(event.position) or not _accept_press():
			return
		if stage == &"phone" and phone.is_choosing():
			phone.click_choice(event.position)
		else:
			_advance_story()

func _accept_press() -> bool:
	var frame: int = Engine.get_process_frames()
	if frame <= _last_input_frame:
		return false
	_last_input_frame = frame
	return true

func _advance_story() -> void:
	# Each event visits one stage only, even when a callback changes the stage.
	match stage:
		&"wakeup", &"reaction", &"reflection":
			if body.is_typing:
				body.reveal_line()
				return
			if stage == &"reaction":
				body.clear_line()
				panel.hide()
				stage = &"phone"
				phone.open_conversation()
				return
			line_index += 1
			var lines: PackedStringArray = WAKEUP_LINES if stage == &"wakeup" else PackedStringArray(REFLECTIONS[selected_branch - 1])
			if line_index < lines.size():
				_present_line(lines[line_index])
			elif stage == &"wakeup":
				_begin_buzz()
			else:
				_finish_introduction()
		&"phone":
			phone.advance()

func _begin_buzz() -> void:
	stage = &"buzz"
	clock.hide()
	body.clear_line()
	_buzz_elapsed = 0.0
	# Final buzz audio can connect here; no substitute audio is generated.
	audio_cued.emit(&"phone_buzz")

func _on_phone_choice_committed(branch: int) -> void:
	if stage != &"phone" or _phone_decision_applied or branch < 1 or branch > REFLECTIONS.size():
		return
	_phone_decision_applied = true
	SanityState.apply_effect(1 if branch == 3 else 0)

func _on_phone_finished(branch: int) -> void:
	if stage != &"phone":
		return
	selected_branch = branch
	stage = &"reflection"
	line_index = 0
	_present_line(REFLECTIONS[branch - 1][0])

func _finish_introduction() -> void:
	if entry_context != EntryContext.DEVELOPER_TEST:
		if not GameState.set_flag(COMPLETION_FLAG, true):
			push_error("Bedroom completion flag was not registered.")
			return
	body.clear_line()
	panel.hide()
	clock.hide()
	stage = &"exploration"
	introduction_active = false
	$Laboratory/TimeHUD.set_gameplay_active(true)
	camera.offset = _camera_offset
	player.velocity = Vector2.ZERO
	interactions.set_suspended(_interactions_were_suspended)
	player.set_physics_process(_movement_was_processing)
	set_process_input(false)
	introduction_finished.emit(selected_branch)

func _seed_held_inputs() -> void:
	for key in [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_W, KEY_S, KEY_UP, KEY_DOWN]:
		if Input.is_physical_key_pressed(key):
			_held_keys[key] = true
	_mouse_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_last_input_frame = Engine.get_process_frames()

func _clear_held_inputs() -> void:
	_held_keys.clear()
	_mouse_held = false
	_last_input_frame = Engine.get_process_frames()

func _exit_tree() -> void:
	if is_instance_valid(_arrival_tween):
		_arrival_tween.kill()
	if introduction_active and is_instance_valid(camera):
		camera.offset = _camera_offset
