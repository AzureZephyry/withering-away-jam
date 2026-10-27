extends Node
## Run with Godot --headless --path . res://scenes/tests/sanity_tests.tscn.

const State = preload("res://scripts/sanity_state.gd")
const HUD = preload("res://scripts/sanity_hud.gd")
const BEDROOM: String = "res://scenes/story/bedroom_story.tscn"

var checks: int = 0
var failures: int = 0
var events: Array[String] = []
var observations_valid: bool = true

func _ready() -> void:
	_run.call_deferred()

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("Sanity test: " + label)

func _run() -> void:
	get_tree().current_scene = null
	_check(SanityState.get_score() == 0, "fresh process starts at zero")
	_check(SanityState.get_stage() == State.Stage.SANE, "fresh process starts sane")
	if "--fresh-session-probe" not in OS.get_cmdline_user_args():
		_test_foundation()
		await _test_hud_and_lifecycle()
		await _test_phone_branches()
		await _test_main_flow()
	print("SANITY TESTS: %d checks, %d failures" % [checks, failures])
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
		await get_tree().process_frame
	get_tree().quit(0 if failures == 0 else 1)

func _test_foundation() -> void:
	var state := State.new()
	state.score_changed.connect(func(previous: int, current: int):
		events.append("score:%d>%d" % [previous, current])
		observations_valid = observations_valid and state.get_score() == current
		observations_valid = observations_valid and state.is_failed() == (current == State.MAX_SCORE)
		observations_valid = observations_valid and not state.apply_effect(-1) and not state.reset_session())
	state.stage_changed.connect(func(previous: State.Stage, current: State.Stage):
		events.append("stage:%d>%d" % [previous, current])
		observations_valid = observations_valid and state.get_stage() == current)
	state.game_over.connect(func(): events.append("failure"))
	_check(state.apply_effect(0), "neutral accepted")
	_check(state.apply_effect(-1), "restorative at zero accepted")
	_check(state.get_score() == 0 and events.is_empty(), "unchanged score is silent")
	for invalid: Variant in [-2, 2, 100, -100, 1.0, -1.0, true, false, "1", null, Vector2.ZERO]:
		_check(not state.apply_effect(invalid), "invalid effect rejected: " + str(invalid))
		_check(state.get_score() == 0 and events.is_empty(), "invalid request cannot mutate")
	var expected_stages: Array[int] = [1, 1, 2, 2, 3, 3, 0]
	for score in range(1, State.MAX_SCORE + 1):
		events.clear()
		_check(state.apply_effect(1), "destabilizing accepted")
		_check(state.get_score() == score, "exact increment")
		_check(state.get_stage() == expected_stages[score], "stage at score %d" % score)
		var expected: Array[String] = ["score:%d>%d" % [score - 1, score]]
		if score in [2, 4]:
			expected.append("stage:%d>%d" % [expected_stages[score - 1], expected_stages[score]])
		if score == State.MAX_SCORE:
			expected.append("failure")
		_check(events == expected, "notification order at score %d" % score)
	events.clear()
	for effect in [-1, 0, 1]:
		_check(not state.apply_effect(effect), "failure rejects ordinary effects")
	_check(state.get_score() == State.MAX_SCORE and events.is_empty(), "failure stays terminal and silent")
	_check(state.reset_session(), "reset accepted after failure")
	_check(events == ["score:6>0", "stage:0>1"], "reset order and playable-stage return")
	_check(not state.is_failed() and state.get_stage() == State.Stage.SANE, "reset clears failure")
	events.clear()
	state.reset_session()
	_check(events.is_empty(), "reset at zero silent")
	for step in range(5):
		state.apply_effect(1)
	for score in range(4, -1, -1):
		events.clear()
		_check(state.apply_effect(-1), "recovery accepted")
		_check(state.get_score() == score and state.get_stage() == expected_stages[score], "recovery score/stage")
		var expected: Array[String] = ["score:%d>%d" % [score + 1, score]]
		if score in [3, 1]:
			expected.append("stage:%d>%d" % [expected_stages[score + 1], expected_stages[score]])
		_check(events == expected, "recovery signals")
	_check(observations_valid, "signal callbacks observe final state; reentrant writes rejected")
	events.clear()
	for step in range(State.MAX_SCORE):
		state.apply_effect(1)
	_check(events.count("failure") == 1, "new failure after reset emits once again")
	state.free()

func _load_scene(path: String) -> Node:
	_check(get_tree().change_scene_to_file(path) == OK, "scene load requested: " + path)
	await get_tree().scene_changed
	await get_tree().process_frame
	await get_tree().process_frame
	return get_tree().current_scene

