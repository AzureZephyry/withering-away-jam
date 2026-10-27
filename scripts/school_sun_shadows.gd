extends Node
## Campus caster models share one sun and a ground-only pixel mask.

@export var prototype_enabled: bool = true:
	set(value):
		prototype_enabled = value
		if is_node_ready():
			if value:
				_update_state()
				_update_projection()
			_apply_uniforms()
			$Mask.render_target_update_mode = SubViewport.UPDATE_ONCE if value else SubViewport.UPDATE_DISABLED
@export_range(0.0, 12.0, 0.25) var sunrise_hour: float = 5.0
@export_range(12.0, 24.0, 0.25) var sunset_hour: float = 19.0
@export_range(30.0, 85.0, 1.0) var peak_elevation_degrees: float = 68.0
@export_range(1.0, 5.0, 0.1) var maximum_length_ratio: float = 3.2
@export_range(0.0, 0.6, 0.01) var maximum_sun_opacity: float = 0.30
@export_range(0.0, 0.3, 0.01) var contact_opacity: float = 0.14
@export_range(5.0, 30.0, 1.0) var horizon_fade_degrees: float = 16.0
@export var mask_origin := Vector2i.ZERO

@export_group("Development preview")
@export_enum("07:00", "12:00", "16:00", "18:00", "21:00", "05:30") var preview_time_index: int = 0
@export var preview_now: bool = false:
	set(value):
		preview_now = false
		if value and is_node_ready():
			preview_time(preview_time_index)

@onready var clock: Node = get_node("/root/GameClock")
@onready var lighting: Node = get_parent()
@onready var mask: SubViewport = $Mask
@onready var casters: Node = $Mask/MapCoordinates/Casters

var sun_direction := Vector2.DOWN
var length_ratio: float = 0.4
var sun_opacity: float = 0.0
var sun_tint := Color(0.25, 0.31, 0.43)
var elevation_degrees: float = 0.0
var mask_redraw_count: int = 0
var _materials: Array[ShaderMaterial] = []
var _override_started_msec: int = -1
var _from_direction: Vector2
var _from_ratio: float
var _from_opacity: float
var _from_tint: Color
var _last_projection_msec: int = -1000
var _caster_models: Array[Dictionary] = []
var _last_view := Rect2()
var _map: Sprite2D

func _ready() -> void:
	mask.world_2d = World2D.new()
	$Mask/MapCoordinates.position = -Vector2(mask_origin)
	_map = lighting.get_node("Map")
	_materials.assign([lighting.get_node("Map").material, lighting.get_node("OcclusionUnderlay").material])
	for ground_material in _materials:
		ground_material.set_shader_parameter("prototype_shadow_mask", mask.get_texture())
		ground_material.set_shader_parameter("prototype_mask_origin", mask_origin)
	for caster: Node2D in casters.get_children():
		var vertices: PackedVector3Array = caster.get_meta("vertices")
		var bounds := Rect2(Vector2(vertices[0].x, vertices[0].y), Vector2.ZERO)
		var height: float = 0.0
		for vertex: Vector3 in vertices:
			bounds = bounds.expand(Vector2(vertex.x, vertex.y))
			height = maxf(height, vertex.z)
		_caster_models.append({"node": caster, "sun": caster.get_node("Sun"), "vertices": vertices,
			"bounds": bounds.grow(8.0), "height": height, "reach": float(caster.get_meta("maximum_reach", 0.0)),
			"last_slope": Vector2(INF, INF)})
	clock.time_overridden.connect(_on_time_overridden)
	_update_state()
	_update_projection()
	_apply_uniforms()

func sample_sun(minutes: float) -> Dictionary:
	var hours: float = fposmod(minutes, 1440.0) / 60.0
	var daylight: float = maxf(1.0, sunset_hour - sunrise_hour)
	var noon: float = (sunrise_hour + sunset_hour) * 0.5
	var day_progress: float = clampf((hours - sunrise_hour) / daylight, 0.0, 1.0)
	var elevation: float = sin(day_progress * PI) * peak_elevation_degrees
	if hours < sunrise_hour or hours > sunset_hour:
		elevation = 0.0
	# The sun crosses the north side of the map: westward shadows in the morning.
	var angle: float = TAU * (hours - noon) / 24.0
	var direction := Vector2(sin(angle), 0.6 + 0.4 * cos(angle)).normalized()
	var cotangent: float = 1.0 / maxf(tan(deg_to_rad(elevation)), 0.001)
	var ratio: float = maximum_length_ratio * cotangent / sqrt(maximum_length_ratio * maximum_length_ratio + cotangent * cotangent)
	var strength: float = smoothstep(0.0, horizon_fade_degrees, elevation)
	var tint: Color = Color(0.31, 0.34, 0.42).lerp(Color(0.22, 0.30, 0.43), clampf(elevation / peak_elevation_degrees, 0.0, 1.0))
	return {"direction": direction, "ratio": ratio, "opacity": maximum_sun_opacity * strength, "tint": tint, "elevation": elevation}

