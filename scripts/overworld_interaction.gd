extends Node2D
## One scene-local controller for environmental interactions, separate from the opening.

const DialoguePanel = preload("res://scripts/dialogue_panel.gd")
const Typewriter = preload("res://scripts/text_type.gd")

const Interactable = preload("res://scripts/overworld_interactable.gd")

signal interaction_started(target: Interactable)
signal interaction_finished(target: Interactable, completed: bool)

@export_node_path("CharacterBody2D") var player_path: NodePath = ^"../Player"
@export_range(8.0, 96.0, 1.0) var dialogue_edge_margin: float = 40.0

@onready var player: CharacterBody2D = get_node(player_path)
@onready var panel: DialoguePanel = $DialogueLayer/DialoguePanel
@onready var body: Typewriter = $DialogueLayer/DialoguePanel/Margin/Content/Body
@onready var prompt: Label = $DialogueLayer/Prompt

var dialogue_open: bool = false
var line_index: int = 0
var _movement_was_processing: bool = true
var _held_keys: Dictionary = {}
var _last_press_frame: int = -1
var _selected: Interactable
var active: Interactable
var _closing: bool = false
var _layout_busy: bool = false
var _player_bounds: Rect2
var _camera: Camera2D
var _camera_home: Vector2
var _camera_shifted: bool = false
var _camera_tween: Tween
var _layout_transform: Transform2D
var _layout_size: Vector2
var placement_issue: String = ""
var suspended: bool = false
var _resume_waiting_for_release: bool = false

const SUBJECT_PADDING: float = 8.0
const FRAME_TIME: float = 0.25

func _ready() -> void:
	body.clear_line()
	panel.hide()
	# This controller owns overworld input; the opening keeps its own handler.
	body.set_process_unhandled_key_input(false)
	get_window().focus_exited.connect(_clear_held_keys)
	_cache_visual_bounds()

func _process(_delta: float) -> void:
	if suspended:
		return
	if dialogue_open and not _layout_busy:
		# Recheck only when the camera or logical viewport actually changes.
		if not get_viewport().get_canvas_transform().is_equal_approx(_layout_transform) or get_viewport_rect().size != _layout_size:
			_position_dialogue()

func _physics_process(_delta: float) -> void:
	if suspended:
		prompt.hide()
		return
	if _resume_waiting_for_release:
		prompt.hide()
		if not Input.is_action_pressed(&"dialogue_advance") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_resume_waiting_for_release = false
			_last_press_frame = Engine.get_process_frames() + 1
		return
	var candidates: Array[Interactable] = []
	for node in get_tree().get_nodes_in_group("overworld_interactables"):
		if player.get_parent().is_ancestor_of(node):
			var target: Interactable = node
			target.observe(player.global_position)
			if target.available():
				candidates.append(target)
	if dialogue_open or _closing:
		prompt.hide()
		return
	# Keep a valid selection to avoid flickering between nearby objects.
	if not is_instance_valid(_selected) or not candidates.has(_selected):
		_selected = null
		candidates.sort_custom(func(a: Interactable, b: Interactable):
			var da: float = player.global_position.distance_squared_to(a.global_position)
			var db: float = player.global_position.distance_squared_to(b.global_position)
			return str(a.get_path()) < str(b.get_path()) if is_equal_approx(da, db) else da < db)
		if not candidates.is_empty():
			_selected = candidates[0]
	if is_instance_valid(_selected) and _selected.automatic_ready():
		_open_dialogue()
	_update_prompt()

func _update_prompt() -> void:
	prompt.visible = not dialogue_open and not _closing and is_instance_valid(_selected) and _selected.available() and not _selected.automatic_ready()
	if not prompt.visible:
		return
	var bounds: Rect2 = _selected.screen_bounds()
	var view: Rect2 = get_viewport_rect().grow(-8.0)
	prompt.size = prompt.get_combined_minimum_size().max(Vector2(120, 36))
	var positions: Array[Vector2] = [
		Vector2(bounds.get_center().x - prompt.size.x * 0.5, bounds.position.y - prompt.size.y - 8.0),
		Vector2(bounds.get_center().x - prompt.size.x * 0.5, bounds.end.y + 8.0),
		Vector2(bounds.end.x + 8.0, bounds.get_center().y - prompt.size.y * 0.5),
		Vector2(bounds.position.x - prompt.size.x - 8.0, bounds.get_center().y - prompt.size.y * 0.5)]
	for candidate in positions:
		candidate = candidate.clamp(view.position, view.end - prompt.size)
		if not Rect2(candidate, prompt.size).intersects(bounds):
			prompt.position = candidate
			return
	prompt.hide()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_action(&"dialogue_advance"):
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if not event.pressed:
		_held_keys.erase(key)
		return
	if suspended:
		return
	get_viewport().set_input_as_handled()
	if _resume_waiting_for_release:
		return
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
		elif line_index < active.lines.size() - 1:
			line_index += 1
			_present_line()
		else:
			_close_dialogue()
	elif not dialogue_open and not _closing and is_instance_valid(_selected) and _selected.available():
		_open_dialogue()

