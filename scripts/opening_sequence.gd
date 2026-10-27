extends Control
## Scene 1 only. User-transcribed pages 1–3; provisional, not finalized narrative.
## Speaker identity is separate from world artwork. No overworld Player or page 4.

signal sequence_finished
signal event_cued(event_id: StringName)
signal audio_cued(cue_id: StringName)
signal character_revealed(character: String)

const Typewriter = preload("res://scripts/text_type.gd")
const EyelidEffect = preload("res://scenes/UI/eyelid_effect.gd")
const DialoguePanel = preload("res://scripts/dialogue_panel.gd")

const STEPS: Array[Dictionary] = [
	{"kind": "line", "presentation": "center", "speaker": "???", "text": "There you are…."},
	{"kind": "line", "presentation": "center", "speaker": "???", "text": "You've always been here.."},
	{"kind": "event", "id": &"eyes_open"},
	{"kind": "line", "presentation": "dream", "speaker": "Albert", "text": "..."},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "Don't look so lost, nobody who's done what you have done gets lost.."},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "Top of everything"},
	{"kind": "event", "id": &"screen_glitches"},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "always ahead of everyone around you."},
	{"kind": "event", "id": &"glitch"},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "Don't think I didn't see all of it."},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "You're such an inspiration to everyone….. As well as a source of envy.."},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "As long as you stay like this."},
	{"kind": "event", "id": &"garden_slowly_glitches"},
	{"kind": "line", "presentation": "dream", "speaker": "???", "text": "I will love you…"},
	{"kind": "event", "id": &"wake_0630"},
	{"kind": "event", "id": &"complete"},
]

@export_group("Provisional technical timing — not final visual direction")
@export_range(0.0, 4.0, 0.1) var opening_delay_seconds: float = 2.0
@export_range(0.15, 0.25, 0.01) var first_glitch_seconds: float = 0.20
@export_range(0.3, 0.5, 0.01) var second_glitch_seconds: float = 0.40
@export_range(0.2, 2.0, 0.05) var deterioration_intro_seconds: float = 0.80
@export_range(0.2, 4.0, 0.05) var deterioration_tail_seconds: float = 2.0
@export_range(0.1, 1.0, 0.05) var waking_fade_out_seconds: float = 0.45
@export_range(0.05, 1.0, 0.05) var waking_black_hold_seconds: float = 0.20

@onready var centered_text: Typewriter = $Label
@onready var dialogue_panel: DialoguePanel = $DialoguePanel
@onready var body_text: Typewriter = $DialoguePanel/Margin/Content/Body
@onready var eyelids: EyelidEffect = $Eyelids
@onready var glitch_placeholder: Control = $GlitchPlaceholder
@onready var deterioration: ColorRect = $GlitchPlaceholder/Deterioration
@onready var awakening_fade: ColorRect = $AwakeningFade

var step_index: int = -1
var phase: StringName = &"initial_black"
var is_busy: bool = true
var is_complete: bool = false
var _instability_tween: Tween

func _ready() -> void:
	if not body_text.advance_requested.is_connected(_on_advance_requested):
		body_text.advance_requested.connect(_on_advance_requested)
	if not body_text.character_revealed.is_connected(_on_character_revealed):
		body_text.character_revealed.connect(_on_character_revealed)
	dialogue_panel.world = DialoguePanel.World.DREAM
	_clear_text()
	$BlackBackdrop.show()
	$WhitePlaceholder.show()
	eyelids.hide()
	glitch_placeholder.hide()
	awakening_fade.hide()
	await get_tree().create_timer(opening_delay_seconds).timeout
	is_busy = false
	await _advance_step()

func _on_advance_requested() -> void:
	if is_busy or is_complete:
		return
	audio_cued.emit(&"dialogue_advance")
	await _advance_step()

func _advance_step() -> void:
	if is_busy or is_complete:
		return
	is_busy = true
	_clear_text()
	step_index += 1
	while step_index < STEPS.size():
		var step: Dictionary = STEPS[step_index]
		if step["kind"] == "line":
			_present(step)
			is_busy = false
			return
		await _run_event(step["id"])
		if is_complete:
			return
		step_index += 1

func _present(step: Dictionary) -> void:
	var presentation: String = step["presentation"]
	if presentation == "center":
		phase = &"black_text"
		centered_text.present_line(step["text"])
		return
	phase = &"dream_dialogue" if presentation == "dream" else &"awakening_dialogue"

	dialogue_panel.speaker_name = step["speaker"]
	dialogue_panel.show()
	body_text.present_line(step["text"])