func _on_time_overridden(previous: float, current: float) -> void:
	var distance: float = minf(fposmod(current - previous, 1440.0), fposmod(previous - current, 1440.0))
	_override_started_msec = Time.get_ticks_msec() if distance >= 2.0 else -1
	_from_direction = sun_direction
	_from_ratio = length_ratio
	_from_opacity = sun_opacity
	_from_tint = sun_tint

func _process(_delta: float) -> void:
	if not prototype_enabled:
		return
	_update_state()
	_apply_uniforms()
	var now: int = Time.get_ticks_msec()
	var view: Rect2 = _source_view()
	var camera_moved: bool = view.position.distance_squared_to(_last_view.position) >= 4.0 or view.size != _last_view.size
	if camera_moved or _override_started_msec >= 0 or (sun_opacity > 0.00001 and now - _last_projection_msec >= 80):
		_update_projection()
		_last_projection_msec = now

func _update_state() -> void:
	var state: Dictionary = sample_sun(clock.get_minutes())
	sun_direction = state.direction
	length_ratio = state.ratio
	sun_opacity = state.opacity
	sun_tint = state.tint
	elevation_degrees = state.elevation
	if _override_started_msec >= 0:
		var duration: float = maxf(0.01, lighting.override_blend_seconds)
		var elapsed: float = float(Time.get_ticks_msec() - _override_started_msec) / 1000.0
		var weight: float = smoothstep(0.0, 1.0, minf(1.0, elapsed / duration))
		sun_direction = _from_direction.slerp(sun_direction, weight).normalized()
		length_ratio = lerpf(_from_ratio, length_ratio, weight)
		sun_opacity = lerpf(_from_opacity, sun_opacity, weight)
		sun_tint = _from_tint.lerp(sun_tint, weight)
		if elapsed >= duration:
			_override_started_msec = -1

func _source_view() -> Rect2:
	var inverse: Transform2D = _map.get_global_transform_with_canvas().affine_inverse()
	var viewport_size: Vector2 = _map.get_viewport_rect().size
	return Rect2(inverse * Vector2.ZERO, inverse * viewport_size - inverse * Vector2.ZERO).grow(16.0)

func _caster_slope(model: Dictionary) -> Vector2:
	var ratio: float = length_ratio
	# Limit tall wings smoothly before their casts span unrelated buildings.
	var limit: float = model.reach
	var length: float = ratio * model.height
	if limit > 0.0 and length > limit * 0.75:
		length = limit * 0.75 + limit * 0.25 * (1.0 - exp(-(length - limit * 0.75) / (limit * 0.25)))
		ratio = length / model.height
	return sun_direction * ratio

func _update_projection() -> void:
	var changed: bool = false
	var view: Rect2 = _source_view()
	_last_view = view
	for model: Dictionary in _caster_models:
		var caster: Node2D = model.node
		var slope: Vector2 = _caster_slope(model)
		var bounds: Rect2 = model.bounds
		var projected_bounds := Rect2(bounds.position + slope * model.height, bounds.size)
		var swept: Rect2 = bounds.merge(projected_bounds)
		swept.position += caster.position
		var in_view: bool = swept.intersects(view)
		if caster.visible != in_view:
			caster.visible = in_view
			changed = true
		var silhouette: Polygon2D = model.sun
		var sunlight: bool = sun_opacity > 0.00001
		if silhouette.visible != sunlight:
			silhouette.visible = sunlight
			changed = true
		if not in_view or not sunlight or slope.distance_to(model.last_slope) * model.height < 0.05:
			continue
		var vertices: PackedVector3Array = model.vertices
		var projected := PackedVector2Array()
		projected.resize(vertices.size())
		for index in range(vertices.size()):
			var vertex: Vector3 = vertices[index]
			projected[index] = (Vector2(vertex.x, vertex.y) + slope * vertex.z).round()
		model.last_slope = slope
		if projected != silhouette.polygon:
			silhouette.polygon = projected
			changed = true
	if changed or mask_redraw_count == 0:
		mask.render_target_update_mode = SubViewport.UPDATE_ONCE
		mask_redraw_count += 1

func _apply_uniforms() -> void:
	for ground_material in _materials:
		ground_material.set_shader_parameter("prototype_shadows_enabled", prototype_enabled)
		ground_material.set_shader_parameter("prototype_sun_opacity", sun_opacity)
		ground_material.set_shader_parameter("prototype_contact_opacity", contact_opacity)
		ground_material.set_shader_parameter("prototype_shadow_tint", sun_tint)

func preview_time(index: int) -> bool:
	if not OS.is_debug_build() or index < 0 or index >= 6:
		return false
	var minutes: int = [420, 720, 960, 1080, 1260, 330][index]
	return clock.set_time(floori(minutes / 60.0), minutes % 60)
