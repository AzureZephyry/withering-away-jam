@tool
extends Node2D
## Static pixel ground treatment. Paths and regions are authored in the Garden scene.

@export_enum("Grass", "Path", "Clearing", "Lawn", "Shade", "Plaza", "PathEdge") var surface: String = "Grass":
	set(value):
		surface = value
		queue_redraw()
@export var extent: Vector2i = Vector2i(2048, 1152):
	set(value):
		extent = value
		queue_redraw()
@export var points: PackedVector2Array = PackedVector2Array():
	set(value):
		points = value
		queue_redraw()
@export var path_width: float = 80.0:
	set(value):
		path_width = value
		queue_redraw()
@export var variant: int = 0:
	set(value):
		variant = value
		queue_redraw()

func _draw() -> void:
	match surface:
		"Grass":
			draw_rect(Rect2(Vector2.ZERO, Vector2(extent)), Color("#829d6c"))
			_grass(Rect2(Vector2.ZERO, Vector2(extent)), false)
		"Path":
			_path()
		"PathEdge":
			if points.size() > 1:
				draw_polyline(points, Color("#8e9671"), path_width + 8, false)
		"Clearing":
			_oval(Rect2(Vector2.ZERO, Vector2(extent)), Color("#91a776"))
			_oval(Rect2(14, 12, extent.x - 28, extent.y - 24), Color("#9aad7c"))
			_grass(Rect2(20, 20, extent.x - 40, extent.y - 40), true)
			_clearing_border()
		"Lawn":
			_oval(Rect2(Vector2.ZERO, Vector2(extent)), Color("#8ba575"))
			_grass(Rect2(12, 12, extent.x - 24, extent.y - 24), true)
		"Shade":
			_oval(Rect2(Vector2.ZERO, Vector2(extent)), Color("#748f68"))
			_grass(Rect2(8, 8, extent.x - 16, extent.y - 16), true)
		"Plaza":
			_oval(Rect2(Vector2.ZERO, Vector2(extent)), Color("#a49f7d"))
			_oval(Rect2(5, 5, extent.x - 10, extent.y - 10), Color("#c4b996"))
			for y in range(12, extent.y - 8, 16):
				for x in range(12, extent.x - 8, 24):
					var p := Vector2(x + (8 if y % 32 == 0 else 0), y)
					var q := (p - Vector2(extent) * 0.5) / (Vector2(extent) * 0.5 - Vector2(16, 16))
					if q.length_squared() < 1.0:
						draw_rect(Rect2(p, Vector2(16, 10)), Color("#d4c8a8") if (x + y) % 3 else Color("#b5ad8e"))

func _grass(area: Rect2, oval: bool) -> void:
	for y in range(int(area.position.y), int(area.end.y), 20):
		for x in range(int(area.position.x), int(area.end.x), 20):
			var seed_value: int = (x * 17 + y * 31 + variant * 73) % 109
			var p := Vector2(x + seed_value % 13, y + (seed_value * 3) % 11)
			if oval:
				var q := (p - area.get_center()) / (area.size * 0.5)
				if q.length_squared() > 0.92:
					continue
			if seed_value % 3 == 0:
				draw_rect(Rect2(p, Vector2(7, 2)), Color("#90a777"))
			if seed_value % 4 == 0:
				draw_rect(Rect2(p + Vector2(4, 5), Vector2(2, 4)), Color("#738f60"))
			if seed_value % 17 == 0:
				draw_rect(Rect2(p + Vector2(6, 1), Vector2(2, 2)), Color("#c5c79b"))

func _path() -> void:
	if points.size() < 2:
		return
	draw_polyline(points, Color("#bfb28e"), path_width, false)
	var carry: float = 0.0
	for i in range(points.size() - 1):
		var a: Vector2 = points[i]
		var direction: Vector2 = points[i + 1] - a
		var length: float = direction.length()
		if length < 0.1:
			continue
		direction /= length
		var side := Vector2(-direction.y, direction.x)
		while carry < length:
			var p: Vector2 = (a + direction * carry).snapped(Vector2(2, 2))
			for lane in [-1, 0, 1]:
				var stone: Vector2 = (p + side * (lane * path_width * 0.27 + sin(p.x * 0.05) * 3)).snapped(Vector2(2, 2))
				var size: float = 10 + int(absf(stone.x + stone.y)) % 3 * 2
				var slab := PackedVector2Array([stone + Vector2(-size * 0.5 + 2, -4), stone + Vector2(size * 0.5 - 2, -4), stone + Vector2(size * 0.5, -2), stone + Vector2(size * 0.5, 3), stone + Vector2(-size * 0.5, 3), stone + Vector2(-size * 0.5, -2)])
				draw_colored_polygon(slab, Color("#d4c6a3") if lane != 0 else Color("#ccbd98"))
				draw_rect(Rect2(stone - Vector2(size * 0.5 - 2, 4), Vector2(size - 4, 1)), Color("#e0d1ae"))
			carry += 22.0
		carry -= length

func _clearing_border() -> void:
	var center := Vector2(extent) * 0.5
	for i in range(64):
		var a: float = i * TAU / 64.0
		var p := (center + Vector2(cos(a) * (center.x - 20), sin(a) * (center.y - 18))).snapped(Vector2(2, 2))
		draw_rect(Rect2(p, Vector2(3, 3)), Color("#788f62"))
		if i % 3 == 0:
			draw_rect(Rect2(p + Vector2(3, -3), Vector2(3, 2)), Color("#d6cf9a"))
			draw_rect(Rect2(p + Vector2(4, -5), Vector2(1, 4)), Color("#e7dcb4"))
	for i in range(12):
		var a: float = i * TAU / 12.0
		var p := (center + Vector2(cos(a) * (center.x - 54), sin(a) * (center.y - 44))).snapped(Vector2(4, 4))
		draw_rect(Rect2(p, Vector2(6, 2)), Color("#b1bd8c"))

func _oval(rect: Rect2, color: Color) -> void:
	var center: Vector2 = rect.get_center()
	for y in range(int(rect.position.y), int(rect.end.y), 4):
		var t: float = (y + 2 - center.y) / (rect.size.y * 0.5)
		var half: float = floorf(sqrt(maxf(0.0, 1.0 - t * t)) * rect.size.x * 0.25) * 2
		if half > 0:
			draw_rect(Rect2(center.x - half, y, half * 2, 4), color)

