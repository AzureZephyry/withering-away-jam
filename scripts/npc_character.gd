extends CharacterBody2D
## External callers supply movement; no player input or autonomous behavior.

@export_range(0.0, 300.0, 1.0) var movement_speed: float = 150.0
var movement_direction := Vector2.ZERO
var _activity_animation: StringName = &""
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func set_move_direction(direction: Vector2) -> void:
	movement_direction = direction.limit_length(1.0)
	if not movement_direction.is_zero_approx():
		_activity_animation = &""

func begin_activity(direction: Vector2, animation_name: StringName = &"") -> void:
	set_move_direction(Vector2.ZERO)
	_activity_animation = &""
	face_direction(direction)
	if animation_name != &"" and animated_sprite.sprite_frames.has_animation(animation_name):
		_activity_animation = animation_name
		animated_sprite.play(_activity_animation)

func end_activity() -> void:
	_activity_animation = &""
	animated_sprite.show_idle()

func face_direction(direction: Vector2) -> void:
	if not direction.is_zero_approx():
		animated_sprite.update_motion(direction, Vector2.ZERO)

func _physics_process(_delta: float) -> void:
	velocity = movement_direction * movement_speed
	var previous_position := global_position
	move_and_slide()
	if _activity_animation != &"" and movement_direction.is_zero_approx():
		animated_sprite.play(_activity_animation)
	else:
		animated_sprite.update_motion(movement_direction, global_position - previous_position)