func _open_dialogue() -> void:
	if suspended or _resume_waiting_for_release:
		return
	active = _selected
	active.tree_exiting.connect(_on_active_target_exiting, CONNECT_ONE_SHOT)
	active.begin()
	panel.world = DialoguePanel.World.DREAM if active.presentation == Interactable.Presentation.DREAM else DialoguePanel.World.REAL
	prompt.hide()
	dialogue_open = true
	line_index = 0
	# Ignore entry-frame presses, including input queued for the next frame.
	_last_press_frame = Engine.get_process_frames() + 1
	_movement_was_processing = player.is_physics_processing()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.get_node("AnimatedSprite2D").show_idle()
	_present_line()
	interaction_started.emit(active)
	if not dialogue_open or not is_instance_valid(active):
		return
	_position_dialogue()

func _cache_visual_bounds() -> void:
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	# Protect every idle pose, including breathing and directional changes.
	for animation_name in sprite.sprite_frames.get_animation_names():
		if not String(animation_name).begins_with("idle_"):
			continue
		for frame in range(sprite.sprite_frames.get_frame_count(animation_name)):
			var texture: Texture2D = sprite.sprite_frames.get_frame_texture(animation_name, frame)
			var bounds := Rect2(texture.get_image().get_used_rect())
			bounds.position += sprite.offset - (texture.get_size() * 0.5 if sprite.centered else Vector2.ZERO)
			_player_bounds = _player_bounds.merge(bounds) if _player_bounds.has_area() else bounds

func _subject_rects() -> Array[Rect2]:
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var bounds: Rect2 = _player_bounds
	if sprite.flip_h:
		bounds.position.x = -bounds.end.x
	if sprite.flip_v:
		bounds.position.y = -bounds.end.y
	return [(sprite.get_global_transform_with_canvas() * bounds).grow(SUBJECT_PADDING),
		active.screen_bounds().grow(SUBJECT_PADDING)]

func _set_panel_edge(at_top: bool) -> void:
	var height: float = panel.size.y
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
		var rect: Rect2 = panel.get_global_rect()
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
			if not dialogue_open or not is_instance_valid(active):
				return
			_camera.force_update_scroll()
	# Check the real result, including limits, rather than trusting the planned pan.
	if chosen < 0 or not _fits(panel.get_global_rect(), _subject_rects()):
		placement_issue = "No safe top/bottom dialogue framing within the current viewport and camera limits."
		push_warning(placement_issue)
		_close_dialogue(false)
		return
	_layout_transform = get_viewport().get_canvas_transform()
	_layout_size = get_viewport_rect().size
	_layout_busy = false
	_last_press_frame = Engine.get_process_frames() + 1
	panel.show()

func _present_line() -> void:
	panel.speaker_name = active.speaker(line_index)
	body.present_line(active.lines[line_index])

func _close_dialogue(success: bool = true) -> void:
	if _closing or not dialogue_open:
		return
	_closing = true
	var finished: Interactable = active
	if is_instance_valid(finished):
		if finished.tree_exiting.is_connected(_on_active_target_exiting):
			finished.tree_exiting.disconnect(_on_active_target_exiting)
		finished.finish(success)
	active = null
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
		await _camera_tween.finished
		_camera_shifted = false
	_closing = false
	_last_press_frame = Engine.get_process_frames() + 1
	interaction_finished.emit(finished if is_instance_valid(finished) else null, success)

func _on_active_target_exiting() -> void:
	_close_dialogue(false)

func _exit_tree() -> void:
	if is_instance_valid(_camera_tween):
		_camera_tween.kill()
	if _camera_shifted and is_instance_valid(_camera):
		_camera.position = _camera_home
	if (dialogue_open or _closing) and is_instance_valid(player):
		player.velocity = Vector2.ZERO
		player.set_physics_process(_movement_was_processing)

func _clear_held_keys() -> void:
	_held_keys.clear()

func set_suspended(value: bool) -> bool:
	# Do not transfer movement/camera ownership during an active interaction.
	if value and (dialogue_open or _closing or _layout_busy):
		push_warning("Finish the environmental interaction before suspending it.")
		return false
	if suspended == value:
		return true
	suspended = value
	_selected = null
	prompt.hide()
	_clear_held_keys()
	_last_press_frame = Engine.get_process_frames() + 1
	# A story's final held press must be released before exploration can react.
	_resume_waiting_for_release = not value
	return true
