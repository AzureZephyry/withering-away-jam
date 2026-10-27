extends "res://scenes/tests/sanity_tests.gd"
## Run with Godot --headless --path . res://scenes/tests/scene02_tests.tscn.

const LABORATORY: String = "res://scenes/prototypes/camera_lab.tscn"
const NOTEBOOK: NodePath = ^"Bedroom/Decoration/Notebook/Interaction"

func _run() -> void:
	get_tree().current_scene = null
	SanityState.reset_session()
	GameState.reset_session()
	await _test_ordinary_interaction()
	await _test_focus_input_and_layout()
	await _test_focus_fallbacks()
	await _test_focus_cleanup()
	if "--scene02-objectives" in OS.get_cmdline_user_args():
		await _test_scene02_objective()
		await _test_preparation_orders()
	if "--scene02-objects" in OS.get_cmdline_user_args():
		await _test_scene02_objects()
	if "--scene02-door" in OS.get_cmdline_user_args():
		await _test_scene02_door()
		await _test_scene02_walking_route()
	await _test_focus_viewports()
	print("SCENE 02 TESTS: %d checks, %d failures" % [checks, failures])
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
		await get_tree().process_frame
	get_tree().quit(0 if failures == 0 else 1)

func _illustration(canvas: Vector2i, used: Rect2i) -> Texture2D:
	var image := Image.create(canvas.x, canvas.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	if used.has_area():
		image.fill_rect(used, Color(0.68, 0.75, 0.79))
	return ImageTexture.create_from_image(image)

func _laboratory(texture: Texture2D = null) -> Node:
	var room: Node = await _load_scene(LABORATORY)
	var target: Node = room.get_node(NOTEBOOK)
	target.focus_texture = texture
	room.get_node("Player").position = Vector2(400, 160)
	await get_tree().create_timer(0.12).timeout
	return room

func _controller(room: Node) -> Node:
	return room.get_node("OverworldInteraction")

func _focus(room: Node) -> Control:
	return room.get_node("OverworldInteraction/DialogueLayer/ObjectFocus")

func _open_environment(room: Node, key: Key = KEY_E) -> void:
	await _press(key)
	await get_tree().create_timer(0.35).timeout
	_check(_controller(room).dialogue_open, "environmental target opens through proximity and input")

func _finish_environment(room: Node) -> void:
	var controller: Node = _controller(room)
	var remaining: int = 12
	while controller.dialogue_open and remaining > 0:
		await _press(KEY_SPACE if remaining % 2 == 0 else KEY_E)
		remaining -= 1
	await get_tree().create_timer(0.35).timeout
	_check(not controller.dialogue_open and not controller._closing, "environmental conversation fully closes")

func _check_focus_layout(room: Node, label: String) -> void:
	var focus: Control = _focus(room)
	var safe: Control = focus.get_node("SafeArea")
	var panel: Control = _controller(room).panel
	var hud: Node = room.get_node("SanityHUD")
	var safe_rect: Rect2 = safe.get_global_rect()
	_check(focus.get_viewport_rect().encloses(safe_rect), label + ": image area stays in viewport")
	_check(not safe_rect.intersects(panel.get_global_rect()), label + ": image area clears dialogue")
	_check(not safe_rect.intersects(hud.frame.get_global_rect()), label + ": image area clears HUD")
	_check(safe_rect.has_area(), label + ": useful image area exists")
	var artwork: TextureRect = focus.get_node("SafeArea/Artwork")
	_check(safe_rect.encloses(artwork.get_global_rect()), label + ": illustration fits safe area")
	_check(is_equal_approx(artwork.size.aspect(), focus.visible_bounds.size.aspect()), label + ": illustration preserves visible aspect ratio")
	_check(artwork.get_global_rect().get_center().distance_to(safe_rect.get_center()) <= 1.5, label + ": illustration stays centered")
	_check(is_equal_approx(artwork.get_global_rect().get_center().x, focus.get_viewport_rect().size.x * 0.5), label + ": visible artwork is centered in the entire viewport")

func _test_ordinary_interaction() -> void:
	var room: Node = await _laboratory()
	var focus: Control = _focus(room)
	var controller: Node = _controller(room)
	_check(not focus.visible and focus.current_texture == null, "presenter starts hidden and empty")
	await _open_environment(room)
	_check(controller.line_index == 0, "opening press cannot advance first line")
	_check(not room.get_node("Player").is_physics_processing(), "ordinary dialogue retains movement lock")
	_check(not focus.visible and not focus.get_node("Dimmer").is_visible_in_tree(), "ordinary target has no focus or dimmer")
	await _finish_environment(room)
	_check(room.get_node(NOTEBOOK).completed_once, "ordinary interaction still completes")
	_check(room.get_node("Player").is_physics_processing(), "ordinary interaction restores movement")
	_check(SanityState.get_score() == 0, "ordinary interaction remains neutral")

func _test_focus_input_and_layout() -> void:
	var used := Rect2i(64, 96, 96, 144)
	var texture: Texture2D = _illustration(Vector2i(256, 320), used)
	var room: Node = await _laboratory(texture)
	var controller: Node = _controller(room)
	var focus: Control = _focus(room)
	var player: CharacterBody2D = room.get_node("Player")
	await _open_environment(room, KEY_SPACE)
	_check(focus.visible and controller.panel.visible, "focus appears with actual visible panel")
	_check(focus.current_texture == texture, "presenter uses target illustration")
	_check(focus.visible_bounds == Rect2(used), "transparent canvas does not replace visible alpha bounds")
	_check(not focus.is_processing_input() and not focus.is_processing_unhandled_key_input(), "presenter owns no interaction input")
	_check(not player.is_physics_processing(), "focus conversation uses existing movement lock")
	var start: Vector2 = player.position
	_key(KEY_D)
	await get_tree().create_timer(0.08).timeout
	_release(KEY_D)
	_check(player.position.is_equal_approx(start), "movement input cannot move player during focus")
	await get_tree().process_frame
	_key(KEY_E)
	_key(KEY_E)
	_key(KEY_SPACE, true)
	await get_tree().process_frame
	_check(controller.line_index == 0 and not controller.body.is_typing, "duplicate and echo input reveal without advancing")
	_key(KEY_E)
	await get_tree().process_frame
	_check(controller.line_index == 0, "held input cannot advance another line")
	_release(KEY_E)
	_release(KEY_SPACE)
	await _press(KEY_SPACE)
	_check(controller.line_index == 1, "fresh alternate key advances exactly one line")
	controller._set_panel_edge(false)
	await get_tree().create_timer(0.3).timeout
	_check(not room.get_node("SanityHUD").at_bottom, "bottom dialogue keeps HUD upper-right")
	_check_focus_layout(room, "bottom dialogue")
	controller._set_panel_edge(true)
	await get_tree().create_timer(0.3).timeout
	_check(room.get_node("SanityHUD").at_bottom, "top dialogue moves HUD lower-right")
	_check_focus_layout(room, "top dialogue")
	controller.panel.hide()
	_check(not focus.visible, "focus hides immediately with panel")
	controller.panel.show()
	await get_tree().process_frame
	_check(focus.visible, "focus follows panel visibility when conversation remains active")
	await _finish_environment(room)
	_check(not focus.visible and focus.current_texture == null, "finished focus clears image and visibility")
	_check(player.is_physics_processing() and SanityState.get_score() == 0, "focus restores movement without Sanity changes")

func _test_focus_fallbacks() -> void:
	var transparent: Texture2D = _illustration(Vector2i(32, 32), Rect2i())
	var room: Node = await _laboratory(transparent)
	await _open_environment(room)
	_check(not _focus(room).visible, "fully transparent illustration falls back to ordinary dialogue")
	_check(not _focus(room).get_node("Dimmer").is_visible_in_tree(), "transparent fallback has no dimmer")
	await _finish_environment(room)
	_check(room.get_node(NOTEBOOK).completed_once, "missing visible artwork cannot block completion")
	var used := Rect2i(24, 48, 208, 80)
	var landscape: Texture2D = _illustration(Vector2i(256, 160), used)
	room = await _laboratory(landscape)
	await _open_environment(room)
	_check(_focus(room).visible and _focus(room).visible_bounds == Rect2(used), "padded landscape illustration is supported")
	_check_focus_layout(room, "landscape")
	await _finish_environment(room)

func _test_focus_cleanup() -> void:
	var texture: Texture2D = _illustration(Vector2i(96, 96), Rect2i(8, 8, 80, 80))
	var room: Node = await _laboratory(texture)
	var target: Node = room.get_node(NOTEBOOK)
	# Deliberately impossible bounds exercise the existing failed-placement path.
	target.visual_bounds = Rect2(1024, 1024, 16, 16)
	await _press(KEY_E)
	await get_tree().create_timer(0.35).timeout
	_check(not _controller(room).dialogue_open and not _focus(room).visible, "failed placement cannot leave focus visible")
	_check(not target.completed_once and room.get_node("Player").is_physics_processing(), "failed placement is unsuccessful and restores movement")
	_check(_focus(room).current_texture == null, "failed placement clears prepared illustration")
	room = await _laboratory(texture)
	await _open_environment(room)
	room.get_node(NOTEBOOK).queue_free()
	await get_tree().create_timer(0.35).timeout
	_check(not _focus(room).visible, "deleted target leaves no orphaned illustration")
	_check(not _controller(room).dialogue_open and room.get_node("Player").is_physics_processing(), "deleted target closes safely and restores movement")
	room = await _laboratory(texture)
	await _open_environment(room)
	room = await _laboratory()
	_check(not _focus(room).visible and _focus(room).current_texture == null, "scene replacement starts with clean focus state")
	_check(room.get_node("Player").is_physics_processing(), "scene replacement does not retain movement lock")
	await _test_target_disappears_during_open(texture)

func _test_target_disappears_during_open(texture: Texture2D) -> void:
	var room: Node = await _laboratory(texture)
	var controller: Node = _controller(room)
	var target: Node = room.get_node(NOTEBOOK)
	var result: Dictionary = {"count": 0, "success": true}
	controller.interaction_finished.connect(func(_finished: Node, completed: bool):
		result["count"] += 1
		result["success"] = completed)
	controller.interaction_started.connect(func(started: Node):
		started.get_parent().remove_child(started), CONNECT_ONE_SHOT)
	await _press(KEY_E)
	await get_tree().create_timer(0.1).timeout
	_check(not controller.dialogue_open and not _focus(room).visible, "synchronous target removal cannot continue opening")
	_check(result["count"] == 1 and not result["success"] and not target.completed_once, "synchronous removal reports unsuccessful completion once")
	_check(room.get_node("Player").is_physics_processing(), "synchronous removal restores movement")
	target.free()
	room = await _laboratory(texture)
	controller = _controller(room)
	target = room.get_node(NOTEBOOK)
	var camera: Camera2D = room.get_node("Camera2D")
	var home: Vector2 = camera.position
	camera.limit_enabled = false
	# An in-memory oversized target requires a legal pan before the panel can show.
	target.visual_bounds = Rect2(-200, -80, 400, 200)
	var pan_result: Dictionary = {"count": 0, "success": true}
	controller.interaction_finished.connect(func(_finished: Node, completed: bool):
		pan_result["count"] += 1
		pan_result["success"] = completed)
	await _press(KEY_E)
	_check(controller._layout_busy and controller._camera_shifted, "fixture begins camera placement before showing dialogue")
	_check(not _focus(room).visible, "focus stays hidden during initial camera pan")
	target.queue_free()
	await get_tree().create_timer(0.4).timeout
	_check(not controller.dialogue_open and not controller._closing and not _focus(room).visible, "target deletion during pan leaves no active presentation")
	_check(room.get_node("Player").is_physics_processing() and camera.position.is_equal_approx(home), "pan interruption restores movement and camera")
	_check(pan_result["count"] == 1 and not pan_result["success"], "pan interruption cannot report successful completion")

func _test_scene02_objective() -> void:
	SanityState.reset_session()
	GameState.reset_session()
	var story: Node = await _load_scene(BEDROOM)
	var flow: Node = story.get_node("Scene02")
	_check(not flow.objective.visible, "objective is hidden during Bedroom introduction")
	_check(_marker_states(flow) == [false, false, false] and not flow.exit_objective_marker.visible, "markers are hidden during introduction")
	_check(not GameState.get_flag("bedroom_schedule_checked"), "schedule starts unchecked")
	await _reach_choices(story)
	_check(not flow.objective.visible, "objective stays hidden during phone choices")
	_check(_marker_states(flow) == [false, false, false], "phone presentation keeps markers hidden")
	await _press(KEY_SPACE)
	await _finish_story(story, 1)
	await get_tree().create_timer(0.12).timeout
	_check(flow.mode == &"exploration" and flow.objective.visible, "first introduction completion enables objective")
	_check(flow.objective.text.begins_with("Get ready for your first day."), "first objective presents first-day preparations")
	_check(_checklist_states(flow) == [false, false, false], "fresh checklist shows all three unfinished preparations")
	_check(_marker_states(flow) == [true, true, true] and not flow.exit_objective_marker.visible, "fresh exploration marks required objects, not the door")
	_check(not GameState.get_flag("bedroom_schedule_checked"), "finishing introduction does not finish schedule")
	var laboratory: Node = story.get_node("Laboratory")
	var controller: Node = _controller(laboratory)
	var notebook: Node = laboratory.get_node(NOTEBOOK)
	var card: Node = laboratory.get_node("Bedroom/Props/Dresser/Card/Interaction")
	var notifications: Dictionary = {"schedule": 0}
	var observe: Callable = func(flag: String, _value: bool):
		if flag == "bedroom_schedule_checked":
			notifications["schedule"] += 1
	GameState.flag_changed.connect(observe)
	controller.interaction_finished.emit(card, true)
	_check(not GameState.get_flag("bedroom_schedule_checked") and GameState.get_flag("bedroom_id_checked"), "card completion changes only its own requirement")
	controller.interaction_finished.emit(notebook, false)
	_check(not GameState.get_flag("bedroom_schedule_checked"), "unsuccessful notebook completion cannot satisfy objective")
	story.player.position = Vector2(400, 160)
	await get_tree().create_timer(0.12).timeout
	await _open_environment(laboratory)
	_check(not flow.objective.visible, "objective hides during notebook dialogue and focus")
	_check(_marker_states(flow) == [false, false, false] and not flow.exit_objective_marker.visible, "all markers hide during examination")
	_check(_focus(laboratory).visible and notebook.focus_texture != null, "story notebook shows assigned planner illustration")
	_check(not GameState.get_flag("bedroom_schedule_checked"), "opening planner does not complete objective")
	_check(controller.body.text == "New semester. New schedule.", "first planner line preserves provisional screenplay")
	await _press(KEY_E)
	_check(not GameState.get_flag("bedroom_schedule_checked"), "revealing first line does not complete objective")
	await _press(KEY_SPACE)
	_check(controller.body.text == "Shouldn't be too different.", "second planner line preserves provisional screenplay")
	_check(not GameState.get_flag("bedroom_schedule_checked"), "reaching final line does not complete objective")
	await _finish_environment(laboratory)
	_check(GameState.get_flag("bedroom_schedule_checked"), "successful notebook completion records session flag")
	_check(flow.objective.visible and flow.objective.text.contains("Check your schedule.") and _checklist_states(flow)[0], "completed schedule updates its checklist row")
	_check(not flow.preparations_complete() and not flow.exit_objective_marker.visible, "two completed objects cannot enable departure")
	_check(notifications["schedule"] == 1, "objective progression emits one state change")
	await _open_environment(laboratory, KEY_SPACE)
	_check(controller.body.text == "I already checked it." and notebook.lines.size() == 1, "repeat planner uses short provisional response")
	_check(not flow.objective.visible, "repeat inspection still hides objective")
	await _finish_environment(laboratory)
	_check(GameState.get_flag("bedroom_schedule_checked") and notifications["schedule"] == 1, "repeat inspection cannot duplicate progression")
	_check(SanityState.get_score() == 0, "planner remains neutral")
	GameState.flag_changed.disconnect(observe)
	story = await _load_scene(BEDROOM)
	flow = story.get_node("Scene02")
	await get_tree().create_timer(0.12).timeout
	_check(story.stage == &"exploration" and flow.mode == &"exploration", "completed introduction re-entry initializes exploration")
	_check(not story.phone.visible and story.player.is_physics_processing(), "re-entry skips phone and preserves movement")
	_check(flow.objective.visible and flow.objective.text.contains("Check your schedule.") and _checklist_states(flow)[0], "re-entry reads completed schedule without introduction signal")
	_check(story.get_node("Laboratory/Bedroom/Decoration/Notebook/Interaction").lines == PackedStringArray(["I already checked it."]), "re-entry restores repeat notebook text")
	await _test_scene02_incomplete_notebook()

func _test_scene02_incomplete_notebook() -> void:
	GameState.set_flag("bedroom_schedule_checked", false)
	var story: Node = await _load_scene(BEDROOM)
	var flow: Node = story.get_node("Scene02")
	var laboratory: Node = story.get_node("Laboratory")
	var notebook: Node = laboratory.get_node(NOTEBOOK)
	story.player.position = Vector2(400, 160)
	await get_tree().create_timer(0.12).timeout
	# This expected warning proves placement failure cannot satisfy progression.
	notebook.visual_bounds = Rect2(1024, 1024, 16, 16)
	await _press(KEY_E)
	await get_tree().create_timer(0.35).timeout
	_check(not GameState.get_flag("bedroom_schedule_checked"), "actual failed planner placement cannot complete objective")
	_check(flow.objective.visible and flow.objective.text.contains("Check your schedule.") and not _checklist_states(flow)[0], "failed inspection restores unchanged objective")
	story = await _load_scene(BEDROOM)
	laboratory = story.get_node("Laboratory")
	story.player.position = Vector2(400, 160)
	await get_tree().create_timer(0.12).timeout
	await _open_environment(laboratory)
	await _press(KEY_E)
	_check(not GameState.get_flag("bedroom_schedule_checked"), "partially read planner remains incomplete")
	story = await _load_scene(BEDROOM)
	flow = story.get_node("Scene02")
	await get_tree().create_timer(0.12).timeout
	_check(not GameState.get_flag("bedroom_schedule_checked"), "scene exit during planner cannot record completion")
	_check(flow.objective.visible and flow.objective.text.contains("Check your schedule.") and not _checklist_states(flow)[0], "incomplete planner re-entry retains required objective")
	_check(story.player.is_physics_processing() and not story.interactions.dialogue_open, "incomplete planner re-entry restores clean movement and interaction")
	_check(SanityState.get_score() == 0, "failed and partial inspections remain neutral")
	laboratory = story.get_node("Laboratory")
	laboratory.get_node(NOTEBOOK).focus_texture = null
	story.player.position = Vector2(400, 160)
	await get_tree().create_timer(0.12).timeout
	await _open_environment(laboratory, KEY_SPACE)
	_check(not _focus(laboratory).visible, "planner remains usable without illustration")
	await _finish_environment(laboratory)
	_check(GameState.get_flag("bedroom_schedule_checked"), "missing illustration cannot block schedule progression")

func _test_scene02_objects() -> void:
	SanityState.reset_session()
	GameState.reset_session()
	GameState.set_flag("bedroom_intro_completed", true)
	var story: Node = await _load_scene(BEDROOM)
	var laboratory: Node = story.get_node("Laboratory")
	var controller: Node = _controller(laboratory)
	var card: Node = laboratory.get_node("Bedroom/Props/Dresser/Card/Interaction")
	_check(card.repeat_mode == OverworldInteractable.Repeat.KEYPRESS, "Student ID uses existing repeatable interaction policy")
	_check(card.lines == PackedStringArray(["Albert James Dimapilis.", "Bachelor of Science in Computer Science.", "First year.", "Sounds official."]), "Student ID contains only approved provisional identity lines")
	_check(card.speakers == PackedStringArray(["Albert", "Albert", "Albert", "Albert"]), "Student ID lines identify Albert")
	story.player.position = Vector2(96, 300)
	await get_tree().create_timer(0.12).timeout
	await _open_environment(laboratory)
	_check(controller.active == card and _focus(laboratory).visible, "existing dresser card opens Student ID focus")
	_check(not story.get_node("Scene02").objective.visible, "ID inspection hides objective")
	_check_focus_layout(laboratory, "Student ID")
	await _finish_environment(laboratory)
	_check(card.completed_once, "Student ID completes normally")
	_check(GameState.get_flag("bedroom_id_checked") and not GameState.get_flag("bedroom_schedule_checked") and SanityState.get_score() == 0, "Student ID completes only its own requirement and stays neutral")
	await _open_environment(laboratory, KEY_SPACE)
	_check(controller.active == card and _focus(laboratory).visible, "completed Student ID remains inspectable with Object Focus")
	await _finish_environment(laboratory)
	story = await _load_scene(BEDROOM)
	laboratory = story.get_node("Laboratory")
	card = laboratory.get_node("Bedroom/Props/Dresser/Card/Interaction")
	story.player.position = Vector2(96, 300)
	await get_tree().create_timer(0.12).timeout
	_check(card.available() and GameState.get_flag("bedroom_id_checked"), "ID remains available on re-entry while session progress persists")
	var medal: Node2D = laboratory.get_node("Bedroom/Decoration/GraduationMedal")
	var target: Node = medal.get_node("Interaction")
	_check(medal.position == Vector2(176, 8), "medal uses isolated upper-wall placement")
	_check(medal.find_children("*", "CollisionShape2D", true, false).is_empty(), "medal adds no blocking collision")
	_check(target.lines == PackedStringArray(["I could've left this at home.", "Whatever."]), "medal preserves provisional screenplay")
	_check(target.speakers == PackedStringArray(["Albert", "Albert"]), "medal uses Albert speaker")
	story.player.position = Vector2(186, 140)
	await get_tree().create_timer(0.12).timeout
	_check(not target.in_range, "medal starts outside interaction radius")
	await _press(KEY_E)
	_check(not _controller(laboratory).dialogue_open, "medal cannot activate outside proximity")
	_key(KEY_W)
	await get_tree().create_timer(0.4).timeout
	_release(KEY_W)
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(story.player.position.y < 92.0 and is_equal_approx(story.player.position.x, 186.0), "player can walk through existing clear route to medal")
	_check(target.in_range, "walked approach reaches medal proximity")
	await _open_environment(laboratory, KEY_SPACE)
	_check(_controller(laboratory).active == target and _focus(laboratory).visible, "medal opens through existing environmental controller")
	_check_focus_layout(laboratory, "graduation medal")
	await _finish_environment(laboratory)
	_check(target.completed_once and not _controller(laboratory).dialogue_open, "medal closes without automatic reopening")
	await _open_environment(laboratory)
	_check(_controller(laboratory).active == target, "medal can be deliberately re-inspected with fresh press")
	await _finish_environment(laboratory)
	_check(SanityState.get_score() == 0 and GameState.get_flag("bedroom_medal_checked") and not GameState.get_flag("bedroom_schedule_checked"), "medal updates only its own requirement and stays neutral")
	_check(story.get_node("Scene02").objective.visible and story.get_node("Scene02").objective.text.contains("Check your schedule.") and not _checklist_states(story.get_node("Scene02"))[0], "remaining schedule is still required")

func _door_press(key: Key) -> void:
	await _press(key)
	await get_tree().physics_frame
	await get_tree().process_frame

func _release_confirm_keys() -> void:
	for key: Key in [KEY_E, KEY_SPACE, KEY_ENTER]:
		_release(key)
	await get_tree().physics_frame
	await get_tree().process_frame

func _test_scene02_door() -> void:
	GameState.reset_session()
	GameState.set_flag("bedroom_intro_completed", true)
	SanityState.reset_session()
	SanityState.apply_effect(1)
	var story: Node = await _load_scene(BEDROOM)
	var flow: Node = story.get_node("Scene02")
	var laboratory: Node = story.get_node("Laboratory")
	var camera: Camera2D = laboratory.get_node("Camera2D")
	var camera_home: Vector2 = camera.position
	var player: CharacterBody2D = story.player
	player.position = Vector2(416, 288)
	await get_tree().create_timer(0.12).timeout
	await _door_press(KEY_E)
	_check(flow.mode == &"exploration", "door cannot activate outside proximity")
	player.position = Vector2(464, 304)
	await get_tree().create_timer(0.12).timeout
	await get_tree().process_frame
	_key(KEY_E)
	_key(KEY_SPACE)
	_key(KEY_ENTER)
	await get_tree().process_frame
	_check(flow.mode == &"reminder", "early departure opens reminder without same-frame confirmation")
	_check(flow.door_panel.visible and flow.door_body.text == "Finish getting ready before leaving.", "early departure uses accurate preparation reminder")
	_check(not player.is_physics_processing() and story.interactions.suspended, "door reminder owns movement and environmental suspension")
	_check(not flow.objective.visible and not story.interactions.prompt.visible, "door reminder hides objective and normal prompt")
	_check(not _focus(laboratory).visible, "door does not use Object Focus")
	_key(KEY_E, true)
	_key(KEY_SPACE, true)
	await get_tree().create_timer(0.12).timeout
	_check(flow.mode == &"reminder", "held and echo opening inputs cannot dismiss reminder")
	await _release_confirm_keys()
	var remaining: int = 4
	while flow.mode == &"reminder" and remaining > 0:
		await _door_press(KEY_SPACE if remaining % 2 == 0 else KEY_E)
		remaining -= 1
	await get_tree().create_timer(0.12).timeout
	_check(flow.mode == &"exploration" and player.is_physics_processing(), "early reminder closes back to movement")
	_check(not story.interactions.suspended and flow.objective.visible, "early reminder restores interactions and objective")
	_check(not GameState.get_flag("bedroom_schedule_checked") and SanityState.get_score() == 1, "early departure cannot progress or penalize")
	_check(flow.endpoint_count == 0 and camera.position.is_equal_approx(camera_home), "early departure leaves endpoint and camera unchanged")
	GameState.set_flag("bedroom_schedule_checked", true)
	GameState.set_flag("bedroom_id_checked", true)
	GameState.set_flag("bedroom_medal_checked", true)
	await get_tree().process_frame
	await _door_press(KEY_SPACE)
	_check(flow.mode == &"door" and flow.selected_choice == 1, "all preparations open decision with safe Not Yet default")
	_check(flow.door_body.text == "Would you like to leave your dorm?", "door retains screenplay question")
	_check(not flow.objective.visible and not player.is_physics_processing(), "decision hides guidance and locks movement")
	_check(_marker_states(flow) == [false, false, false] and not flow.exit_objective_marker.visible, "door decision hides objective markers")
	await get_tree().create_timer(0.3).timeout
	_check(laboratory.get_node("SanityHUD").at_bottom, "top door panel moves Sanity HUD below")
	_check(not flow.door_panel.get_global_rect().intersects(laboratory.get_node("SanityHUD").frame.get_global_rect()), "door panel clears actual HUD")
	if flow.door_body.is_typing:
		await _door_press(KEY_E)
	_check(flow.mode == &"door" and flow.endpoint_count == 0, "revealing door question does not confirm it")
	var before: Vector2 = player.position
	_key(KEY_SPACE)
	_key(KEY_E)
	_key(KEY_ENTER)
	await get_tree().process_frame
	_check(flow.mode == &"exploration", "distinct confirmation chooses default Not Yet")
	_key(KEY_SPACE, true)
	_key(KEY_E)
	await get_tree().create_timer(0.15).timeout
	_check(flow.mode == &"exploration" and flow.endpoint_count == 0, "held dismissal cannot immediately reopen door")
	_check(player.is_physics_processing() and not story.interactions.suspended, "Not Yet restores prior processing and interaction state")
	_check(player.position.is_equal_approx(before), "choice confirmation does not move player")
	await _release_confirm_keys()
	await get_tree().create_timer(0.15).timeout
	_check(flow.objective.visible and flow.objective.text == "Head out for school.", "Not Yet restores completed objective guidance")
	_check(flow.exit_objective_marker.visible, "Not Yet restores the exit marker")
	await _door_press(KEY_E)
	_check(flow.mode == &"door" and flow.selected_choice == 1, "door can deliberately reopen and resets safe choice")
	await _door_press(KEY_W)
	_check(flow.selected_choice == 0 and not player.is_physics_processing(), "W selects Yes without moving Albert")
	if flow.door_body.is_typing:
		await _door_press(KEY_SPACE)
	_check(flow.mode == &"door", "selected Yes still waits for distinct confirmation")
	var completion: Dictionary = {"count": 0}
	flow.scene_completed.connect(func(): completion["count"] += 1)
	_key(KEY_SPACE)
	_key(KEY_E)
	_key(KEY_ENTER)
	_key(KEY_SPACE, true)
	await get_tree().create_timer(0.9).timeout
	var school: Node = get_tree().current_scene
	_check(school.scene_file_path == "res://scenes/story/school_exterior_story.tscn", "Yes fades into School Exterior")
	_check(completion["count"] == 1, "duplicate confirmation produces one scene completion")
	if school.scene_file_path != "res://scenes/story/school_exterior_story.tscn":
		return
	var arrival_player: CharacterBody2D = school.get_node("Laboratory/Player")
	_check(arrival_player.global_position == school.get_node("SchoolArrivalSpawn").global_position, "story uses named sidewalk arrival marker")
	_check(not school.arrival_active and arrival_player.is_physics_processing(), "arrival fade restores movement")
	for flag_name: String in ["bedroom_intro_completed", "bedroom_schedule_checked", "bedroom_id_checked", "bedroom_medal_checked"]:
		_check(GameState.get_flag(flag_name), "departure preserves " + flag_name)
	_check(SanityState.get_score() == 1, "departure preserves Sanity score")
	_check(not is_instance_valid(story) and school.find_children("Endpoint", "Control", true, false).is_empty(), "old Bedroom and Return to Bedroom endpoint are absent")
	_check(school.find_children("*", "CharacterBody2D", true, false).size() == 1 and school.find_children("*", "Camera2D", true, false).size() == 1, "one Player and one camera after departure")
	_key(KEY_ENTER, true)
	await get_tree().process_frame
	_check(get_tree().current_scene == school, "held confirmation cannot trigger another transition")
	await _release_confirm_keys()

func _stop_walk_input() -> void:
	for action: StringName in [&"ui_left", &"ui_right", &"ui_up", &"ui_down"]:
		Input.action_release(action)

func _walk_to(player: CharacterBody2D, destination: Vector2, label: String) -> void:
	var limit: int = ceili(player.position.distance_to(destination) / 150.0 * Engine.physics_ticks_per_second) + 60
	while player.position.distance_to(destination) > 3.0 and limit > 0:
		_stop_walk_input()
		var delta: Vector2 = destination - player.position
		var action: StringName
		if absf(delta.x) > 2.0:
			action = &"ui_right" if delta.x > 0.0 else &"ui_left"
		else:
			action = &"ui_down" if delta.y > 0.0 else &"ui_up"
		Input.action_press(action)
		await get_tree().physics_frame
		await get_tree().process_frame
		limit -= 1
	_stop_walk_input()
	await get_tree().physics_frame
	await get_tree().process_frame
	_check(player.position.distance_to(destination) <= 4.0, "walking route reaches " + label)

func _test_scene02_walking_route() -> void:
	GameState.reset_session()
	GameState.set_flag("bedroom_intro_completed", true)
	SanityState.reset_session()
	var story: Node = await _load_scene(BEDROOM)
	var player: CharacterBody2D = story.player
	var laboratory: Node = story.get_node("Laboratory")
	var camera: Camera2D = laboratory.get_node("Camera2D")
	var camera_home: Vector2 = camera.position
	# Only the initial placement is direct; every route leg uses normal movement.
	player.position = Vector2(144, 176)
	Input.action_press(&"ui_left")
	await get_tree().create_timer(0.3).timeout
	_stop_walk_input()
	_check(player.position.x >= 123.5 and player.position.x < 144.0, "existing bed collision blocks attempted movement")
	await _walk_to(player, Vector2(144, 176), "bedside start")
	await _walk_to(player, Vector2(144, 252), "clear central aisle")
	await _walk_to(player, Vector2(400, 252), "desk approach aisle")
	await _walk_to(player, Vector2(400, 160), "notebook")
	_check(laboratory.get_node(NOTEBOOK).in_range, "walked notebook route reaches required interaction")
	await _walk_to(player, Vector2(400, 252), "central aisle from notebook")
	await _walk_to(player, Vector2(96, 252), "dresser approach aisle")
	await _walk_to(player, Vector2(96, 300), "Student ID")
	_check(laboratory.get_node("Bedroom/Props/Dresser/Card/Interaction").in_range, "walked ID route reaches optional interaction")
	await _walk_to(player, Vector2(96, 252), "central aisle from ID")
	await _walk_to(player, Vector2(186, 252), "medal approach aisle")
	await _walk_to(player, Vector2(186, 80), "graduation medal")
	_check(laboratory.get_node("Bedroom/Decoration/GraduationMedal/Interaction").in_range, "walked medal route reaches optional interaction")
	await _walk_to(player, Vector2(186, 252), "central aisle from medal")
	await _walk_to(player, Vector2(400, 252), "door approach aisle")
	await _walk_to(player, Vector2(400, 304), "door approach")
	await _walk_to(player, Vector2(464, 304), "door")
	_check(player.global_position.distance_to(Vector2(504, 288)) <= 72.0, "walked route reaches door proximity")
	Input.action_press(&"ui_right")
	await get_tree().create_timer(0.4).timeout
	_stop_walk_input()
	_check(player.position.x <= 484.5 and player.position.x > 470.0, "existing DoorStop blocks passage through right wall")
	_check(camera.position.is_equal_approx(camera_home), "full walking route preserves fixed Bedroom camera")
	_check(player.is_physics_processing() and not story.interactions.dialogue_open, "walking route leaves ordinary exploration functional")

func _marker_states(flow: Node) -> Array[bool]:
	var states: Array[bool] = []
	for marker: Node2D in flow.objective_markers:
		states.append(marker.is_visible_in_tree())
	return states

func _checklist_states(flow: Node) -> Array[bool]:
	var states: Array[bool] = []
	for checkbox: Panel in flow.checklist_boxes:
		states.append(checkbox.get_node("Fill").visible)
	return states

func _test_preparation_orders() -> void:
	var orders: Array = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
	var flags: Array[String] = ["bedroom_schedule_checked", "bedroom_id_checked", "bedroom_medal_checked"]
	var approaches: Array[Vector2] = [Vector2(400, 160), Vector2(96, 300), Vector2(186, 80)]
	for order: Array in orders:
		GameState.reset_session()
		GameState.set_flag("bedroom_intro_completed", true)
		SanityState.reset_session()
		var story: Node = await _load_scene(BEDROOM)
		var flow: Node = story.get_node("Scene02")
		var laboratory: Node = story.get_node("Laboratory")
		var changes: Dictionary = {"bedroom_schedule_checked": 0, "bedroom_id_checked": 0, "bedroom_medal_checked": 0}
		var observe: Callable = func(flag_name: String, _value: bool):
			if changes.has(flag_name):
				changes[flag_name] += 1
		GameState.flag_changed.connect(observe)
		var done: Array[bool] = [false, false, false]
		_check(_marker_states(flow) == [true, true, true], "order %s starts with all three markers" % str(order))
		for index in range(3):
			var marker: Node2D = flow.objective_markers[index]
			var bounds: Rect2 = marker.get_global_transform_with_canvas() * Rect2(-4, -3, 8, 6)
			_check(get_viewport().get_visible_rect().encloses(bounds), "required marker %d is not clipped" % index)
			_check(not bounds.intersects(flow.objective.get_global_rect()), "required marker %d clears checklist" % index)
		for step in range(3):
			var index: int = order[step]
			story.player.position = approaches[index]
			await get_tree().create_timer(0.12).timeout
			await _open_environment(laboratory)
			_check(_controller(laboratory).active == flow.preparation_targets[index], "order %s activates chosen object %d" % [str(order), index])
			_check(not GameState.get_flag(flags[index]), "activation alone leaves chosen requirement pending")
			_check(_marker_states(flow) == [false, false, false], "examination hides all markers")
			await _finish_environment(laboratory)
			done[index] = true
			for other in range(3):
				_check(GameState.get_flag(flags[other]) == done[other], "order %s completes only examined object %d" % [str(order), other])
			var expected_markers: Array[bool] = [not done[0], not done[1], not done[2]]
			_check(_marker_states(flow) == expected_markers, "markers track individual successful completions")
			_check(flow.preparations_complete() == (step == 2), "departure requires all three in order %s" % str(order))
			_check(flow.exit_objective_marker.visible == (step == 2), "exit marker waits for all three requirements")
			if step < 2:
				_check(flow.objective.text.begins_with("Get ready for your first day.") and _checklist_states(flow).count(true) == step + 1, "checklist distinguishes completed and remaining tasks")
				story.player.position = Vector2(464, 304)
				await get_tree().create_timer(0.12).timeout
				await _door_press(KEY_E)
				_check(flow.mode == &"reminder" and flow.door_body.text == "Finish getting ready before leaving.", "partial preparations cannot open departure choice")
				if flow.door_body.is_typing:
					await _door_press(KEY_SPACE)
				await _door_press(KEY_E)
				await get_tree().create_timer(0.12).timeout
				_check(_marker_states(flow) == expected_markers and not flow.exit_objective_marker.visible, "early reminder restores remaining markers")
			else:
				_check(flow.objective.text == "Head out for school.", "all six orders reach departure guidance")
		for index in range(3):
			story.player.position = approaches[index]
			await get_tree().create_timer(0.12).timeout
			await _open_environment(laboratory)
			_check(_controller(laboratory).active == flow.preparation_targets[index] and _focus(laboratory).visible, "completed object %d remains examinable" % index)
			await _finish_environment(laboratory)
		_check(changes.values() == [1, 1, 1], "re-examination produces no duplicate progression")
		GameState.flag_changed.disconnect(observe)
		story = await _load_scene(BEDROOM)
		flow = story.get_node("Scene02")
		_check(flow.preparations_complete() and flow.objective.text == "Head out for school.", "all completed preparations survive room re-entry")
		_check(_marker_states(flow) == [false, false, false] and flow.exit_objective_marker.visible, "re-entry restores only exit marker")
		_check(SanityState.get_score() == 0 and not story.phone.visible, "preparation orders neither affect Sanity nor replay phone")
	await _test_other_incomplete_objects()

func _test_other_incomplete_objects() -> void:
	var paths: Array[NodePath] = [^"Bedroom/Props/Dresser/Card/Interaction", ^"Bedroom/Decoration/GraduationMedal/Interaction"]
	var positions: Array[Vector2] = [Vector2(96, 300), Vector2(186, 80)]
	var flags: Array[String] = ["bedroom_id_checked", "bedroom_medal_checked"]
	for index in range(2):
		GameState.reset_session()
		GameState.set_flag("bedroom_intro_completed", true)
		var story: Node = await _load_scene(BEDROOM)
		var laboratory: Node = story.get_node("Laboratory")
		var target: Node = laboratory.get_node(paths[index])
		story.player.position = positions[index]
		await get_tree().create_timer(0.12).timeout
		# Deliberately impossible framing must not record examination success.
		target.visual_bounds = Rect2(1024, 1024, 16, 16)
		await _press(KEY_E)
		await get_tree().create_timer(0.35).timeout
		_check(not GameState.get_flag(flags[index]), "failed object %d leaves its requirement pending" % index)
		_check(_marker_states(story.get_node("Scene02")) == [true, true, true], "failed examination restores required-object markers")
		story = await _load_scene(BEDROOM)
		laboratory = story.get_node("Laboratory")
		story.player.position = positions[index]
		await get_tree().create_timer(0.12).timeout
		await _open_environment(laboratory)
		await _press(KEY_SPACE)
		_check(not GameState.get_flag(flags[index]), "partial object dialogue cannot record success")
		story = await _load_scene(BEDROOM)
		_check(not GameState.get_flag(flags[index]) and _marker_states(story.get_node("Scene02")) == [true, true, true], "interrupted examination leaves progress pending on re-entry")

func _test_focus_viewports() -> void:
	var window: Window = get_window()
	var original_size: Vector2i = window.content_scale_size
	var sizes: Array[Vector2i] = [Vector2i(1280, 960), Vector2i(960, 720), Vector2i(1600, 900)]
	var names: Array[String] = ["planner_focus.svg", "student_id_focus.svg", "graduation_medal_focus.svg"]
	for asset_name in names:
		var texture: Texture2D = load("res://assets/placeholders/scene02/" + asset_name)
		var room: Node = await _laboratory(texture)
		await _open_environment(room)
		var controller: Node = _controller(room)
		# Isolate UI resizing from the world's separate dialogue-framing decision.
		controller.set_process(false)
		for viewport_size in sizes:
			window.content_scale_size = viewport_size
			await get_tree().create_timer(0.1).timeout
			var centers: Array[float] = []
			for at_top: bool in [false, true]:
				controller._set_panel_edge(at_top)
				await get_tree().create_timer(0.3).timeout
				var focus: Control = _focus(room)
				_check(focus.get_viewport_rect().size.is_equal_approx(Vector2(viewport_size)), "UI test uses actual logical viewport %s" % str(viewport_size))
				_check(focus.visible, "%s remains visible at %s" % [asset_name, str(viewport_size)])
				_check_focus_layout(room, asset_name + " " + str(viewport_size))
				centers.append(focus.get_node("SafeArea/Artwork").get_global_rect().get_center().y)
			_check(centers[0] < centers[1], "illustration moves vertically, never sideways, with dialogue")
		window.content_scale_size = original_size
		await get_tree().create_timer(0.15).timeout
		controller._set_panel_edge(false)
		controller.set_process(true)
		await _finish_environment(room)
	# An unusably small viewport keeps dialogue and HUD ahead of the illustration.
	var small_room: Node = await _laboratory(_illustration(Vector2i(64, 64), Rect2i(0, 0, 64, 64)))
	await _open_environment(small_room)
	var small_controller: Node = _controller(small_room)
	small_controller.set_process(false)
	window.content_scale_size = Vector2i(320, 240)
	await get_tree().create_timer(0.3).timeout
	small_controller._set_panel_edge(false)
	await get_tree().create_timer(0.3).timeout
	_check(not _focus(small_room).visible and small_controller.panel.visible, "impossible small layout hides artwork, not dialogue")
	window.content_scale_size = original_size
	await get_tree().create_timer(0.15).timeout
	small_controller._set_panel_edge(false)
	small_controller.set_process(true)
	await _finish_environment(small_room)
