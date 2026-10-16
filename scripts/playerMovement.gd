extends CharacterBody2D
 
const SPEED = 150.0
 
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction * SPEED

		if abs(direction.x) > abs(direction.y):
			animated_sprite.play("Walk")
			animated_sprite.flip_h = direction.x < 0
		elif direction.y < 0:
			animated_sprite.play("Up")
		else:
			animated_sprite.play("Down")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		animated_sprite.play("Idle")

	move_and_slide()