func _test_hud_and_lifecycle() -> void:
	SanityState.reset_session()
	var room: Node = await _load_scene("res://scenes/gameplay/bedroom_playable.tscn")
	var hud: Node = room.get_node("SanityHUD")
	_check(get_tree().get_nodes_in_group("sanity_hud").size() == 1, "one Bedroom HUD")
	_check(not hud.at_bottom, "default upper-right")
	for score in range(State.MAX_SCORE + 1):
		_check(hud.artwork.texture.resource_path == HUD.TEXTURES[score].resource_path, "HUD texture at %d" % score)
		_check(hud.artwork.mouse_filter == Control.MOUSE_FILTER_IGNORE, "HUD ignores input")
		if score < State.MAX_SCORE:
			SanityState.apply_effect(1)
	var zero_artwork: AtlasTexture = hud.artwork.texture as AtlasTexture
	_check(zero_artwork != null and zero_artwork.atlas.resource_path.ends_with("sanity_00.png"), "final zero-bar artwork loads")
	SanityState.reset_session()
	for step in range(4):
		SanityState.apply_effect(1)
	SanityState.apply_effect(-1)
	_check(hud.artwork.texture.resource_path.ends_with("sanity_03.png"), "HUD follows recovery")
	var panel: Control = room.get_node("OverworldInteraction/DialogueLayer/DialoguePanel")
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_bottom = 400.0
	panel.show()
	await get_tree().create_timer(0.3).timeout
	_check(hud.at_bottom and hud.frame.position.y > hud.screen.size.y * 0.5, "actual top panel moves combined HUD down")
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_bottom = -40.0
	await get_tree().create_timer(0.3).timeout
	_check(not hud.at_bottom, "visible bottom panel returns HUD up")
	panel.hide()
	await get_tree().process_frame
	_check(not hud.at_bottom, "closed panel restores default")
	room = await _load_scene("res://scenes/prototypes/garden_camera_lab.tscn")
	_check(SanityState.get_score() == 3, "score survives ordinary scene replacement")
	_check(get_tree().get_nodes_in_group("sanity_hud").size() == 1, "one Garden HUD, old HUD freed")
	_check(room.get_node("SanityHUD").artwork.texture.resource_path.ends_with("sanity_03.png"), "new HUD reads current state")
	room.get_node("Player").global_position = Vector2(1024, 650)
	await get_tree().create_timer(0.4).timeout
	_check(room.dialogue_open and not room.player.is_physics_processing(), "Lily proximity opens dialogue and locks movement")
	var garden_panel: Control = room.get_node("DialogueLayer/DialoguePanel")
	var garden_hud: Node = room.get_node("SanityHUD")
	_check(garden_hud.at_bottom == (garden_panel.get_global_rect().get_center().y < garden_hud.screen.size.y * 0.5), "HUD follows actual Garden dialogue placement")
	for step in range(6):
		await _press(KEY_E if step % 2 == 0 else KEY_SPACE)
	await get_tree().create_timer(0.4).timeout
	_check(not room.dialogue_open and room.player.is_physics_processing(), "Lily closes and restores movement")
	_check(SanityState.get_score() == 3 and not garden_hud.at_bottom, "Lily remains neutral and HUD returns up")
	room.player.global_position = Vector2(1024, 704)
	await get_tree().create_timer(0.05).timeout
	room.player.global_position = Vector2(1024, 500)
	await get_tree().create_timer(0.4).timeout
	_check(room.dialogue_open and SanityState.get_score() == 3, "Lily re-entry repetition stays neutral")
	_check(garden_hud.at_bottom and garden_panel.get_global_rect().get_center().y < 480.0, "north approach places real Garden panel top and HUD bottom")
	for step in range(6):
		await _press(KEY_E)
	await get_tree().create_timer(0.4).timeout
	room = await _load_scene("res://scenes/prototypes/school_camera_lab.tscn")
	_check(SanityState.get_score() == 3 and get_tree().get_nodes_in_group("sanity_hud").size() == 1, "School preserves score without duplicate HUD")

func _key(code: Key, echo: bool = false) -> void:
	var press := InputEventKey.new()
	press.physical_keycode = code
	press.keycode = code
	press.pressed = true
	press.echo = echo
	Input.parse_input_event(press)

func _release(code: Key) -> void:
	var release := InputEventKey.new()
	release.physical_keycode = code
	release.keycode = code
	Input.parse_input_event(release)

func _press(code: Key) -> void:
	await get_tree().process_frame
	_key(code)
	await get_tree().process_frame
	_release(code)
	await get_tree().process_frame

