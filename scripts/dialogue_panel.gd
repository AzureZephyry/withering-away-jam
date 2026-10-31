extends Control
## Full-image skins selected by Albert's world, independently of interaction type.
## Panel-only FontVariations trim this font's oversized vertical metrics; the TTF is unchanged.

enum World { DREAM, REAL }

const DREAM_ART = preload("res://assets/ui/dialogue/dialogue_dream_world.png")
const REAL_ART = preload("res://assets/ui/dialogue/dialogue_real_world.png")

@export var world: World = World.DREAM:
	set(value):
		world = value
		if is_node_ready():
			_apply_world()

@export var speaker_name: String = "":
	set(value):
		speaker_name = value
		if is_node_ready():
			$Speaker.text = speaker_name

@onready var artwork: TextureRect = $Artwork
@onready var body: Label = $Margin/Content/Body
@onready var hint: Label = $Margin/Content/Hint
@onready var speaker: Label = $Speaker

func _ready() -> void:
	add_to_group("dialogue_panels")
	resized.connect(_layout_artwork)
	speaker.text = speaker_name
	_apply_world()

func _apply_world() -> void:
	var dreaming: bool = world == World.DREAM
	artwork.texture = DREAM_ART if dreaming else REAL_ART
	body.add_theme_color_override("font_color", Color("#fff9ed") if dreaming else Color("#151d22"))
	hint.add_theme_color_override("font_color", Color("#c4c9cf") if dreaming else Color("#515a64"))
	# Both supplied name tabs are light, including the Dream World tab.
	speaker.add_theme_color_override("font_color", Color("#252b32"))
	_layout_artwork()

func _layout_artwork() -> void:
	if not is_node_ready() or artwork.texture == null or size.x <= 0.0:
		return
	var source: Vector2 = artwork.texture.get_size()
	var visible_area := Rect2(artwork.texture.get_image().get_used_rect())
	if not visible_area.has_area():
		return
	var scale_factor: float = size.x / visible_area.size.x
	var artwork_height: float = visible_area.size.y * scale_factor
	if not is_equal_approx(size.y, artwork_height):
		offset_top = offset_bottom - artwork_height
	# Keep the complete texture; transparent canvas does not occupy dialogue space.
	artwork.anchor_right = 0.0
	artwork.anchor_bottom = 0.0
	artwork.position = -visible_area.position * scale_factor
	artwork.size = source * scale_factor
	# Safe areas in the approved 640 x 480 exports, before transparent padding.
	var body_rect := Rect2(64, 346, 460, 82) if world == World.DREAM else Rect2(64, 344, 510, 84)
	var tab_rect := Rect2(66, 313, 122, 28)
	$Margin.position = (body_rect.position - visible_area.position) * scale_factor
	$Margin.size = body_rect.size * scale_factor
	speaker.position = (tab_rect.position - visible_area.position) * scale_factor
	speaker.size = tab_rect.size * scale_factor
