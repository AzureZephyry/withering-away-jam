extends CharacterBody2D
 
const SPEED = 150.0
 
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var position_before: Vector2 = global_position

	if direction != Vector2.ZERO:
		velocity = direction * SPEED

	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
	animated_sprite.update_motion(direction, global_position - position_before)
