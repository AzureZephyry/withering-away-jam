extends CanvasLayer
## Keep the exact artwork above an inspection-only Reality dialogue panel.

signal dismissed

@onready var screen: Control = $Screen
@onready var artwork: TextureRect = $Screen/Artwork
@onready var dismissal_panel: Control = $Screen/Dismissal
@onready var dismiss_button: Button = $Screen/Dismissal/Dismiss

const OUTER_MARGIN: float = 20.0
const PANEL_GAP: float = 16.0
const PANEL_WIDTH: float = 540.0

var _dismissed: bool = false
var _armed: bool = false
var _opened_frame: int
var _held_keys: Dictionary = {}
var _previous_focus: WeakRef

func _ready() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus != null:
		_previous_focus = weakref(focus)
	_opened_frame = Engine.get_process_frames()
	# The action is immediate UI text, not a new spoken/typewritten line.
	dismissal_panel.body.clear_line()
	dismissal_panel.body.set_process_unhandled_key_input(false)
	dismissal_panel.body.set_process(false)
	dismissal_panel.body.text = "Close notice board"
	dismissal_panel.body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dismissal_panel.body.visible_characters = -1
	dismissal_panel.body.show()
	dismissal_panel.hint.text = "E / Space / Click"
	get_viewport().size_changed.connect(_layout)
	_layout()
	dismiss_button.grab_focus()

func _process(_delta: float) -> void:
	# Require release of the opening key or click before accepting dismissal.
	if Engine.get_process_frames() > _opened_frame + 1 and not Input.is_action_pressed(&"dialogue_advance") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_armed = true
		set_process(false)

func _layout() -> void:
	_layout_for_size(get_viewport().get_visible_rect().size)

func _layout_for_size(view: Vector2) -> void:
	var native := artwork.texture.get_size()
	var skin: Rect2i = dismissal_panel.artwork.texture.get_image().get_used_rect()
	var panel_width := minf(PANEL_WIDTH, view.x - OUTER_MARGIN * 2)
	var panel_height := panel_width * float(skin.size.y) / float(skin.size.x)
	var available := view - Vector2(OUTER_MARGIN * 2, OUTER_MARGIN * 2 + PANEL_GAP + panel_height)
	var factor := maxi(1, floori(minf(available.x / native.x, available.y / native.y)))
	if factor == 1 and native.y + PANEL_GAP + panel_height + OUTER_MARGIN * 2 > view.y:
		panel_height = maxf(1.0, view.y - OUTER_MARGIN * 2 - PANEL_GAP - native.y)
		panel_width = minf(panel_width, panel_height * float(skin.size.x) / float(skin.size.y))
	var compact: bool = panel_width < 480.0
	dismissal_panel.body.add_theme_font_size_override("font_size", 32 if compact else 40)
	dismissal_panel.hint.add_theme_font_size_override("font_size", 20 if compact else 24)
	dismissal_panel.speaker.add_theme_font_size_override("font_size", 24 if compact else 30)
	artwork.size = native * factor
	artwork.position = Vector2(floorf((view.x - artwork.size.x) * 0.5), OUTER_MARGIN)
	dismissal_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	dismissal_panel.size = Vector2(panel_width, panel_height)
	dismissal_panel.position = Vector2(floorf((view.x - panel_width) * 0.5), artwork.position.y + artwork.size.y + PANEL_GAP)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	get_viewport().set_input_as_handled()
	if not event.is_action(&"dialogue_advance"):
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if not event.pressed:
		_held_keys.erase(key)
		return
	if not _armed or event.echo or _held_keys.has(key):
		return
	_held_keys[key] = true
	_dismiss()

func _on_dismiss_pressed() -> void:
	if _armed:
		_dismiss()

func _dismiss() -> void:
	if _dismissed:
		return
	_dismissed = true
	dismissed.emit()

func _exit_tree() -> void:
	if _previous_focus != null:
		var focus := _previous_focus.get_ref() as Control
		if is_instance_valid(focus) and focus.is_inside_tree() and focus.is_visible_in_tree():
			focus.grab_focus()
