extends Node
## Focused runtime probes; additional actors and clock overrides exist only here.

@export var capture_directory: String = "user://actor_shadow_tests"
var checks: Array[Dictionary] = []
var timings: Array[Dictionary] = []
var extras: Array[Node2D] = []
var lab: Node
var player: CharacterBody2D
var shadow: Node
var sun: Node
var clock: Node

func _ready() -> void:
	_run.call_deferred()

func _check(value: bool, label: String) -> void:
	checks.append({"passed": value, "label": label})
	if not value:
		push_error("Actor shadow test: " + label)

func _capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	_check(get_viewport().get_texture().get_image().save_png(capture_directory.path_join(label + ".png")) == OK, "capture: " + label)

func _time(hour: int, minute: int = 0) -> void:
	clock.set_time(hour, minute)
	await get_tree().create_timer(0.8).timeout

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_directory))
	clock = get_node("/root/GameClock")
	clock.set_process(false)
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
		await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/gameplay/school_exterior_playable.tscn")
	await get_tree().scene_changed
	await get_tree().create_timer(0.3).timeout
	lab = get_tree().current_scene
	player = lab.get_node("Player")
	shadow = player.get_node("ActorShadow2D")
	sun = lab.get_node("SchoolExterior/SunShadowPrototype")
	player.position = Vector2(390,650)
	_check(shadow.receiver == sun, "shared Player automatically binds to School receiver")
	_check(shadow.mask_visual.get_parent() == sun.get_node("Mask/MapCoordinates"), "one existing mask receives actor proxy")
	_check(sun.casters.get_child_count() == 93, "93 environmental casters unchanged")
	_check(lab.get_node("SchoolExterior/Solids").find_children("*", "StaticBody2D", true, false).size() == 99, "99 barriers unchanged")
	_check(lab._objects.size() == 29 and lab.has_node("SchoolExterior/GroundFog/GroundField"), "foreground fading and fog retained")
	var ratios: Array[float] = []
	for entry: Array in [[7,"morning"], [12,"noon"], [16,"afternoon"], [18,"sunset"], [20,"evening"], [21,"night"], [5,"dawn"]]:
		await _time(entry[0], 30 if entry[1] == "dawn" else 0)
		ratios.append(sun.length_ratio)
		var expected: Dictionary = sun.sample_sun(clock.get_minutes())
		_check(sun.sun_direction.is_equal_approx(expected.direction) and is_equal_approx(sun.length_ratio, expected.ratio), "effective profile matches environment: " + entry[1])
		_check(shadow.contact.visible and shadow.mask_visual.visible, "contact retained: " + entry[1])
		_check(shadow.cast.visible == (sun.sun_opacity > 0.00001), "solar visibility: " + entry[1])
		if entry[0] == 7:
			_check(sun.sun_direction.x < 0, "morning cast westward")
		if entry[0] in [16,18]:
			_check(sun.sun_direction.x > 0, "afternoon/sunset cast eastward")
		if entry[1] == "dawn":
			_check(sun.sun_opacity > 0.0 and sun.sun_opacity < sun.maximum_sun_opacity, "05:30 solar shadow returns gradually")
		if entry[1] in ["morning", "noon", "sunset", "night"]:
			await _capture(entry[1])
	_check(ratios[0] > ratios[1] and ratios[3] > ratios[2], "noon shorter than morning; sunset longer than afternoon")
	await _time(7)
	var previous: Transform2D = shadow.cast.transform
	clock.set_time(18,0)
	await get_tree().process_frame
	_check(shadow.cast.transform.y.distance_to(previous.y) < 0.2, "override begins from displayed projection without snap")
	await get_tree().create_timer(0.2).timeout
	_check(sun._override_started_msec >= 0, "actor consumes active environment blend")
	clock.set_time(12,0)
	await get_tree().create_timer(0.8).timeout
	_check(sun.sun_direction.is_equal_approx(sun.sample_sun(720).direction), "latest override replaces obsolete blend")
	await _time(7)
	var start: Vector2 = player.position
	for direction: Vector2 in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2(1,1).normalized(), Vector2(-1,1).normalized(), Vector2(-1,-1).normalized(), Vector2(1,-1).normalized()]:
		player.position = start
		for action: String in ["ui_left","ui_right","ui_up","ui_down"]:
			Input.action_release(action)
		if direction.x > 0: Input.action_press("ui_right")
		if direction.x < 0: Input.action_press("ui_left")
		if direction.y > 0: Input.action_press("ui_down")
		if direction.y < 0: Input.action_press("ui_up")
		await get_tree().create_timer(0.22).timeout
		var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
		_check(player.position.distance_to(start) > 20 and is_equal_approx(player.velocity.length(),150), "actual normalized movement: " + str(direction))
		_check(shadow.cast.texture == sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame) and shadow.cast.flip_h == sprite.flip_h, "current frame and flip synchronized: " + str(direction))
		_check(shadow.contact.position.distance_to(sun.get_actor_shadow_map().to_local(player.global_position)) < 0.01, "contact anchored during movement: " + str(direction))
		if direction == Vector2.RIGHT:
			await _capture("walking")
	for action: String in ["ui_left","ui_right","ui_up","ui_down"]:
		Input.action_release(action)
	await get_tree().create_timer(0.1).timeout
	_check(player.get_node("AnimatedSprite2D").animation.begins_with("idle_"), "idle pose restored")
	player.position = start
	await RenderingServer.frame_post_draw
	var receiver_before: Image = sun.mask.get_texture().get_image()
	var first: Node2D = _spawn_actor(start + Vector2(70,0), true)
	await get_tree().create_timer(0.15).timeout
	var second_shadow: Node = first.get_node("ActorShadow2D")
	_check(second_shadow.cast.material != shadow.cast.material, "actor materials are independent")
	_check(second_shadow.cast.texture == first.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture(&"walk_right",0), "test actor uses independent pose")
	second_shadow.cast_strength = 0.3
	await get_tree().process_frame
	_check(shadow.cast_strength == 0.8, "one actor strength cannot mutate another")
	await _capture("multiple-actors")
	var proxy_count: int = sun.get_node("Mask/MapCoordinates").get_child_count()
	lab.remove_child(first)
	await get_tree().process_frame
	_check(sun.get_node("Mask/MapCoordinates").get_child_count() == proxy_count-1, "detached actor removes receiver proxy")
	lab.add_child(first)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(first.get_node("ActorShadow2D").receiver == sun and sun.get_node("Mask/MapCoordinates").get_child_count() == proxy_count, "same actor re-enters and rebinds")
	await RenderingServer.frame_post_draw
	var receiver_after: Image = sun.mask.get_texture().get_image()
	var ground_unchanged: bool = true
	for y in range(450,750,3):
		for x in range(250,500,3):
			ground_unchanged = ground_unchanged and receiver_before.get_pixel(x,y).b == receiver_after.get_pixel(x,y).b
	_check(ground_unchanged and receiver_after.get_pixel(300,850).b == 0, "actor coverage preserves receiver channel and roof exclusion")
	await _benchmark(2)
	for index in range(2,4):
		_spawn_actor(start + Vector2((index%4)*48-96,(index/4)*48-50), false)
	await get_tree().create_timer(0.3).timeout
	await _benchmark(4)
	for index in range(4,20):
		_spawn_actor(start + Vector2((index%4)*48-96,(index/4)*48-100), false)
	await get_tree().create_timer(0.3).timeout
	_check(get_tree().get_nodes_in_group("actor_shadow_receiver").size() == 1 and sun.get_node("Mask").get_child_count() == 1, "20 actors still share one environmental mask viewport")
	await _benchmark(20)
	for actor: Node2D in extras:
		actor.queue_free()
	await get_tree().process_frame
	_check(sun.get_node("Mask/MapCoordinates").get_child_count() == proxy_count-1, "all test actors clean up their proxies")
	await _benchmark(1)
	var failures: int = 0
	for check: Dictionary in checks:
		if not check.passed: failures += 1
	var output := FileAccess.open(capture_directory.path_join("results.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks.size(),"failures":failures,"details":checks,"performance":timings},"  "))
	print("ACTOR SHADOWS: ",checks.size()," checks, ",failures," failures")
	clock.set_process(true)
	get_tree().quit(0 if failures == 0 else 1)

func _spawn_actor(position: Vector2, walking: bool) -> Node2D:
	var actor: Node2D = load("res://scenes/player.tscn").instantiate()
	actor.position = position
	actor.collision_layer = 0
	actor.collision_mask = 0
	lab.add_child(actor)
	var visual: AnimatedSprite2D = actor.get_node("AnimatedSprite2D")
	visual.play(&"walk_right" if walking else &"idle_up")
	visual.pause()
	visual.frame = 0
	extras.append(actor)
	return actor

func _benchmark(count: int) -> void:
	var frames: int = 0
	var draws: float = 0.0
	var started: int = Time.get_ticks_msec()
	while Time.get_ticks_msec()-started < 2000:
		await get_tree().process_frame
		frames += 1
		draws += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	timings.append({"stationary_actors":count,"fps":frames*1000.0/(Time.get_ticks_msec()-started),"mean_draw_calls":draws/frames})
