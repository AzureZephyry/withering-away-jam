extends Node
## Shared session time. Story progression and Sanity do not depend on this clock.

signal minute_changed(hour: int, minute: int)
signal time_overridden(previous_minutes: float, current_minutes: float)

const MINUTES_PER_DAY: float = 1440.0
const REAL_SECONDS_PER_MINUTE: float = 1.0
const INITIAL_MINUTES: float = 390.0

var _minutes: float = INITIAL_MINUTES
var _last_tick_msec: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_last_tick_msec = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_msec()
	var elapsed: float = maxf(0.0, float(now - _last_tick_msec) / 1000.0)
	_last_tick_msec = now
	_advance_elapsed(elapsed)

func _advance_elapsed(real_seconds: float) -> void:
	if real_seconds <= 0.0:
		return
	var previous: int = floori(_minutes)
	_minutes = fposmod(_minutes + real_seconds / REAL_SECONDS_PER_MINUTE, MINUTES_PER_DAY)
	if floori(_minutes) != previous:
		minute_changed.emit(get_hour(), get_minute())

func set_time(hour: int, minute: int = 0) -> bool:
	if hour < 0 or hour > 23 or minute < 0 or minute > 59:
		return false
	var previous_time: float = _minutes
	var previous: int = floori(previous_time)
	_minutes = float(hour * 60 + minute)
	_last_tick_msec = Time.get_ticks_msec()
	time_overridden.emit(previous_time, _minutes)
	if floori(_minutes) != previous:
		minute_changed.emit(get_hour(), get_minute())
	return true

func get_minutes() -> float:
	return _minutes

func get_hour() -> int:
	return floori(_minutes / 60.0)

func get_minute() -> int:
	return floori(_minutes) % 60

func get_day_fraction() -> float:
	return _minutes / MINUTES_PER_DAY
