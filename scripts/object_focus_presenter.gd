extends Control
## Artwork only. The environmental controller keeps input and movement ownership.

@export var screen_margin: float = 24.0

@onready var dimmer: ColorRect = $Dimmer
@onready var safe_area: Control = $SafeArea
@onready var artwork: TextureRect = $SafeArea/Artwork

var current_texture: Texture2D
var visible_bounds: Rect2
var _target: OverworldInteractable
var _controller: Node
var _panel: Control
var _hud_frames: Array[Control] = []
var _layout_queued: bool = false

func _ready() -> void:
	hide()
	_bind.call_deferred()

func _bind() -> void:
	_controller = get_parent().get_parent()
	_panel = get_parent().get_node("DialoguePanel")
	_controller.interaction_started.connect(_on_started)
	_controller.interaction_finished.connect(_on_finished)
	_panel.visibility_changed.connect(_queue_layout)
	_panel.item_rect_changed.connect(_queue_layout)
	for hud in get_tree().get_nodes_in_group("sanity_hud"):
		var frame: Control = hud.get_node_or_null("Screen/Frame") as Control
		if frame != null and frame.get_viewport() == get_viewport():
			_hud_frames.append(frame)
			frame.item_rect_changed.connect(_queue_layout)
	resized.connect(_queue_layout)

func _on_started(target: OverworldInteractable) -> void:
	_clear()
	if not is_instance_valid(target) or target.focus_texture == null:
		return
	var image: Image = target.focus_texture.get_image()
	if image == null or image.is_empty():
		push_warning("Object Focus could not read the illustration for %s; using dialogue only." % target.name)
		return
	visible_bounds = Rect2(image.get_used_rect())
	if not visible_bounds.has_area():
		return
	_target = target
	current_texture = target.focus_texture
	_target.tree_exiting.connect(_clear, CONNECT_ONE_SHOT)
	# Trim transparent display padding without changing the source texture.
	var trimmed := AtlasTexture.new()
	trimmed.atlas = current_texture
	trimmed.region = visible_bounds
	artwork.texture = trimmed
	_queue_layout()

func _on_finished(_target_node: OverworldInteractable, _completed: bool) -> void:
	_clear()

func _queue_layout() -> void:
	if not is_instance_valid(_panel) or not _panel.is_visible_in_tree():
		hide()
	if _layout_queued:
		return
	_layout_queued = true
	_layout.call_deferred()

func _layout() -> void:
	_layout_queued = false
	if not is_instance_valid(_target) or current_texture == null or not _panel.is_visible_in_tree():
		hide()
		return
	var panel_rect: Rect2 = _panel.get_global_rect()
	var top: float = screen_margin
	var bottom: float = size.y - screen_margin
	var dialogue_at_top: bool = panel_rect.get_center().y < size.y * 0.5
	if dialogue_at_top:
		top = panel_rect.end.y + screen_margin
	else:
		bottom = panel_rect.position.y - screen_margin
	# Leave the HUD's corner band clear, without shifting the illustration sideways.
	for frame in _hud_frames:
		if not is_instance_valid(frame) or not frame.is_visible_in_tree():
			continue
		var rect: Rect2 = frame.get_global_rect()
		var edge_margin: float = maxf(0.0, minf(rect.position.y, size.y - rect.end.y))
		var clearance: float = rect.size.y + edge_margin + screen_margin
		if dialogue_at_top:
			bottom = minf(bottom, size.y - clearance)
		else:
			top = maxf(top, clearance)
	var available := Vector2(size.x - screen_margin * 2.0, bottom - top)
	if available.x <= 0.0 or available.y <= 0.0:
		hide()
		return
	safe_area.position = Vector2(screen_margin, top)
	safe_area.size = available
	var factor: float = minf(available.x / visible_bounds.size.x, available.y / visible_bounds.size.y)
	if factor >= 1.0:
		factor = floorf(factor)
	artwork.size = visible_bounds.size * factor
	artwork.position = (safe_area.size - artwork.size) * 0.5
	show()

func _clear() -> void:
	hide()
	if is_instance_valid(_target) and _target.tree_exiting.is_connected(_clear):
		_target.tree_exiting.disconnect(_clear)
	_target = null
	current_texture = null
	visible_bounds = Rect2()
	if is_instance_valid(artwork):
		artwork.texture = null
