extends Node
## Session-only deterioration. Presentation and story progression belong to callers.

signal score_changed(previous: int, current: int)
signal stage_changed(previous: Stage, current: Stage)
signal game_over

enum Stage { NONE, SANE, MODERATELY_SANE, INSANE }

const MAX_SCORE: int = 6
const MODERATE_THRESHOLD: int = 2
const INSANE_THRESHOLD: int = 4

var _score: int = 0
var _notifying: bool = false

func get_score() -> int:
	return _score

func get_stage() -> Stage:
	if is_failed():
		return Stage.NONE
	if _score >= INSANE_THRESHOLD:
		return Stage.INSANE
	if _score >= MODERATE_THRESHOLD:
		return Stage.MODERATELY_SANE
	return Stage.SANE

func is_failed() -> bool:
	return _score == MAX_SCORE

func apply_effect(effect: Variant) -> bool:
	if _notifying or is_failed() or typeof(effect) != TYPE_INT:
		return false
	if effect < -1 or effect > 1:
		return false
	_change_score(clampi(_score + effect, 0, MAX_SCORE))
	return true

func reset_session() -> bool:
	if _notifying:
		return false
	_change_score(0)
	return true

func _change_score(value: int) -> void:
	if value == _score:
		return
	var previous: int = _score
	var previous_stage: Stage = get_stage()
	_score = value
	var current_stage: Stage = get_stage()
	# Callbacks can read the final state, but cannot interrupt this notification batch.
	_notifying = true
	score_changed.emit(previous, _score)
	if current_stage != Stage.NONE and current_stage != previous_stage:
		stage_changed.emit(previous_stage, current_stage)
	if is_failed():
		game_over.emit()
	_notifying = false
