extends Label
## Shared checklist presentation; scene controllers own progression.

@onready var checklist_boxes: Array[Panel] = [$ScheduleCheck, $IDCheck, $MedalCheck]

func present(title: String, entries: PackedStringArray, completed: Array[bool]) -> void:
	var lines: PackedStringArray = [title]
	for entry in entries:
		lines.append("   " + entry)
	text = "\n".join(lines)
	size.y = maxf(66.0, get_combined_minimum_size().y)
	var line_height: float = get_line_height()
	var line_step: float = line_height + get_theme_constant("line_spacing")
	for index in checklist_boxes.size():
		var checkbox := checklist_boxes[index]
		checkbox.visible = index < entries.size()
		checkbox.position = Vector2(14, 8 + (index + 1) * line_step + (line_height - 12) * 0.5)
		checkbox.get_node("Fill").visible = index < completed.size() and completed[index]
