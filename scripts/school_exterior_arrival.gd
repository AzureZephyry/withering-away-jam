extends Node2D
## Reveal the existing School Exterior after placing Albert on its sidewalk.

@export_range(0.0, 1.0, 0.05) var fade_seconds: float = 0.35

@onready var player: CharacterBody2D = $Laboratory/Player
@onready var arrival_spawn: Marker2D = $SchoolArrivalSpawn
@onready var camera: Camera2D = $Laboratory/Player/Camera2D
@onready var fade: ColorRect = $ArrivalLayer/Fade

var arrival_active: bool = true
var _movement_was_processing: bool = true
var _fade_tween: Tween

func _ready() -> void:
	_movement_was_processing = player.is_physics_processing()
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.global_position = arrival_spawn.global_position
	player.get_node("AnimatedSprite2D").show_idle()
	camera.reset_smoothing()
	camera.force_update_scroll()
	# Keep placement and the first camera update behind the saved black overlay.
	await get_tree().process_frame
	_fade_tween = create_tween()
	_fade_tween.tween_property(fade, "color:a", 0.0, fade_seconds)
	_fade_tween.tween_callback(_finish_arrival)

func _finish_arrival() -> void:
	if not arrival_active:
		return
	arrival_active = false
	fade.hide()
	player.velocity = Vector2.ZERO
	player.set_physics_process(_movement_was_processing)

func _exit_tree() -> void:
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
