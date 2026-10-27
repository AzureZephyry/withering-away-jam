extends CanvasLayer
## Reads session time and yields screen space to existing gameplay UI.

@export var display_size: Vector2 = Vector2(210, 56)
@export var avoid_controls: Array[NodePath] = []

@onready var clock: Node = get_node("/root/GameClock")
@onready var screen: Control = $Screen
@onready var frame: Panel = $Screen/Frame
@onready var readout: Control = $Screen/Frame/Readout
@onready var previous_label: Label = $Screen/Frame/Readout/Previous
@onready var current_label: Label = $Screen/Frame/Readout/Current

var displayed_time: String = ""
var gameplay_active: bool = true
var _blockers: Array[Control] = []
var _target := Vector2(-1, -1)
var _dirty: bool = true
var _scan_queued: bool = false
var _text_tween: Tween
var _move_tween: Tween
var _fade_tween: Tween
var _alpha_target: float = -1.0

func _ready() -> void:
	for other in get_tree().get_nodes_in_group("time_hud"):
		if other != self and other.get_viewport() == get_viewport() and not other.is_queued_for_deletion():
			queue_free()
			return
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 1000
	frame.size = display_size
	frame.modulate.a = 0.0
	displayed_time = format_time(clock.get_hour(), clock.get_minute())
	current_label.text = displayed_time
	previous_label.modulate.a = 0.0
	clock.minute_changed.connect(_on_minute_changed)
	clock.time_overridden.connect(_on_time_overridden)
	screen.resized.connect(_on_obstacle_changed)
	get_tree().node_added.connect(_on_node_added)
	_queue_scan()

static func format_time(hour: int, minute: int) -> String:
	var hour12: int = hour % 12
	return "%d:%02d %s" % [12 if hour12 == 0 else hour12, minute, "AM" if hour < 12 else "PM"]

func _on_minute_changed(hour: int, minute: int) -> void:
	_animate_time(format_time(hour, minute), 0.24)

func _on_time_overridden(previous: float, current: float) -> void:
	var distance: float = minf(fposmod(current - previous, 1440.0), fposmod(previous - current, 1440.0))
	_animate_time(format_time(clock.get_hour(), clock.get_minute()), 0.6 if distance >= 2.0 else 0.24)

func _animate_time(text: String, duration: float) -> void:
	if text == displayed_time:
		return
	if is_instance_valid(_text_tween):
		_text_tween.kill()
	previous_label.text = displayed_time
	displayed_time = text
	current_label.text = text
	previous_label.position.y = 0.0
	previous_label.modulate.a = 1.0
	current_label.position.y = 6.0
	current_label.modulate.a = 0.0
	_text_tween = create_tween().set_parallel(true).set_ignore_time_scale(true)
	_text_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_text_tween.tween_property(previous_label, "position:y", -6.0, duration)
	_text_tween.tween_property(previous_label, "modulate:a", 0.0, duration)
	_text_tween.tween_property(current_label, "position:y", 0.0, duration)
	_text_tween.tween_property(current_label, "modulate:a", 1.0, duration)

func _on_node_added(node: Node) -> void:
	if (node is Control or node is CanvasLayer) and not is_ancestor_of(node):
		_queue_scan()

func _queue_scan() -> void:
	if _scan_queued:
		return
	_scan_queued = true
	_scan_blockers.call_deferred()

func _scan_blockers() -> void:
	_scan_queued = false
	_blockers.clear()
	for node in get_tree().get_nodes_in_group("dialogue_panels") + get_tree().get_nodes_in_group("time_hud_obstacles"):
		_add_blocker(node as Control)
	for hud in get_tree().get_nodes_in_group("sanity_hud"):
		_add_blocker(hud.get_node_or_null("Screen/Frame") as Control)
	for node in get_tree().root.find_children("*", "Control", true, false):
		if node.name in [&"Prompt", &"Objective", &"DoorPrompt", &"Choices", &"Endpoint", &"Fade", &"ArrivalFade"]:
			_add_blocker(node)
		var script: Script = node.get_script()
		if script != null and script.resource_path == "res://scripts/object_focus_presenter.gd":
			_add_blocker(node.get_node_or_null("SafeArea") as Control)
	for path in avoid_controls:
		_add_blocker(get_node_or_null(path) as Control)
	_on_obstacle_changed()

func _add_blocker(control: Control) -> void:
	if control == null or control.get_viewport() != get_viewport() or _blockers.has(control):
		return
	_blockers.append(control)
	if not control.item_rect_changed.is_connected(_on_obstacle_changed):
		control.item_rect_changed.connect(_on_obstacle_changed)
		control.visibility_changed.connect(_on_obstacle_changed)
		control.tree_exiting.connect(_on_obstacle_changed)

func _rectangles() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for control in _blockers:
		if is_instance_valid(control) and control.is_visible_in_tree():
			result.append(control.get_global_rect().grow(10.0))
	return result

func _clear(rect: Rect2, obstacles: Array[Rect2]) -> bool:
	if not Rect2(Vector2.ZERO, screen.size).encloses(rect):
		return false
	for obstacle in obstacles:
		if rect.intersects(obstacle):
			return false
	return true

func _on_obstacle_changed() -> void:
	_dirty = true
	if is_inside_tree() and is_node_ready() and is_instance_valid(frame) and not _clear(frame.get_global_rect(), _rectangles()):
		_set_readable(false)

func _process(_delta: float) -> void:
	if _dirty or (is_instance_valid(_move_tween) and _move_tween.is_running()):
		_place()

func set_gameplay_active(active: bool) -> void:
	gameplay_active = active
	_dirty = true
	if not active:
		_set_readable(false)

func _place() -> void:
	_dirty = false
	if not gameplay_active:
		_set_readable(false)
		return
	var margin: float = roundf(minf(24.0, minf(screen.size.x, screen.size.y) * 0.04))
	var right: float = screen.size.x - margin - frame.size.x
	var bottom: float = screen.size.y - margin - frame.size.y
	var middle: float = roundf((screen.size.y - frame.size.y) * 0.5)
	var obstacles: Array[Rect2] = _rectangles()
	var destination := Vector2(-1, -1)
	for candidate: Vector2 in [Vector2(margin, margin), Vector2(right, margin), Vector2(margin, bottom), Vector2(right, bottom), Vector2(margin, middle), Vector2(right, middle)]:
		if _clear(Rect2(candidate, frame.size), obstacles):
			destination = candidate
			break
	if destination.x < 0.0:
		_set_readable(false)
		return
	if not destination.is_equal_approx(_target):
		if is_instance_valid(_move_tween):
			_move_tween.kill()
		if _target.x < 0.0:
			frame.position = destination
		else:
			_move_tween = create_tween().set_ignore_time_scale(true)
			_move_tween.tween_property(frame, "position", destination, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		_target = destination
	_set_readable(_clear(frame.get_global_rect(), obstacles))

func _set_readable(readable: bool) -> void:
	var alpha: float = 1.0 if readable else 0.0
	if is_equal_approx(alpha, _alpha_target):
		return
	_alpha_target = alpha
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
	if not readable:
		# Hide immediately when critical UI enters the current or moving footprint.
		frame.modulate.a = 0.0
	else:
		_fade_tween = create_tween().set_ignore_time_scale(true)
		_fade_tween.tween_property(frame, "modulate:a", 1.0, 0.12)
