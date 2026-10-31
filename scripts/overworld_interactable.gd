class_name OverworldInteractable
extends Node2D
## Add to an environmental object. Bounds are local to visual_path.

enum Trigger { MANUAL, AUTOMATIC }
enum Repeat { KEYPRESS, REENTRY, ONE_TIME }
enum Presentation { DREAM, REAL }

@export var radius: float = 84.0
@export var trigger: Trigger = Trigger.MANUAL
@export var repeat_mode: Repeat = Repeat.KEYPRESS
@export var presentation: Presentation = Presentation.REAL
@export var lines: PackedStringArray = []
@export var speakers: PackedStringArray = []
@export var focus_texture: Texture2D
@export var inspection_scene: PackedScene
@export_node_path("Node2D") var visual_path: NodePath = ^".."
# Include the full movement envelope of any animated artwork.
@export var visual_bounds: Rect2 = Rect2(0, 0, 32, 32)

var in_range: bool = false
var completed_once: bool = false
var _requires_exit: bool = false

func _ready() -> void:
	add_to_group("overworld_interactables")

func observe(player_position: Vector2) -> void:
	in_range = global_position.distance_squared_to(player_position) <= radius * radius
	if not in_range:
		_requires_exit = false

func available() -> bool:
	return in_range and not _requires_exit and not lines.is_empty() and not (repeat_mode == Repeat.ONE_TIME and completed_once)

func automatic_ready() -> bool:
	# Automatic + keypress repeats automatically only the first time.
	return available() and trigger == Trigger.AUTOMATIC and not (repeat_mode == Repeat.KEYPRESS and completed_once)

func begin() -> void:
	_requires_exit = true

func finish(success: bool) -> void:
	if success:
		completed_once = true
		_requires_exit = repeat_mode != Repeat.KEYPRESS

func screen_bounds() -> Rect2:
	var visual: Node2D = get_node(visual_path)
	return visual.get_global_transform_with_canvas() * visual_bounds

func dialogue_available() -> bool:
	return not lines.is_empty()

func speaker(index: int) -> String:
	return speakers[index] if index < speakers.size() else ""
