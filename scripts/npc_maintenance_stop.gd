extends Marker2D
## Work settings for an existing waypoint; ordinary markers remain rest stops.

@export var work_direction := Vector2.LEFT
@export_range(1.0, 60.0, 0.5) var work_min_seconds: float = 6.0
@export_range(1.0, 60.0, 0.5) var work_max_seconds: float = 10.0
@export_range(0.0, 15.0, 0.5) var rest_min_seconds: float = 2.0
@export_range(0.0, 15.0, 0.5) var rest_max_seconds: float = 4.0
@export var work_animation: StringName = &""

func get_work_settings() -> Dictionary:
	return {"direction": work_direction, "animation": work_animation,
		"work_min": work_min_seconds, "work_max": maxf(work_min_seconds, work_max_seconds),
		"rest_min": rest_min_seconds, "rest_max": maxf(rest_min_seconds, rest_max_seconds)}
