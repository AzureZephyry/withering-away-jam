extends Node
## Project an actor's current visual into a compatible environment's ground mask.

@export_node_path("AnimatedSprite2D", "Sprite2D") var visual_source_path: NodePath = ^"../AnimatedSprite2D"
@export_node_path("Node2D") var feet_anchor_path: NodePath = ^".."
@export var feet_offset := Vector2.ZERO
@export_range(0.1, 1.5, 0.05) var height_scale: float = 0.75
@export_range(0.02, 0.3, 0.01) var ground_depth: float = 0.12
@export_range(0.0, 1.0, 0.05) var cast_strength: float = 0.8
@export_range(0.0, 1.0, 0.05) var contact_strength: float = 0.8
@export var contact_size := Vector2(18, 6)

@onready var mask_visual: Node2D = $MaskVisual
@onready var cast: Sprite2D = $MaskVisual/Cast
@onready var contact: Polygon2D = $MaskVisual/Contact

var receiver: Node
var _source: Node2D
var _feet: Node2D
var _cast_strength: float = -1.0
var _contact_strength: float = -1.0
const VISUAL_PROPERTIES: Array[StringName] = [&"centered", &"offset", &"flip_h", &"flip_v"]
const SPRITE_PROPERTIES: Array[StringName] = [&"region_enabled", &"region_rect", &"hframes", &"vframes", &"frame"]

func _enter_tree() -> void:
	if is_node_ready():
		_bind_default.call_deferred()

func _ready() -> void:
	_source = get_node_or_null(visual_source_path) as Node2D
	_feet = get_node_or_null(feet_anchor_path) as Node2D
	set_process(false)
	_bind_default.call_deferred()

func _bind_default() -> void:
	if receiver == null:
		bind_receiver(get_tree().get_first_node_in_group("actor_shadow_receiver"))

func bind_receiver(environment: Node) -> bool:
	if not is_instance_valid(environment) or not environment.has_method("attach_actor_shadow"):
		return false
	if not (_source is AnimatedSprite2D or _source is Sprite2D) or _feet == null:
		return false
	receiver = environment
	receiver.attach_actor_shadow(mask_visual)
	set_process(true)
	_process(0.0)
	return true

func _process(_delta: float) -> void:
	if not is_instance_valid(receiver) or not is_instance_valid(mask_visual):
		set_process(false)
		return
	if not is_instance_valid(_source) or not is_instance_valid(_feet):
		mask_visual.hide()
		receiver.request_actor_shadow_redraw()
		set_process(false)
		return
	var changed: bool = false
	var shown: bool = _source.is_visible_in_tree() and receiver.prototype_enabled
	if mask_visual.visible != shown:
		mask_visual.visible = shown
		changed = true
	if not shown:
		if changed:
			receiver.request_actor_shadow_redraw()
		return
	var texture: Texture2D
	if _source is AnimatedSprite2D:
		var frames: SpriteFrames = _source.sprite_frames
		if frames != null and frames.has_animation(_source.animation) and frames.get_frame_count(_source.animation) > _source.frame:
			texture = frames.get_frame_texture(_source.animation, _source.frame)
	else:
		texture = _source.texture
		for property: StringName in SPRITE_PROPERTIES:
			if cast.get(property) != _source.get(property):
				cast.set(property, _source.get(property))
				changed = true
	if cast.texture != texture:
		cast.texture = texture
		changed = true
	for property: StringName in VISUAL_PROPERTIES:
		if cast.get(property) != _source.get(property):
			cast.set(property, _source.get(property))
			changed = true
	var map: Sprite2D = receiver.get_actor_shadow_map()
	var inverse: Transform2D = map.global_transform.affine_inverse()
	var feet: Vector2 = inverse * (_feet.global_transform * feet_offset)
	var visual: Transform2D = inverse * _source.global_transform
	visual.origin -= feet
	var slope: Vector2 = receiver.sun_direction * receiver.length_ratio * height_scale
	var flatten := Transform2D(Vector2.RIGHT, Vector2(-slope.x, ground_depth - slope.y), feet)
	var projected: Transform2D = flatten * visual
	if cast.transform.origin.distance_squared_to(projected.origin) > 0.0004 or cast.transform.x.distance_squared_to(projected.x) > 0.000001 or cast.transform.y.distance_squared_to(projected.y) > 0.000004:
		cast.transform = projected
		changed = true
	var sunlight: bool = receiver.sun_opacity > 0.00001 and texture != null
	if cast.visible != sunlight:
		cast.visible = sunlight
		changed = true
	var contact_transform := Transform2D(Vector2(1.0 / map.global_scale.x, 0), Vector2(0, 1.0 / map.global_scale.y), feet)
	contact_transform = contact_transform.scaled_local(contact_size / Vector2(18, 6))
	if not contact.transform.is_equal_approx(contact_transform):
		contact.transform = contact_transform
		changed = true
	if _cast_strength != cast_strength:
		cast.material.set_shader_parameter("strength", cast_strength)
		_cast_strength = cast_strength
		changed = true
	if _contact_strength != contact_strength:
		contact.material.set_shader_parameter("strength", contact_strength)
		_contact_strength = contact_strength
		changed = true
	if changed:
		receiver.request_actor_shadow_redraw()

func _exit_tree() -> void:
	if is_instance_valid(receiver):
		receiver.request_actor_shadow_redraw()
	# Return the proxy so removal/re-entry and freeing follow the actor's lifetime.
	if is_instance_valid(mask_visual) and mask_visual.get_parent() != self:
		mask_visual.reparent(self, false)
		mask_visual.hide()
	receiver = null
