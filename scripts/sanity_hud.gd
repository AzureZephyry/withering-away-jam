extends CanvasLayer
## One combined image; dialogue geometry determines which corner is clear.

const State = preload("res://scripts/sanity_state.gd")
const TEXTURES: Array[Texture2D] = [
	preload("res://assets/ui/sanity/sanity_06.png"),
	preload("res://assets/ui/sanity/sanity_05.png"),
	preload("res://assets/ui/sanity/sanity_04.png"),
	preload("res://assets/ui/sanity/sanity_03.png"),
	preload("res://assets/ui/sanity/sanity_02.png"),
	preload("res://assets/ui/sanity/sanity_01.png"),
	preload("res://assets/ui/sanity/sanity_00_display.tres"),
]

@export var margin: float = 24.0
@export var display_size: Vector2 = Vector2(426, 136)
@export_range(0.05, 0.3, 0.01) var corner_fade_seconds: float = 0.10

@export_group("Development preview")
@export var preview_zero_sanity: bool = false:
	set(value):
		preview_zero_sanity = value and OS.is_debug_build()
		if is_node_ready():
			_update_artwork(SanityState.get_score())

@onready var screen: Control = $Screen
@onready var frame: Control = $Screen/Frame
@onready var artwork: TextureRect = $Screen/Frame/Artwork

var at_bottom: bool = false
var _panels: Array[Control] = []
var _placement_queued: bool = false
var _corner_tween: Tween
var _feedback_tween: Tween

func _ready() -> void:
	SanityState.score_changed.connect(_on_score_changed)
	SanityState.stage_changed.connect(_on_stage_changed)
	SanityState.game_over.connect(_on_game_over)
	screen.resized.connect(_queue_placement)
	_update_artwork(SanityState.get_score())
	_layout_corner(false)
	# Story panels finish entering after the instanced laboratory's HUD is ready.
	_bind_panels.call_deferred()

func _update_artwork(score: int) -> void:
	# Preview changes only the image; it never writes to the session score.
	var shown_score: int = State.MAX_SCORE if preview_zero_sanity and OS.is_debug_build() else score
	artwork.texture = TEXTURES[shown_score]

func _bind_panels() -> void:
	for node in get_tree().get_nodes_in_group("dialogue_panels"):
		var panel: Control = node as Control
		if panel != null and panel.get_viewport() == get_viewport():
			_panels.append(panel)
			panel.visibility_changed.connect(_queue_placement)
			panel.item_rect_changed.connect(_queue_placement)
	_queue_placement()

func _queue_placement() -> void:
	if _placement_queued:
		return
	_placement_queued = true
	_update_placement.call_deferred()

func _update_placement() -> void:
	_placement_queued = false
	var top_dialogue: bool = false
	for panel in _panels:
		if is_instance_valid(panel) and panel.is_visible_in_tree():
			if panel.get_global_rect().get_center().y < screen.size.y * 0.5:
				top_dialogue = true
	_layout_corner(top_dialogue)

func _layout_corner(bottom: bool) -> void:
	var changed: bool = at_bottom != bottom
	at_bottom = bottom
	var ratio: float = minf(1.0, maxf(1.0, screen.size.x - margin * 2.0) / display_size.x)
	frame.size = display_size * ratio
	var target := Vector2(screen.size.x - margin - frame.size.x,
		screen.size.y - margin - frame.size.y if bottom else margin)
	if is_instance_valid(_corner_tween):
		_corner_tween.kill()
	if not changed:
		frame.position = target
		frame.modulate.a = 1.0
		return
	_corner_tween = create_tween()
	_corner_tween.tween_property(frame, "modulate:a", 0.0, corner_fade_seconds)
	_corner_tween.tween_callback(func(): frame.position = target)
	_corner_tween.tween_property(frame, "modulate:a", 1.0, corner_fade_seconds)

func _on_score_changed(_previous: int, current: int) -> void:
	_update_artwork(current)
	_pulse(false)

func _on_stage_changed(_previous: State.Stage, _current: State.Stage) -> void:
	_pulse(true)

func _on_game_over() -> void:
	_pulse(true)

func _pulse(major: bool) -> void:
	if is_instance_valid(_feedback_tween):
		_feedback_tween.kill()
	# One dark pulse, with a longer recovery at a major threshold. No flashing loop.
	artwork.self_modulate = Color(0.48, 0.40, 0.43) if major else Color(0.72, 0.64, 0.67)
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(artwork, "self_modulate", Color.WHITE, 0.42 if major else 0.24)

func _exit_tree() -> void:
	if is_instance_valid(_corner_tween):
		_corner_tween.kill()
	if is_instance_valid(_feedback_tween):
		_feedback_tween.kill()
