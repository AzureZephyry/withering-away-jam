@tool
extends Node2D

@export_enum("Wood", "Tile", "Grass") var pattern: String = "Wood":
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
