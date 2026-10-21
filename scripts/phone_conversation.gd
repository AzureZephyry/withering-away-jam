extends Control

signal finished(branch: int)
signal choice_committed(branch: int)

const CANVAS_SIZE := Vector2(640.0, 1088.0)
const VIEWPORT_PADDING := 16.0
const SCREENS: Array[Texture2D] = [
	preload("res://assets/ui/phone/prepared/phone_common_01_mama_greeting.png"),
	preload("res://assets/ui/phone/prepared/phone_common_02_mama_congratulations.png"),
	preload("res://assets/ui/phone/prepared/phone_common_03_papa_message.png"),
	preload("res://assets/ui/phone/prepared/phone_common_04_choices.png"),
	preload("res://assets/ui/phone/prepared/phone_branch1_05_albert_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch1_06_mama_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch1_07_papa_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch2_08_albert_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch2_09_mama_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch2_10_papa_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch2_11_mama_final.png"),
	preload("res://assets/ui/phone/prepared/phone_branch3_12_albert_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch3_13_albert_nervous.png"),
	preload("res://assets/ui/phone/prepared/phone_branch3_14_mama_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch3_15_papa_reply.png"),
	preload("res://assets/ui/phone/prepared/phone_branch3_16_mama_final.png"),
]
const BRANCH_START: Array[int] = [5, 8, 12]
const BRANCH_END: Array[int] = [7, 11, 16]

# Regions use prepared-image pixels, shared by the outline and mouse tests.
const CHOICE_REGIONS: Array[Rect2] = [
	Rect2(103.0, 716.0, 432.0, 58.0),
	Rect2(103.0, 774.0, 432.0, 56.0),
	Rect2(103.0, 830.0, 432.0, 56.0),
]

@export_range(0.1, 1.0, 0.05) var phone_scale: float = 0.75

var current_screen: int = 1
var selected_choice: int = 0
var branch: int = 0
var active: bool = false

@onready var phone_canvas: Control = $PhoneCanvas
@onready var artwork: TextureRect = $PhoneCanvas/Artwork
@onready var choice_outline: Panel = $PhoneCanvas/ChoiceOutline

func _ready() -> void:
	resized.connect(_layout_phone)
	hide()
	_layout_phone()
	_show_screen()

func open_conversation() -> void:
	if active:
		return
	active = true
	branch = 0
	selected_choice = 0
	current_screen = 1
	show()
	_layout_phone()
	_show_screen()

func advance() -> void:
	if not active or is_choosing():
		return
	if branch == 0:
		current_screen += 1
		_show_screen()
	elif current_screen < BRANCH_END[branch - 1]:
		current_screen += 1
		_show_screen()
	else:
		active = false
		hide()
		choice_outline.hide()
		finished.emit(branch)

func move_selection(direction: int) -> void:
	if not is_choosing():
		return
	selected_choice = wrapi(selected_choice + signi(direction), 0, CHOICE_REGIONS.size())
	_update_outline()

func confirm_selection() -> void:
	if not is_choosing():
		return
	# Branch identity follows response order, not placeholder image wording.
	branch = selected_choice + 1
	current_screen = BRANCH_START[selected_choice]
	_show_screen()
	choice_committed.emit(branch)

func hover_choice(viewport_position: Vector2) -> void:
	if not is_choosing():
		return
	var hovered: int = _choice_at(viewport_position)
	if hovered >= 0:
		selected_choice = hovered
		_update_outline()

func click_choice(viewport_position: Vector2) -> void:
	if not is_choosing():
		return
	var clicked: int = _choice_at(viewport_position)
	if clicked >= 0:
		selected_choice = clicked
		confirm_selection()

func is_choosing() -> bool:
	return active and current_screen == 4 and branch == 0

func _choice_at(viewport_position: Vector2) -> int:
	var image_position: Vector2 = phone_canvas.get_global_transform_with_canvas().affine_inverse() * viewport_position
	for index: int in range(CHOICE_REGIONS.size()):
		if CHOICE_REGIONS[index].has_point(image_position):
			return index
	return -1

func _show_screen() -> void:
	artwork.texture = SCREENS[current_screen - 1]
	_update_outline()

func _update_outline() -> void:
	choice_outline.visible = is_choosing()
	if choice_outline.visible:
		choice_outline.position = CHOICE_REGIONS[selected_choice].position
		choice_outline.size = CHOICE_REGIONS[selected_choice].size

func _layout_phone() -> void:
	if not is_node_ready():
		return
	var available: Vector2 = (size - Vector2.ONE * VIEWPORT_PADDING * 2.0).max(Vector2.ONE)
	var uniform_scale: float = minf(phone_scale, minf(available.x / CANVAS_SIZE.x, available.y / CANVAS_SIZE.y))
	phone_canvas.size = CANVAS_SIZE
	phone_canvas.scale = Vector2.ONE * uniform_scale
	phone_canvas.position = (size - CANVAS_SIZE * uniform_scale) * 0.5
