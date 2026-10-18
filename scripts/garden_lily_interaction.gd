extends Node2D

const DialoguePanel = preload("res://scripts/dialogue_panel.gd")
const Typewriter = preload("res://scripts/text_Type.gd")

# Temporary lines for testing the Garden interaction.
const LINES: Array[Dictionary] = [
	{"speaker": "???", "text": "You came back."},
	{"speaker": "Albert", "text": "What... is this thing?"},
	{"speaker": "???", "text": "You don't remember?"},
]

@export_range(24.0, 128.0, 1.0) var interaction_distance: float = 84.0
@export_range(8.0, 96.0, 1.0) var dialogue_edge_margin: float = 40.0

@onready var player: CharacterBody2D = $Player
@onready var lily: StaticBody2D = $Garden/Props/CorpseLily
@onready var panel: DialoguePanel = $DialogueLayer/DialoguePanel
@onready var body: Typewriter = $DialogueLayer/DialoguePanel/Margin/Content/Body

var dialogue_open: bool = false
var line_index: int = 0
var _movement_was_processing: bool = true
var _held_keys: Dictionary = {}
var _last_press_frame: int = -1
var _was_in_range: bool = false
var _layout_busy: bool = false
var _player_bounds: Rect2
var _lily_bounds: Rect2
var _camera: Camera2D
var _camera_home: Vector2
var _camera_shifted: bool = false
var _camera_tween: Tween
var _layout_transform: Transform2D
var _layout_size: Vector2
var placement_issue: String = ""

const SUBJECT_PADDING: float = 8.0
const FRAME_TIME: float = 0.25

func _ready() -> void:
	panel.world = DialoguePanel.World.DREAM
	body.clear_line()
	panel.hide()
	# One input handler owns opening, revealing, advancing, and closing.
	body.set_process_unhandled_key_input(false)
	get_window().focus_exited.connect(_clear_held_keys)
	_cache_visual_bounds()

func _process(_delta: float) -> void:
	if dialogue_open and not _layout_busy:
		# Recheck only when the camera or logical viewport actually changes.
		if not get_viewport().get_canvas_transform().is_equal_approx(_layout_transform) or get_viewport_rect().size != _layout_size:
			_position_dialogue()

func _physics_process(_delta: float) -> void:
	var in_range: bool = player.global_position.distance_squared_to(lily.global_position) <= interaction_distance * interaction_distance
	if in_range and not _was_in_range and not dialogue_open:
		_open_dialogue()
	_was_in_range = in_range

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_action(&"dialogue_advance"):
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if not event.pressed:
		_held_keys.erase(key)
		return
	get_viewport().set_input_as_handled()
	if event.echo or _held_keys.has(key):
		return
	_held_keys[key] = true
	var frame: int = Engine.get_process_frames()
	if frame <= _last_press_frame:
		return
	_last_press_frame = frame
	if dialogue_open and not _layout_busy:
		if body.is_typing:
			body.reveal_line()
		elif line_index < LINES.size() - 1:
			line_index += 1
			_present_line()
		else:
			_close_dialogue()

func _open_dialogue() -> void:
	dialogue_open = true
	line_index = 0
	# Ignore entry-frame presses, including input queued for the next frame.
	_last_press_frame = Engine.get_process_frames() + 1
	_movement_was_processing = player.is_physics_processing()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.get_node("AnimatedSprite2D").play("Idle")
	_present_line()
	_position_dialogue()

func _cache_visual_bounds() -> void:
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	for frame in range(sprite.sprite_frames.get_frame_count("Idle")):
		var texture: Texture2D = sprite.sprite_frames.get_frame_texture("Idle", frame)
		var bounds := Rect2(texture.get_image().get_used_rect())
		bounds.position += sprite.offset - (texture.get_size() * 0.5 if sprite.centered else Vector2.ZERO)
		_player_bounds = bounds if frame == 0 else _player_bounds.merge(bounds)
	# The procedural Lily is drawn within its extent. Include every idle position.
	var visual: Node2D = lily.get_node("Visual")
	var idle: Animation = $LilyIdle.get_animation("lily_idle")
	for key in range(idle.track_get_key_count(0)):
		var pose: Transform2D = visual.transform
		pose.origin = idle.track_get_key_value(0, key)
		var bounds: Rect2 = pose * Rect2(Vector2.ZERO, visual.extent)
		_lily_bounds = bounds if key == 0 else _lily_bounds.merge(bounds)

func _subject_rects() -> Array[Rect2]:
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var bounds: Rect2 = _player_bounds
	if sprite.flip_h:
		bounds.position.x = -bounds.end.x
	if sprite.flip_v:
		bounds.position.y = -bounds.end.y
	return [(sprite.get_global_transform_with_canvas() * bounds).grow(SUBJECT_PADDING),
		(lily.get_global_transform_with_canvas() * _lily_bounds).grow(SUBJECT_PADDING)]

