extends OverworldInteractable
## Repeat the inspection, but finish Albert's discovery only once per session.

const DISCOVERY_FLAG := "school_notice_board_discovered"

func _init() -> void:
	lines = PackedStringArray(["There.", "Found it."])
	speakers = PackedStringArray(["Albert", "Albert"])

func dialogue_available() -> bool:
	return not GameState.get_flag(DISCOVERY_FLAG)

func finish(success: bool) -> void:
	super.finish(success)
	if success and not GameState.get_flag(DISCOVERY_FLAG):
		GameState.set_flag(DISCOVERY_FLAG, true)
