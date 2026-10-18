extends CharacterBody2D
 
 
const SPEED = 150.0
const JUMP_VELOCITY = -400.0
 
@onready var animated_sprite = $AnimatedSprite2D
 
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
 
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.play("Walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("Idle")
 
	move_and_slide()
