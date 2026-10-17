@tool
extends Node2D
## Decorative silhouettes only. Collision shapes are authored separately in each room.

@export_enum("Bed", "Desk", "Chair", "Cabinet", "Window", "Picture", "Lockers",
	"ClassroomDoor", "Board", "Bench", "Tree", "Shrub", "FlowerBed", "Fence") var kind: String = "Bed":
	set(value):
		kind = value
		queue_redraw()
@export var extent: Vector2 = Vector2(48, 80):
	set(value):
		extent = value
		queue_redraw()


func _draw() -> void:
	var w: float = extent.x
	var h: float = extent.y
	match kind:
		"Bed":
			_box(0, 0, w, h, "#494b51")
			_box(3, 5, w - 6, h - 10, "#a2a49b")
			_box(6, 8, w - 12, 16, "#ced0bc")
			_box(3, 30, w - 6, h - 36, "#647c8c")
			_box(3, 34, w - 6, 3, "#879baa")
			_box(0, h - 5, w, 5, "#584b42")
		"Desk", "Cabinet":
			_box(0, 0, w, h, "#4e4843")
			_box(2, 2, w - 4, h - 5, "#94806a")
			if kind == "Desk":
				_box(6, 4, 12, 10, "#c2bca7")
				_box(w - 12, 5, 6, 7, "#596e79")
			else:
				for y in range(10, int(h) - 2, 10):
					_box(3, y, w - 6, 2, "#62584c")
					_box(w / 2 - 2, y - 4, 4, 2, "#c6b08b")
		"Chair":
			_box(2, 0, w - 4, h, "#494c4c")
			_box(0, 0, w, 4, "#8b7967")
			_box(3, 6, w - 6, h - 9, "#73838a")
		"Window":
			_box(0, 0, w, h, "#414d56")
			_box(3, 2, w - 6, h - 5, "#9bafb3")
			_box(w / 2 - 1, 2, 2, h - 4, "#d0cbb5")
			_box(0, h - 3, w, 3, "#beb69f")
		"Picture":
			_box(0, 0, w, h, "#574b42")
			_box(2, 2, w - 4, h - 4, "#a5a791")
			_box(4, h / 2, w - 8, h / 2 - 3, "#687b80")
		"Lockers":
			_box(0, 0, w, h, "#4c605b")
			for x in range(0, int(w), 32):
				_box(x + 2, 2, 28, h - 4, "#849486")
				_box(x + 6, 6, 18, 2, "#50685f")
				_box(x + 6, 10, 18, 2, "#50685f")
				_box(x + 24, h - 12, 2, 6, "#c1c1aa")
		"ClassroomDoor":
			_box(0, 0, w, h, "#59675c")
			_box(3, 2, w - 6, h - 2, "#978b71")
			_box(7, 4, w - 14, 8, "#b3beb1")
			_box(w - 7, h - 7, 3, 2, "#d6caa1")
		"Board":
			_box(0, 0, w, h, "#6b6050")
			_box(2, 2, w - 4, h - 4, "#a99e7c")
			_box(6, 4, 10, h - 8, "#d2cfba")
			_box(21, 5, w - 27, h - 10, "#b4bead")
		"Bench":
			_box(4, 0, 4, h, "#4e5048")
			_box(w - 8, 0, 4, h, "#4e5048")
			_box(0, 2, w, 5, "#99856a")
			_box(0, 9, w, 5, "#8a785e")
		"Tree":
			_box(w / 2 - 4, h - 20, 8, 20, "#695847")
			_box(8, 0, w - 16, 8, "#6b825d")
			_box(0, 8, w, h - 32, "#4d6952")
			_box(8, h - 24, w - 16, 8, "#405d4a")
			_box(8, 8, w - 20, 8, "#7c9063")
		"Shrub":
			_box(4, 0, w - 8, h, "#526b4b")
			_box(0, 4, w, h - 8, "#526b4b")
			_box(5, 4, w - 12, 4, "#849268")
		"FlowerBed":
			_box(0, 0, w, h, "#9d9986")
			_box(3, 3, w - 6, h - 6, "#665c49")
			for x in range(8, int(w) - 4, 16):
				for y in range(8, int(h) - 4, 16):
					_box(x - 2, y, 6, 6, "#657950")
					_box(x, y - 2, 4, 4, "#b6a17d")
		"Fence":
			_box(0, 0, w, h, "#665e50")
			if w >= h:
				for x in range(0, int(w), 16):
					_box(x, 0, 4, h, "#a19a80")
			else:
				for y in range(0, int(h), 16):
					_box(0, y, w, 4, "#a19a80")


func _box(x: float, y: float, w: float, h: float, color: String) -> void:
	draw_rect(Rect2(x, y, w, h), Color(color))

