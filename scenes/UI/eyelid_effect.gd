extends CanvasLayer
## Open the eyes with a hesitant blink.
signal completed

@export var auto_start: bool = true
@export var free_on_finish: bool = true
## Temporary timing: 3.5 seconds with the default settings.
@export_range(0.0, 3.0, 0.05) var initial_delay_seconds: float = 0.15
@export_range(0.1, 8.0, 0.1) var playback_speed: float = 1.0

@onready var color_rect: ColorRect = $ColorRect
var is_playing: bool = false
var _tween: Tween

func _ready() -> void:
	color_rect.material.set_shader_parameter("open_amount", 0.0)
	if auto_start:
		play_wake_up_sequence()

func play_wake_up_sequence() -> bool:
	if is_playing:
		return false
	is_playing = true
	color_rect.material.set_shader_parameter("open_amount", 0.0)
	show()
	_tween = create_tween().set_speed_scale(playback_speed)
	_tween.tween_interval(initial_delay_seconds)
	_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 0.28, 1.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(0.30)
	_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(0.12)
	_tween.tween_property(color_rect, "material:shader_parameter/open_amount", 1.0, 1.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_finish)
	return true

func _finish() -> void:
	color_rect.material.set_shader_parameter("open_amount", 1.0)
	is_playing = false
	hide()
	completed.emit()
	if free_on_finish:
		queue_free()
