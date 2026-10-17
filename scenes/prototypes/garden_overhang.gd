extends CanvasGroup
## Garden overhead foliage/roof. Only this composite fades; ground and supports stay opaque.

@export_node_path("Node2D") var player_path: NodePath = ^"../../../../Player"
@export_range(0.1, 1.0, 0.01) var faded_opacity: float = 0.52
@export_range(0.05, 1.0, 0.01) var fade_in_seconds: float = 0.16
@export_range(0.05, 1.0, 0.01) var fade_out_seconds: float = 0.22
@export_range(0.0, 8.0, 0.5) var exit_padding: float = 3.0

var obscuring_player: bool = false
var _sprite: AnimatedSprite2D
var _ellipses: Array[Rect2] = []
var _polygon: PackedVector2Array = PackedVector2Array()
var _axes: PackedVector2Array = PackedVector2Array()
var _intervals: PackedVector2Array = PackedVector2Array()
var _polygon_bounds: Rect2

func _ready() -> void:
	var player: Node = get_node_or_null(player_path)
	if player == null:
		set_process(false)
		return
	_sprite = player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if _sprite == null:
		set_process(false)
		return
	var drawing: Node = get_node("Visual")
	_ellipses = drawing.call("occlusion_ellipses")
	_polygon = drawing.call("occlusion_polygon")
	if not _polygon.is_empty():
		_polygon_bounds = Rect2(_polygon[0], Vector2.ZERO)
		for point in _polygon:
			_polygon_bounds = _polygon_bounds.expand(point)
		for i in range(_polygon.size()):
			var edge: Vector2 = _polygon[(i + 1) % _polygon.size()] - _polygon[i]
			var axis := Vector2(-edge.y, edge.x).normalized()
			var lo: float = INF
			var hi: float = -INF
			for point in _polygon:
				var projection: float = axis.dot(point)
				lo = minf(lo, projection)
				hi = maxf(hi, projection)
			_axes.append(axis)
			_intervals.append(Vector2(lo, hi))

func _process(delta: float) -> void:
	if not is_instance_valid(_sprite):
		set_process(false)
		return
	var texture: Texture2D = _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame)
	var size: Vector2 = texture.get_size()
	var origin: Vector2 = _sprite.offset - size * 0.5 if _sprite.centered else _sprite.offset
	var world_rect: Rect2 = _sprite.global_transform * Rect2(origin, size)
	var local_rect: Rect2 = global_transform.affine_inverse() * world_rect
	if obscuring_player:
		local_rect = local_rect.grow(exit_padding)
	obscuring_player = _overlaps(local_rect)
	var target: float = faded_opacity if obscuring_player else 1.0
	var seconds: float = fade_in_seconds if obscuring_player else fade_out_seconds
	self_modulate.a = move_toward(self_modulate.a, target, delta * (1.0 - faded_opacity) / seconds)

func _overlaps(rect: Rect2) -> bool:
	for ellipse in _ellipses:
		var ellipse_center: Vector2 = ellipse.get_center()
		var nearest := Vector2(clampf(ellipse_center.x, rect.position.x, rect.end.x), clampf(ellipse_center.y, rect.position.y, rect.end.y))
		var distance: Vector2 = (nearest - ellipse_center) / (ellipse.size * 0.5)
		if distance.length_squared() <= 1.0:
			return true
	if _polygon.is_empty() or not rect.intersects(_polygon_bounds):
		return false
	var center: Vector2 = rect.get_center()
	var half: Vector2 = rect.size * 0.5
	for i in range(_axes.size()):
		var axis: Vector2 = _axes[i]
		var projection: float = axis.dot(center)
		var radius: float = absf(axis.x) * half.x + absf(axis.y) * half.y
		if projection + radius < _intervals[i].x or projection - radius > _intervals[i].y:
			return false
	return true
