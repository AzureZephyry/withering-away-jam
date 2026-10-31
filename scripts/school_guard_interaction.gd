extends "res://scripts/overworld_interaction.gd"
## Scene 03's first guard encounter uses the ordinary overworld lifecycle.

const COMPLETION_FLAG := "school_arnel_intro_completed"
const PRIMARY_CHOICES: Array[String] = ["Opo.", "Yes, po. BSCS", "...Is this the right line?"]
const FOLLOWUP_CHOICES: Array[String] = ["Thank you, po.", "Can you tell me where the rooms are for CS?"]

var choosing: bool = false
var selected_choice: int = 0
var _stage: StringName = &"opening"
var _choice_count: int = 0
var _arrival_host: Node
@onready var _guard: Interactable = get_node("../MangArnel/Interaction")
@onready var _choices: VBoxContainer = $DialogueLayer/DialoguePanel/Margin/Choices
@onready var _choice_rows: VBoxContainer = $DialogueLayer/DialoguePanel/Margin/Choices/OptionsFrame/Rows
@onready var _hint: Label = $DialogueLayer/DialoguePanel/Margin/Content/Hint

func _ready() -> void:
	super._ready()
	for i in _choice_rows.get_child_count():
		var button: Button = _choice_rows.get_child(i)
		button.gui_input.connect(_on_choice_key_input)
		button.mouse_entered.connect(_on_choice_hovered.bind(i))
		button.focus_entered.connect(_on_choice_focused.bind(i))
	_reset_opening()
	_guard.repeat_mode = Interactable.Repeat.ONE_TIME
	_guard.completed_once = GameState.get_flag(COMPLETION_FLAG)
	interaction_finished.connect(_on_encounter_finished)
	GameState.flag_changed.connect(_on_flag_changed)
	var wrapper := get_parent().get_parent()
	if wrapper.has_method("_finish_arrival"):
		_arrival_host = wrapper

func _arrival_active() -> bool:
	return is_instance_valid(_arrival_host) and _arrival_host.arrival_active

func _physics_process(delta: float) -> void:
	if _arrival_active():
		prompt.hide()
		return
	super._physics_process(delta)

func _unhandled_key_input(event: InputEvent) -> void:
	if _arrival_active():
		return
	if not choosing:
		super._unhandled_key_input(event)
		return
	if not event is InputEventKey:
		return
	if event.is_action(&"dialogue_advance"):
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if not event.pressed:
			_held_keys.erase(key)
			return
		get_viewport().set_input_as_handled()
		if event.echo or _held_keys.has(key):
			return
		_held_keys[key] = true
		_commit_choice(selected_choice)
	elif event.pressed and (event.is_action(&"ui_up") or event.is_action(&"ui_down")):
		get_viewport().set_input_as_handled()
		selected_choice = wrapi(selected_choice + (1 if event.is_action(&"ui_down") else -1), 0, _choice_count)
		_update_selection()

func _advance_dialogue() -> void:
	if active != _guard or line_index < active.lines.size() - 1:
		super._advance_dialogue()
	elif _stage == &"opening":
		_show_choices(PRIMARY_CHOICES)
	elif _stage == &"option_three":
		_show_choices(FOLLOWUP_CHOICES)
	else:
		super._advance_dialogue()

func _show_choices(options: Array[String]) -> void:
	choosing = true
	selected_choice = 0
	_choice_count = options.size()
	_choices.get_node("Context/SpokenLine").text = _guard.lines[line_index]
	body.hide()
	_hint.hide()
	panel.speaker_name = _guard.speaker(line_index)
	for i in _choice_rows.get_child_count():
		var button: Button = _choice_rows.get_child(i)
		button.visible = i < options.size()
		button.disabled = i >= options.size()
		if i < options.size():
			button.text = options[i]
	_choices.show()
	_update_selection()
	_last_press_frame = Engine.get_process_frames() + 1

func _update_selection() -> void:
	for i in _choice_rows.get_child_count():
		_choice_rows.get_child(i).set_pressed_no_signal(i == selected_choice)
	if choosing and _choices.is_visible_in_tree():
		var selected: Button = _choice_rows.get_child(selected_choice)
		if not selected.has_focus():
			selected.grab_focus()

func _on_choice_key_input(event: InputEvent) -> void:
	if choosing and event is InputEventKey and (event.is_action(&"dialogue_advance") or event.is_action(&"ui_up") or event.is_action(&"ui_down")):
		_unhandled_key_input(event)
		_choices.accept_event()

func _on_choice_hovered(index: int) -> void:
	if choosing and index < _choice_count:
		selected_choice = index
		_update_selection()

func _on_choice_focused(index: int) -> void:
	if choosing and selected_choice != index:
		selected_choice = index
		_update_selection()

func _hide_choices() -> void:
	choosing = false
	_choices.hide()
	_hint.show()
	for button in _choice_rows.get_children():
		button.disabled = true

func _commit_choice(index: int) -> void:
	if not choosing or index < 0 or index >= _choice_count or Engine.get_process_frames() <= _last_press_frame:
		return
	_hide_choices()
	_last_press_frame = Engine.get_process_frames() + 1
	if _stage == &"opening":
		if index == 2:
			_set_branch(PackedStringArray(["Same line for everyone, dong. Don’t worry."]), PackedStringArray(["Mang Arnel"]), &"option_three")
		else:
			var third: String = "BSCS?" if index == 0 else "I didn’t ask for your course yet. Eager huh?"
			var reply: String = "Yes, po." if index == 0 else "Ah…sorry, po."
			_set_branch(PackedStringArray([
				"ID?", "Albert James Dimapilis...", third, reply,
				"Check the board around the hallway. You’ll see the rooms you need to go to.",
				"Thank you, po.", "Sige. Next!"
			]), PackedStringArray(["Mang Arnel", "Mang Arnel", "Mang Arnel", "Albert", "Mang Arnel", "Albert", "Mang Arnel"]), &"ending")
	else:
		var answer: String = "Sige, Check the board around the hallway. You’ll see the rooms you need to go to, Next!" if index == 0 else "Rooms change, The board updated. Go on."
		_set_branch(PackedStringArray([answer, "Thank you, po."]), PackedStringArray(["Mang Arnel", "Albert"]), &"ending")

func _set_branch(lines: PackedStringArray, speakers: PackedStringArray, stage: StringName) -> void:
	_stage = stage
	_guard.lines = lines
	_guard.speakers = speakers
	line_index = 0
	_present_line()

func _reset_opening() -> void:
	_stage = &"opening"
	_guard.lines = PackedStringArray(["First year?"])
	_guard.speakers = PackedStringArray(["Mang Arnel"])

func _close_dialogue(success: bool = true) -> void:
	_hide_choices()
	super._close_dialogue(success)

func _on_encounter_finished(target: Interactable, completed: bool) -> void:
	if target != _guard:
		return
	if completed and _stage == &"ending":
		GameState.set_flag(COMPLETION_FLAG, true)
	_reset_opening()

func _on_flag_changed(flag_name: String, value: bool) -> void:
	if flag_name == COMPLETION_FLAG:
		_guard.completed_once = value

func _on_first_choice_pressed() -> void:
	_commit_choice(0)

func _on_second_choice_pressed() -> void:
	_commit_choice(1)

func _on_third_choice_pressed() -> void:
	_commit_choice(2)
