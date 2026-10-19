extends AnimatedSprite2D
## Direction and animation only; the Player keeps control of movement.

const POSES: Array[StringName] = [
	&"right", &"down_right", &"down", &"down_right",
	&"right", &"up_right", &"up", &"up_right",
]

var facing_sector: int = 2

func update_motion(input_direction: Vector2, displacement: Vector2) -> void:
	var has_input: bool = input_direction.length_squared() > 0.0001
	if has_input:
		facing_sector = posmod(roundi(input_direction.angle() / (PI / 4.0)), 8)
	# Face the requested direction, but idle when collision stops all movement.
	_play_state(has_input and displacement.length_squared() > 0.0001)

func show_idle() -> void:
	_play_state(false)

func _play_state(walking: bool) -> void:
	flip_h = facing_sector == 3 or facing_sector == 4 or facing_sector == 5
	var next_animation := StringName(("walk_" if walking else "idle_") + POSES[facing_sector])
	if animation == next_animation:
		if not is_playing():
			play()
		return
	var same_state: bool = String(animation).begins_with("walk_") == walking
	var previous_frame: int = frame
	var previous_progress: float = frame_progress
	play(next_animation)
	# Turning keeps the current step or breath instead of restarting the loop.
	if same_state:
		set_frame_and_progress(previous_frame, previous_progress)
