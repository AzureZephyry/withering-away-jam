extends Node
## Session-only story flags. Register approved names here before using them.

signal flag_changed(flag_name: String, value: bool)

const REGISTERED_FLAGS: Array[String] = [
	"bedroom_intro_completed",
	"bedroom_schedule_checked",
	"bedroom_id_checked",
	"bedroom_medal_checked",
]

var _flags: Dictionary[String, bool] = {}

func _init() -> void:
	for flag_name in REGISTERED_FLAGS:
		_flags[flag_name] = false

func set_flag(flag_name: Variant, value: Variant) -> bool:
	if not _is_registered(flag_name):
		return false
	if not value is bool:
		push_warning("GameState.set_flag: '%s' needs a bool value; got %s." % [flag_name, type_string(typeof(value))])
		return false
	if _flags[flag_name] == value:
		return true
	_flags[flag_name] = value
	flag_changed.emit(flag_name, value)
	return true

func get_flag(flag_name: Variant) -> Variant:
	if not _is_registered(flag_name):
		return null
	return _flags[flag_name]

func clear_flag(flag_name: Variant) -> bool:
	return set_flag(flag_name, false)

func reset_session() -> void:
	var changed_flags: Array[String] = []
	for flag_name in REGISTERED_FLAGS:
		if _flags[flag_name]:
			_flags[flag_name] = false
			changed_flags.append(flag_name)
	# Listeners see the fully reset session, even during the first notification.
	for flag_name in changed_flags:
		flag_changed.emit(flag_name, false)

func _is_registered(flag_name: Variant) -> bool:
	if not flag_name is String:
		push_warning("GameState: flag names must be String values; got %s." % type_string(typeof(flag_name)))
		return false
	if not _flags.has(flag_name):
		push_warning("GameState: unknown flag '%s'. Add approved names to REGISTERED_FLAGS in scripts/game_state.gd." % flag_name)
		return false
	return true
