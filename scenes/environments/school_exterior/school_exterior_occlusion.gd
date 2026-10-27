extends Node2D
## School foreground fades only where its pixels cover Albert's current sprite.

@export_node_path("AnimatedSprite2D") var player_sprite_path: NodePath = ^"Player/AnimatedSprite2D"
@export_node_path("Sprite2D") var map_path: NodePath = ^"SchoolExterior/Map"
@export_node_path("Node2D") var occluders_path: NodePath = ^"SchoolExterior/Occluders"
@export var occlusion_mask: Texture2D
@export_range(0.1, 1.0, 0.01) var faded_opacity: float = 0.65
@export_range(0.05, 1.0, 0.01) var fade_seconds: float = 0.20
@export_range(0.0, 0.2, 0.01) var clear_delay_seconds: float = 0.06

var obscuring_ids: Dictionary = {}
var _sprite: AnimatedSprite2D
var _map: Sprite2D
var _mask: PackedByteArray
var _mask_size: Vector2i
var _additional_masks: Array[PackedByteArray] = []
var _objects: Dictionary = {}
var _frames: Dictionary = {}

func _ready() -> void:
	_sprite = get_node(player_sprite_path) as AnimatedSprite2D
	_map = get_node(map_path) as Sprite2D
	var image: Image = occlusion_mask.get_image()
	image.convert(Image.FORMAT_RGBA8)
	_mask = image.get_data()
	_mask_size = image.get_size()
	var mask_textures: Array[Texture2D] = [occlusion_mask]
	for root: Node2D in get_node(occluders_path).get_children():
		var material: ShaderMaterial = root.get_node("Artwork").material as ShaderMaterial
		if not material.get_shader_parameter("fade_enabled"):
			continue
		var object_mask: Texture2D = material.get_shader_parameter("occlusion_mask")
		if not mask_textures.has(object_mask):
			var additional: Image = object_mask.get_image()
			if additional.get_size() != _mask_size:
				push_error("School foreground masks must share the map dimensions.")
				continue
			additional.convert(Image.FORMAT_RGBA8)
			_additional_masks.append(additional.get_data())
			mask_textures.append(object_mask)
		var id: int = roundi(float(material.get_shader_parameter("object_mask_value")) * 255.0)
		_objects[id] = {"root": root, "material": material, "opacity": 1.0,
			"cutoff": float(material.get_shader_parameter("fade_cutoff_y")) * _mask_size.y,
			"clear_time": 0.0}

func _process(delta: float) -> void:
	if not is_instance_valid(_sprite):
		return
	obscuring_ids = _covered_objects()
	for id: int in _objects:
		var object: Dictionary = _objects[id]
		object.clear_time = clear_delay_seconds if obscuring_ids.has(id) else maxf(0.0, object.clear_time - delta)
		var target: float = faded_opacity if obscuring_ids.has(id) or object.clear_time > 0.0 else 1.0
		object.opacity = move_toward(object.opacity, target, delta * (1.0 - faded_opacity) / fade_seconds)
		object.material.set_shader_parameter("fade_opacity", object.opacity)

func _covered_objects() -> Dictionary:
	var covered: Dictionary = {}
	var texture: Texture2D = _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame)
	if not _frames.has(texture):
		var image: Image = texture.get_image()
		image.convert(Image.FORMAT_RGBA8)
		_frames[texture] = {"size": image.get_size(), "pixels": image.get_data()}
	var frame: Dictionary = _frames[texture]
	var size := Vector2(frame.size)
	var origin: Vector2 = _sprite.offset - size * 0.5 if _sprite.centered else _sprite.offset
	var world_rect: Rect2 = _sprite.global_transform * Rect2(origin, size)
	var sprite_inverse: Transform2D = _sprite.global_transform.affine_inverse()
	var map_inverse: Transform2D = _map.global_transform.affine_inverse()
	var player_y: float = _sprite.get_parent().global_position.y
	for y in range(floori(world_rect.position.y), ceili(world_rect.end.y)):
		for x in range(floori(world_rect.position.x), ceili(world_rect.end.x)):
			var world_point := Vector2(x + 0.5, y + 0.5)
			var map_point: Vector2 = map_inverse * world_point
			var mx: int = floori(map_point.x)
			var my: int = floori(map_point.y)
			if mx < 0 or my < 0 or mx >= _mask_size.x or my >= _mask_size.y:
				continue
			var id: int = _mask[(my * _mask_size.x + mx) * 4 + 3]
			if id == 0:
				for additional: PackedByteArray in _additional_masks:
					id = additional[(my * _mask_size.x + mx) * 4 + 3]
					if id != 0:
						break
			if not _objects.has(id):
				continue
			var object: Dictionary = _objects[id]
			if object.root.global_position.y <= player_y or map_point.y >= object.cutoff:
				continue
			var local_point: Vector2 = sprite_inverse * world_point - origin
			var sx: int = floori(local_point.x)
			var sy: int = floori(local_point.y)
			if sx < 0 or sy < 0 or sx >= frame.size.x or sy >= frame.size.y:
				continue
			if _sprite.flip_h:
				sx = frame.size.x - 1 - sx
			if _sprite.flip_v:
				sy = frame.size.y - 1 - sy
			if frame.pixels[(sy * frame.size.x + sx) * 4 + 3] > 0:
				covered[id] = true
	return covered
