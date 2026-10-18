extends Label
## Typewriter text for the opening and dialogue panels.

signal line_revealed
signal advance_requested
## Lawrence's typing sound hook. Revealing a whole line makes no typing sounds.
signal character_revealed(character: String)

@export_range(0.01, 0.3, 0.01) var seconds_per_character: float = 0.1

var is_typing: bool = false
var is_active: bool = false
var _elapsed: float = 0.0
var _shown: int = 0
var _revision: int = 0
var _held_keys: Dictionary = {}
var _last_accept_frame: int = -1

func _ready() -> void:
	get_window().focus_exited.connect(_clear_held_keys)

func present_line(draft_text: String) -> void:
	_revision += 1
	# The font has no ellipsis glyph. Keep the original dialogue in the sequence.
	text = draft_text.replace("…", "...")
	_shown = 0
	_elapsed = 0.0
	visible_characters = 0
	is_active = true
	is_typing = not text.is_empty()
	show()
	if not is_typing:
		line_revealed.emit()

func clear_line() -> void:
	_revision += 1
	is_active = false
	is_typing = false
	_elapsed = 0.0
	text = ""
	visible_characters = 0
	hide()

func reveal_line() -> void:
	if not is_active or not is_typing:
		return
	is_typing = false
	_elapsed = 0.0
	_shown = text.length()
	visible_characters = -1
	line_revealed.emit()

func _process(delta: float) -> void:
	if not is_active or not is_typing:
		return
	var revision: int = _revision
	_elapsed += delta
	while _elapsed >= seconds_per_character and _shown < text.length():
		_elapsed -= seconds_per_character
		var character: String = text.substr(_shown, 1)
		_shown += 1
		visible_characters = _shown
		character_revealed.emit(character)
		if revision != _revision:
			return
	if _shown == text.length():
		is_typing = false
		visible_characters = -1
		line_revealed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_action(&"dialogue_advance"):
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if not event.pressed:
		_held_keys.erase(key)
		return
	if event.echo or _held_keys.has(key):
		return
	_held_keys[key] = true
	if not is_active:
		return
	get_viewport().set_input_as_handled()
	var frame: int = Engine.get_process_frames()
	if _last_accept_frame == frame:
		return
	_last_accept_frame = frame
	if is_typing:
		reveal_line()
	else:
		advance_requested.emit()

func _clear_held_keys() -> void:
	_held_keys.clear()