func _set_panel_edge(at_top: bool) -> void:
	var height: float = panel.artwork.size.y
	var anchor: float = 0.0 if at_top else 1.0
	panel.anchor_top = anchor
	panel.anchor_bottom = anchor
	panel.offset_bottom = dialogue_edge_margin + height if at_top else -dialogue_edge_margin
	panel.offset_top = dialogue_edge_margin if at_top else -dialogue_edge_margin - height

func _fits(rect: Rect2, subjects: Array[Rect2]) -> bool:
	var viewport: Rect2 = get_viewport_rect()
	if not viewport.encloses(rect):
		return false
	for subject in subjects:
		if not viewport.encloses(subject) or rect.intersects(subject):
			return false
	return true

func _framing_shift(rect: Rect2, at_top: bool, subjects: Array[Rect2]) -> Vector2:
	# A short pan is supported for the existing unrotated, non-drag cameras.
	if _camera == null or not is_zero_approx(_camera.get_screen_rotation()) or _camera.drag_horizontal_enabled or _camera.drag_vertical_enabled:
		return Vector2(INF, INF)
	var viewport: Rect2 = get_viewport_rect()
	var occupied: Rect2 = subjects[0].merge(subjects[1])
	var free := viewport.grow(-SUBJECT_PADDING)
	if at_top:
		free.position.y = rect.end.y + 1.0
		free.size.y = viewport.end.y - SUBJECT_PADDING - free.position.y
	else:
		free.size.y = rect.position.y - 1.0 - free.position.y
	var minimum: Vector2 = free.position - occupied.position
	var maximum: Vector2 = free.end - occupied.end
	if _camera.limit_enabled:
		var world_view: Rect2 = get_viewport().get_canvas_transform().affine_inverse() * viewport
		minimum = minimum.max((world_view.end - Vector2(_camera.limit_right, _camera.limit_bottom)) * _camera.zoom)
		maximum = maximum.min((world_view.position - Vector2(_camera.limit_left, _camera.limit_top)) * _camera.zoom)
	minimum = minimum.ceil()
	maximum = maximum.floor()
	if minimum.x > maximum.x or minimum.y > maximum.y:
		return Vector2(INF, INF)
	return Vector2.ZERO.clamp(minimum, maximum)

func _position_dialogue() -> void:
	_layout_busy = true
	panel.hide()
	placement_issue = ""
	if _camera_tween != null and _camera_tween.is_running():
		_camera_tween.kill()
	_camera = get_viewport().get_camera_2d()
	if _camera != null:
		if not _camera_shifted:
			_camera_home = _camera.position
		_camera.force_update_scroll()
	var subjects: Array[Rect2] = _subject_rects()
	var edges: Array[bool] = [false, true]
	var chosen: int = -1
	var shift := Vector2(INF, INF)
	for index in range(edges.size()):
		_set_panel_edge(edges[index])
		var rect: Rect2 = panel.artwork.get_global_rect()
		var candidate: Vector2 = Vector2.ZERO if _fits(rect, subjects) else _framing_shift(rect, edges[index], subjects)
		if candidate.length_squared() < shift.length_squared():
			chosen = index
			shift = candidate
	if chosen >= 0:
		_set_panel_edge(edges[chosen])
		if not shift.is_zero_approx():
			_camera_shifted = true
			var target: Vector2 = _camera.get_screen_center_position() - _camera.offset - shift / _camera.zoom
			var local_target: Vector2 = _camera.get_parent().to_local(target)
			_camera_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_camera_tween.tween_property(_camera, "position", local_target, FRAME_TIME)
			await _camera_tween.finished
			_camera.force_update_scroll()
	# Check the real result, including limits, rather than trusting the planned pan.
	if chosen < 0 or not _fits(panel.artwork.get_global_rect(), _subject_rects()):
		placement_issue = "No safe top/bottom dialogue framing within the current viewport and camera limits."
		push_warning(placement_issue)
		_close_dialogue()
		return
	_layout_transform = get_viewport().get_canvas_transform()
	_layout_size = get_viewport_rect().size
	_layout_busy = false
	_last_press_frame = Engine.get_process_frames() + 1
	panel.show()

func _present_line() -> void:
	panel.speaker_name = LINES[line_index]["speaker"]
	body.present_line(LINES[line_index]["text"])

func _close_dialogue() -> void:
	body.clear_line()
	panel.hide()
	dialogue_open = false
	_layout_busy = false
	player.velocity = Vector2.ZERO
	player.set_physics_process(_movement_was_processing)
	if _camera_shifted and is_instance_valid(_camera):
		if _camera_tween != null and _camera_tween.is_running():
			_camera_tween.kill()
		_camera_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_camera_tween.tween_property(_camera, "position", _camera_home, FRAME_TIME)
		_camera_tween.tween_callback(func(): _camera_shifted = false)

func _clear_held_keys() -> void:
	_held_keys.clear()