func _clear_text() -> void:
	centered_text.clear_line()
	body_text.clear_line()
	dialogue_panel.hide()

func _run_event(event_id: StringName) -> void:
	event_cued.emit(event_id)
	match event_id:
		&"eyes_open":
			phase = &"eyes_opening"
			audio_cued.emit(&"solemn_music_start")
			# The overlay is closed before black is removed: no white flash.
			eyelids.play_wake_up_sequence()
			$BlackBackdrop.hide()
			await eyelids.completed
		&"screen_glitches", &"glitch":
			phase = &"glitch_cue"
			audio_cued.emit(event_id)
			await _play_glitch(event_id == &"glitch")
		&"garden_slowly_glitches":
			phase = &"dream_deterioration"
			audio_cued.emit(&"gradual_glitch")
			glitch_placeholder.modulate.a = 1.0
			glitch_placeholder.show()
			$GlitchPlaceholder/Wash.hide()
			$GlitchPlaceholder/UpperBand.hide()
			$GlitchPlaceholder/LowerBand.hide()
			deterioration.show()
			deterioration.material.set_shader_parameter("amount", 0.0)
			# The onset is mandatory. The remainder runs behind the final line.
			_instability_tween = create_tween()
			_instability_tween.tween_property(deterioration, "material:shader_parameter/amount", 0.4, deterioration_intro_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await _instability_tween.finished
			_instability_tween = create_tween()
			_instability_tween.tween_property(deterioration, "material:shader_parameter/amount", 1.0, deterioration_tail_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		&"wake_0630":
			phase = &"dream_fade_out"
			audio_cued.emit(&"awakening_transition")
			awakening_fade.modulate.a = 0.0
			awakening_fade.show()
			await _fade_to(1.0, waking_fade_out_seconds)
			phase = &"awakening_black"
			if is_instance_valid(_instability_tween):
				_instability_tween.kill()
			glitch_placeholder.hide()
			audio_cued.emit(&"solemn_music_stop")
			audio_cued.emit(&"alarm_0630")
			await get_tree().create_timer(waking_black_hold_seconds).timeout
			# Bedroom owns the reveal and waking dialogue after this black hold.
		&"complete":
			phase = &"complete"
			is_complete = true
			is_busy = false
			sequence_finished.emit()

func _on_sequence_finished() -> void:
	# Let the awaited sequence callbacks unwind before replacing their scene.
	_enter_bedroom.call_deferred()

func _enter_bedroom() -> void:
	if not is_inside_tree():
		return
	var error: Error = get_tree().change_scene_to_file("res://scenes/story/bedroom_story.tscn")
	if error != OK:
		push_error("Could not open the story Bedroom: %s" % error_string(error))

func _play_glitch(second: bool) -> void:
	$GlitchPlaceholder/Wash.show()
	$GlitchPlaceholder/UpperBand.show()
	$GlitchPlaceholder/LowerBand.show()
	deterioration.hide()
	glitch_placeholder.modulate.a = 0.0
	glitch_placeholder.show()
	var duration: float = second_glitch_seconds if second else first_glitch_seconds
	var peak: float = 0.85 if second else 0.35
	var cue: Tween = create_tween()
	cue.tween_method(_glitch_envelope.bind(peak, second), 0.0, 1.0, duration)
	await cue.finished
	glitch_placeholder.hide()

func _glitch_envelope(progress: float, peak: float, drift: bool) -> void:
	# One smooth pulse, never a train of flashes.
	glitch_placeholder.modulate.a = sin(PI * progress) * peak
	var shift: float = progress * 0.03 if drift else 0.0
	$GlitchPlaceholder/UpperBand.anchor_top = 0.32 + shift
	$GlitchPlaceholder/UpperBand.anchor_bottom = 0.34 + shift
	$GlitchPlaceholder/LowerBand.anchor_top = 0.68 - shift
	$GlitchPlaceholder/LowerBand.anchor_bottom = 0.70 - shift

func _fade_to(alpha: float, duration: float) -> void:
	var fade: Tween = create_tween()
	fade.tween_property(awakening_fade, "modulate:a", alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade.finished


func _on_character_revealed(character: String) -> void:
	character_revealed.emit(character)