func _reach_choices(story: Node) -> void:
	await get_tree().create_timer(0.4).timeout
	for step in range(6):
		await _press(KEY_E)
	await get_tree().create_timer(0.4).timeout
	await _press(KEY_SPACE)
	await _press(KEY_SPACE)
	for step in range(3):
		await _press(KEY_E)
	_check(story.stage == &"phone" and story.phone.is_choosing(), "waking/reaction/phone reaches choices")

func _finish_story(story: Node, branch: int) -> void:
	var limit: int = 25
	while story.stage != &"exploration" and limit > 0:
		await _press(KEY_E)
		limit -= 1
	_check(story.stage == &"exploration" and story.selected_branch == branch, "phone branch and reflection finish")
	_check(GameState.get_flag("bedroom_intro_completed") == true, "completion flag after final reflection")
	_check(story.player.is_physics_processing() and not story.interactions.suspended, "exploration control restored")

func _test_phone_branches() -> void:
	for branch in [1, 2, 3]:
		SanityState.reset_session()
		GameState.reset_session()
		var story: Node = await _load_scene(BEDROOM)
		_check(not story.player.is_physics_processing() and story.interactions.suspended, "introduction locks movement/interactions")
		await _reach_choices(story)
		_check(SanityState.get_score() == 0 and not GameState.get_flag("bedroom_intro_completed"), "highlight/advance has no consequence or completion")
		for step in range(branch - 1):
			await _press(KEY_S)
		_check(story.phone.selected_choice == branch - 1, "visible option order matches branch")
		await get_tree().process_frame
		_key(KEY_SPACE)
		_key(KEY_ENTER)
		_key(KEY_SPACE, true)
		await get_tree().process_frame
		var expected: int = 1 if branch == 3 else 0
		_check(SanityState.get_score() == expected and story.phone.branch == branch, "single committed phone consequence")
		await get_tree().process_frame
		_key(KEY_SPACE, true)
		_release(KEY_SPACE)
		_release(KEY_ENTER)
		await get_tree().process_frame
		story.phone.choice_committed.emit(branch)
		_check(SanityState.get_score() == expected, "duplicate commit callback ignored")
		_check(story.get_node("Laboratory/SanityHUD").artwork.texture.resource_path.ends_with("sanity_05.png" if branch == 3 else "sanity_06.png"), "phone consequence immediately reaches HUD")
		await _finish_story(story, branch)
		_check(SanityState.get_score() == expected, "finishing branch cannot repeat consequence")
		story = await _load_scene(BEDROOM)
		_check(story.stage == &"exploration" and SanityState.get_score() == expected, "completed re-entry skips phone without reapplying")
		if branch == 3:
			story.player.position = Vector2(440, 150)
			await get_tree().create_timer(0.1).timeout
			await _press(KEY_E)
			await get_tree().create_timer(0.4).timeout
			_check(story.interactions.dialogue_open and not story.player.is_physics_processing(), "Bedroom manual interaction still locks movement")
			for step in range(4):
				await _press(KEY_SPACE)
			await get_tree().create_timer(0.4).timeout
			_check(not story.interactions.dialogue_open and story.player.is_physics_processing(), "Bedroom interaction restores movement")
			_check(SanityState.get_score() == 1, "Bedroom environmental dialogue has no new consequence")

func _test_main_flow() -> void:
	SanityState.reset_session()
	GameState.reset_session()
	var dream: Node = await _load_scene(ProjectSettings.get_setting("application/run/main_scene"))
	_check(get_tree().get_nodes_in_group("sanity_hud").is_empty(), "Dream has no gameplay HUD")
	_check(dream.is_busy and dream.phase == &"initial_black", "normal startup retains delay")
	_check(dream.body_text.advance_requested.is_connected(dream._on_advance_requested), "Dream runtime signal repair retained")
	await get_tree().create_timer(dream.opening_delay_seconds + 0.1).timeout
	var presses: int = 0
	var phases: Dictionary = {}
	while is_instance_valid(dream) and get_tree().current_scene == dream and presses < 400:
		phases[dream.phase] = true
		await _press(KEY_E if presses % 2 == 0 else KEY_SPACE)
		await get_tree().create_timer(0.05).timeout
		presses += 1
	_check(get_tree().current_scene != dream and get_tree().current_scene.scene_file_path == BEDROOM, "complete normal Dream-to-Bedroom handoff")
	_check(phases.has(&"black_text") and phases.has(&"dream_dialogue"), "black and Dream dialogue progress")
	_check(phases.has(&"eyes_opening") and phases.has(&"glitch_cue") and phases.has(&"dream_deterioration"), "timed opening effects retained")
	_check(SanityState.get_score() == 0 and get_tree().get_nodes_in_group("sanity_hud").size() == 1, "handoff preserves initial score and one HUD")
