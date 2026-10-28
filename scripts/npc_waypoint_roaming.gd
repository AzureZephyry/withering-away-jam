extends Node
## Follow scene-authored stops through the character's existing movement API.

enum State { WALKING, PAUSING, BLOCKED, WORKING, RESTING }

@export_node_path("Node2D") var route_path: NodePath
@export_range(0.5, 8.0, 0.5) var arrival_tolerance: float = 2.0
@export_range(0.0, 10.0, 0.25) var pause_min_seconds: float = 2.0
@export_range(0.0, 10.0, 0.25) var pause_max_seconds: float = 4.0
@export_range(0.1, 2.0, 0.05) var blocked_after_seconds: float = 0.35
@export_range(0.25, 5.0, 0.25) var retry_seconds: float = 1.25

var state: State = State.WALKING
var waypoint_index: int = 0
var completed_loops: int = 0
var _stops: Array[Marker2D] = []
var _timer: float = 0.0
var _stalled_seconds: float = 0.0
var _previous_position: Vector2
var _requested_direction := Vector2.ZERO
var _work_settings: Dictionary = {}
@onready var _actor: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	var route := get_node_or_null(route_path)
	if route != null:
		for child in route.get_children():
			if child is Marker2D:
				_stops.append(child)
	_previous_position = _actor.global_position
	if _stops.is_empty():
		_actor.set_move_direction(Vector2.ZERO)
		set_physics_process(false)
		push_warning("NPC roaming needs a route containing Marker2D stops.")

func _physics_process(delta: float) -> void:
	var displacement := _actor.global_position - _previous_position
	_previous_position = _actor.global_position
	if state in [State.PAUSING, State.WORKING, State.RESTING]:
		_actor.set_move_direction(Vector2.ZERO)
		_timer -= delta
		if _timer <= 0.0:
			if state == State.WORKING:
				_actor.end_activity()
				state = State.RESTING
				_timer = randf_range(_work_settings.rest_min, _work_settings.rest_max)
			else:
				waypoint_index = (waypoint_index + 1) % _stops.size()
				if waypoint_index == 0:
					completed_loops += 1
				state = State.WALKING
		return

	var remaining := _stops[waypoint_index].global_position - _actor.global_position
	if remaining.length() <= arrival_tolerance:
		state = State.PAUSING
		_timer = randf_range(pause_min_seconds, maxf(pause_min_seconds, pause_max_seconds))
		_stalled_seconds = 0.0
		_requested_direction = Vector2.ZERO
		_actor.set_move_direction(Vector2.ZERO)
		var stop: Marker2D = _stops[waypoint_index]
		if stop.has_method("get_work_settings"):
			_work_settings = stop.get_work_settings()
			_actor.begin_activity(_work_settings.direction, _work_settings.animation)
			state = State.WORKING
			_timer = randf_range(_work_settings.work_min, _work_settings.work_max)
		return

	if state == State.BLOCKED:
		_actor.set_move_direction(Vector2.ZERO)
		_timer -= delta
		if _timer <= 0.0:
			_timer = retry_seconds
			# Stay idle while the next physical step is still obstructed.
			if not _actor.test_move(_actor.global_transform, remaining.normalized() * _actor.movement_speed * delta):
				state = State.WALKING
				_stalled_seconds = 0.0
				_requested_direction = Vector2.ZERO
		return

	if not _requested_direction.is_zero_approx():
		if displacement.dot(_requested_direction) < _actor.movement_speed * delta * 0.1:
			_stalled_seconds += delta
		else:
			_stalled_seconds = 0.0
	if _stalled_seconds >= blocked_after_seconds:
		state = State.BLOCKED
		_timer = retry_seconds
		_actor.set_move_direction(Vector2.ZERO)
		return

	_requested_direction = remaining.normalized()
	# Cap the final step instead of overshooting or snapping to the marker.
	var fraction := minf(1.0, remaining.length() / maxf(_actor.movement_speed * delta, 0.001))
	_actor.set_move_direction(_requested_direction * fraction)
