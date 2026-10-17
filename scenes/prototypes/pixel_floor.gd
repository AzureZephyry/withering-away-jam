@tool
extends Node2D
## Visual-only 16-pixel floor pattern for the temporary camera laboratory.

@export_enum("Wood", "Tile", "Grass", "WarmWood", "Terrazzo", "Classroom", "Parquet", "Carpet") var pattern: String = "Wood":
	set(value):
		pattern = value
		queue_redraw()
@export var extent: Vector2i = Vector2i(288, 160):
	set(value):
		extent = value
		queue_redraw()
@export var stone_paths: Array[Rect2] = []:
	set(value):
		stone_paths = value
		queue_redraw()


func _draw() -> void:
	if _draw_room_floor():
		return
	for y in range(0, extent.y, 16):
		for x in range(0, extent.x, 16):
			var alternate: bool = (x + y) % 32 == 0
			var tile := Rect2(x, y, mini(16, extent.x - x), mini(16, extent.y - y))
			match pattern:
				"Wood":
					draw_rect(tile, Color("#77695d") if alternate else Color("#706256"))
					draw_rect(Rect2(x, y, tile.size.x, 1), Color("#514c48"))
					draw_rect(Rect2(x, y, 1, tile.size.y), Color("#60554c"))
					draw_rect(Rect2(x + 4, y + 7, 8, 1), Color("#827264"))
				"Tile":
					draw_rect(tile, Color("#b3b19d") if alternate else Color("#a9ad9e"))
					draw_rect(Rect2(x, y, tile.size.x, 1), Color("#808b80"))
					draw_rect(Rect2(x, y, 1, tile.size.y), Color("#808b80"))
				"Grass":
					draw_rect(tile, Color("#65785b") if alternate else Color("#607255"))
					draw_rect(Rect2(x + 4, y + 5, 2, 3), Color("#81906b"))
					draw_rect(Rect2(x + 11, y + 12, 3, 2), Color("#4e644e"))
	for path in stone_paths:
		draw_rect(path, Color("#727a70"))
		for y in range(int(path.position.y), int(path.end.y), 16):
			for x in range(int(path.position.x), int(path.end.x), 16):
				draw_rect(Rect2(x + 1, y + 1, 14, 14), Color("#9c9e8e"))
				draw_rect(Rect2(x + 3, y + 3, 9, 1), Color("#b2b1a0"))


func _draw_room_floor() -> bool:
	match pattern:
		"WarmWood":
			draw_rect(Rect2(Vector2.ZERO, Vector2(extent)), Color("#ad8056"))
			for y in range(0, extent.y, 12):
				draw_rect(Rect2(0, y, extent.x, 1), Color("#8f694b"))
				var stagger: int = 32 if int(y / 12.0) % 2 == 0 else 0
				for x in range(stagger, extent.x, 64):
					draw_rect(Rect2(x, y, 1, mini(12, extent.y - y)), Color("#95704f"))
					draw_rect(Rect2(x + 7, y + 5, mini(18, extent.x - x - 7), 1), Color("#bc9369"))
		"Terrazzo":
			draw_rect(Rect2(Vector2.ZERO, Vector2(extent)), Color("#ddd2b8"))
			for y in range(0, extent.y, 24):
				for x in range(0, extent.x, 24):
					draw_rect(Rect2(x + 5, y + 7, 2, 1), Color("#c5b79d"))
					draw_rect(Rect2(x + 16, y + 17, 1, 2), Color("#e9dfc6"))
		"Classroom":
			draw_rect(Rect2(Vector2.ZERO, Vector2(extent)), Color("#c9bb97"))
			for y in range(0, extent.y, 32):
				for x in range(0, extent.x, 32):
					var shade := Color("#c5b894") if (x + y) % 64 == 0 else Color("#cdbf9c")
					draw_rect(Rect2(x, y, mini(32, extent.x - x), mini(32, extent.y - y)), shade)
					draw_rect(Rect2(x + 5, y + 9, 2, 1), Color("#b7ab8c"))
		"Parquet":
			draw_rect(Rect2(Vector2.ZERO, Vector2(extent)), Color("#9e7955"))
			for y in range(0, extent.y, 16):
				for x in range(0, extent.x, 32):
					draw_rect(Rect2(x + 1, y + 1, mini(30, extent.x - x - 1), mini(14, extent.y - y - 1)), Color("#ae8860") if (int(x / 32.0) + int(y / 16.0)) % 2 == 0 else Color("#a4805b"))
					draw_rect(Rect2(x + 5, y + 7, mini(16, extent.x - x - 5), 1), Color("#b48e65"))
		"Carpet":
			draw_rect(Rect2(Vector2.ZERO, Vector2(extent)), Color("#78836c"))
			for y in range(0, extent.y, 8):
				for x in range(0, extent.x, 8):
					draw_rect(Rect2(x + 2, y + 3, 1, 1), Color("#838c76"))
		_:
			return false
	return true

