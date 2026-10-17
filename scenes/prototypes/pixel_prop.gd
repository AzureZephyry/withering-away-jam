@tool
extends Node2D
## Decorative silhouettes only. Collision shapes are authored separately in each room.

@export_enum("Bed", "Desk", "Chair", "Cabinet", "Window", "Picture", "Lockers",
	"ClassroomDoor", "Board", "Bench", "Tree", "Shrub", "FlowerBed", "Fence",
	"BedroomBed", "Nightstand", "ComputerDesk", "HomeChair", "Bookshelf", "Wardrobe", "CurtainedWindow", "Noticeboard", "Calendar", "Rug", "SchoolDesk", "SchoolChair", "GroupTable", "CampusBench", "SchoolWindow", "TeachingBoard", "ReceptionCounter", "Clock", "Planter", "Bin", "CampusInlay", "BookStack") var kind: String = "Bed":
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
	if _draw_room_prop(w, h):
		return
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


func _draw_room_prop(w: float, h: float) -> bool:
	match kind:
		"BedroomBed":
			_box(0, 2, w, h - 2, "#644b3b")
			_box(4, 6, w - 8, h - 12, "#c2a984")
			_box(5, 10, w - 10, h - 20, "#e8ddc0")
			_box(10, 13, w - 20, 18, "#f5ead0")
			_box(13, 16, w - 26, 2, "#d9cbb0")
			_box(5, 38, w - 10, h - 48, "#b26f54")
			_box(5, 41, w - 10, 5, "#d49c72")
			_box(5, h - 20, w - 10, 3, "#d49c72")
			for x in range(12, int(w) - 7, 12):
				_box(x, 50, 1, h - 76, "#bd8060")
			_box(0, 0, w, 7, "#896342")
			_box(3, 1, w - 6, 2, "#b98b5b")
			_box(2, h - 7, w - 4, 5, "#896342")
		"Nightstand":
			_box(0, 2, w, h - 2, "#74583e")
			_box(2, 0, w - 4, h - 5, "#b58d5e")
			_box(4, h - 9, w - 8, 1, "#806041")
			_box(w / 2 - 2, h - 7, 4, 2, "#d3b47e")
			_box(4, 3, 7, 10, "#6c7f78")
			_box(5, 5, 5, 1, "#c9c7a8")
			_box(w - 11, 4, 7, 7, "#e4c791")
			_box(w - 9, 11, 3, 3, "#8a704b")
		"ComputerDesk", "SchoolDesk", "ReceptionCounter":
			_box(3, h - 4, 5, 4, "#635747")
			_box(w - 8, h - 4, 5, 4, "#635747")
			_box(0, 2, w, h - 5, "#896a49")
			_box(2, 0, w - 4, h - 7, "#c4a577")
			_box(4, 2, w - 8, 2, "#d8ba87")
			if kind == "ComputerDesk":
				_box(w / 2 - 16, 4, 32, 15, "#454b4a")
				_box(w / 2 - 13, 6, 26, 10, "#85a5a0")
				_box(w / 2 - 10, 8, 13, 1, "#c5d4c1")
				_box(w / 2 - 3, 19, 6, 2, "#555e57")
				_box(w / 2 - 14, 22, 28, 5, "#d5cbb0")
				_box(5, 8, 8, 12, "#dfd5b8")
				_box(6, 11, 6, 1, "#9bada1")
				_box(w - 9, 22, 4, 4, "#eee0b9")
			elif kind == "ReceptionCounter":
				_box(5, 5, w - 10, 3, "#876647")
				_box(w - 43, 12, 26, 14, "#4d5a54")
				_box(w - 40, 14, 20, 9, "#8fa89a")
				_box(14, 12, 18, 12, "#e9dec4")
				_box(17, 15, 12, 1, "#8d9d91")
				_box(39, 12, 9, 12, "#b87e5b")
			else:
				_box(6, 6, 13, 11, "#eee3c9")
				_box(8, 9, 8, 1, "#a3ada0")
				_box(8, 12, 8, 1, "#a3ada0")
				_box(w - 14, 7, 8, 10, "#879781")
				_box(w - 13, 8, 1, 8, "#586d64")
				_box(w / 2, 7, 1, 10, "#d6a558")
		"HomeChair", "SchoolChair":
			_box(2, 2, w - 4, h - 2, "#565b50")
			_box(0, 0, w, 6, "#8d7252")
			_box(2, 1, w - 4, 2, "#bea077")
			_box(3, 9, w - 6, h - 12, "#a77c58" if kind == "SchoolChair" else "#8a9b7e")
			_box(4, 10, w - 8, 2, "#cfaa78" if kind == "SchoolChair" else "#a9b08b")
		"Wardrobe":
			_box(0, 0, w, h, "#6f513c")
			_box(3, 3, w - 6, h - 7, "#ae8355")
			_box(5, 5, w / 2 - 7, h - 12, "#bd9464")
			_box(w / 2 + 2, 5, w / 2 - 7, h - 12, "#b78b5d")
			_box(w / 2 - 1, 3, 2, h - 6, "#79583f")
			_box(w / 2 - 6, h / 2, 2, 6, "#e2c08a")
			_box(w / 2 + 4, h / 2, 2, 6, "#e2c08a")
		"Bookshelf":
			_box(0, 0, w, h, "#70533e")
			_box(3, 3, w - 6, h - 6, "#90704c")
			for y in range(4, int(h) - 8, 20):
				for x in range(5, int(w) - 8, 9):
					var shades: Array[String] = ["#819486", "#be9165", "#9b775b", "#c3b78c", "#6b8686"]
					_box(x, y + (x % 3), 6, mini(13, h - y - 5), shades[int(x / 9.0) % shades.size()])
					_box(x + 1, y + 4, 4, 1, "#d3c6a5")
				_box(3, y + 15, w - 6, 3, "#b08a5b")
		"CurtainedWindow", "SchoolWindow":
			_box(0, 0, w, h, "#8a765b")
			_box(3, 2, w - 6, h - 5, "#aec6bf")
			_box(5, 3, w - 10, 3, "#d9e2c9")
			_box(w / 2 - 1, 2, 2, h - 4, "#e4d6b4")
			_box(0, h - 4, w, 4, "#b4936b")
			if kind == "CurtainedWindow":
				_box(0, 0, 9, h - 2, "#b37358")
				_box(w - 9, 0, 9, h - 2, "#b37358")
				_box(2, 2, 2, h - 5, "#d49870")
				_box(w - 5, 2, 2, h - 5, "#d49870")
				_box(0, 0, w, 3, "#d6b68c")
		"Noticeboard":
			_box(0, 0, w, h, "#856343")
			_box(3, 3, w - 6, h - 6, "#b29a70")
			for x in range(7, int(w) - 14, 19):
				var top: int = 5 + x % 3
				_box(x, top, 13, h - top - 6, "#ede0bd" if x % 2 == 0 else "#b8c3a0")
				_box(x + 5, top + 1, 2, 2, "#a36f50")
				_box(x + 2, top + 6, 9, 1, "#9a9b7b")
		"Calendar":
			_box(0, 0, w, h, "#ede1c5")
			_box(0, 0, w, 5, "#ae7858")
			for y in range(8, int(h) - 2, 4):
				for x in range(3, int(w) - 2, 4):
					_box(x, y, 2, 2, "#a4a78c")
		"Rug":
			_box(4, 0, w - 8, h, "#af7659")
			_box(0, 4, w, h - 8, "#af7659")
			_box(5, 5, w - 10, h - 10, "#d2b087")
			_box(9, 9, w - 18, h - 18, "#bd8967")
			_box(w / 2 - 10, h / 2 - 10, 20, 20, "#d8bb8d")
			for x in range(12, int(w) - 8, 12):
				_box(x, 5, 2, 2, "#8c6f53")
				_box(x, h - 7, 2, 2, "#8c6f53")
		"GroupTable":
			_box(7, h - 8, 5, 8, "#655c4b")
			_box(w - 12, h - 8, 5, 8, "#655c4b")
			_box(5, 0, w - 10, h - 4, "#a88960")
			_box(0, 5, w, h - 14, "#a88960")
			_box(5, 3, w - 10, h - 10, "#cdb487")
			_box(5, 6, w - 10, 2, "#e0c79b")
			_box(14, 12, 16, 11, "#ede3c9")
			_box(17, 15, 10, 1, "#9ca98d")
			_box(w - 30, 12, 14, 12, "#879b8c")
			_box(w - 27, 14, 10, 1, "#c6d1b7")
		"CampusBench":
			_box(4, h - 7, 5, 7, "#665743")
			_box(w - 9, h - 7, 5, 7, "#665743")
			_box(0, 0, w, h - 7, "#7f8f73")
			_box(3, 2, w - 6, 5, "#a0ad89")
			_box(4, 9, w - 8, h - 18, "#9aa17a")
			for x in range(28, int(w) - 5, 28):
				_box(x, 9, 1, h - 18, "#74856b")
		"TeachingBoard":
			_box(0, 0, w, h, "#8d6c49")
			_box(3, 2, w - 6, h - 6, "#506b5c")
			_box(10, 6, w / 3, 1, "#ddd9b8")
			_box(10, 10, w / 4, 1, "#c6ccb0")
			_box(w / 2, 6, 2, h - 15, "#bdc9ae")
			_box(w / 2, h - 11, w / 4, 1, "#bdc9ae")
			_box(w / 2 + 6, 10, 10, 7, "#a6baa2")
			_box(3, h - 4, w - 6, 3, "#c7ac7d")
		"Clock":
			draw_colored_polygon(PackedVector2Array([Vector2(4,0), Vector2(w-4,0), Vector2(w,4), Vector2(w,h-4), Vector2(w-4,h), Vector2(4,h), Vector2(0,h-4), Vector2(0,4)]), Color("#8a7253"))
			_box(3, 3, w - 6, h - 6, "#eee2c1")
			_box(w / 2, 4, 1, h / 2 - 2, "#5e6658")
			_box(w / 2, h / 2, w / 4, 1, "#5e6658")
		"Planter":
			_box(3, h - 11, w - 6, 10, "#ad8259")
			_box(2, h - 13, w - 4, 4, "#c49a6c")
			_box(w / 2 - 1, 4, 2, h - 14, "#708363")
			_box(2, 5, w / 2 - 2, 6, "#8a9a6b")
			_box(w / 2, 1, w / 2 - 2, 6, "#799464")
			_box(w / 2, 11, w / 2 - 1, 5, "#617d57")
		"Bin":
			_box(2, 4, w - 4, h - 4, "#7e8b78")
			_box(0, 1, w, 5, "#a7ac8e")
			_box(4, 2, w - 8, 2, "#586957")
			_box(4, 9, 2, h - 13, "#9ca689")
		"CampusInlay":
			_box(12, 0, w - 24, h, "#c4a779")
			_box(0, 12, w, h - 24, "#c4a779")
			_box(12, 8, w - 24, h - 16, "#e9ddbd")
			_box(8, 12, w - 16, h - 24, "#e9ddbd")
			_box(w / 2 - 10, h / 2 - 20, 20, 40, "#ac8460")
			_box(w / 2 - 20, h / 2 - 10, 40, 20, "#ac8460")
		"BookStack":
			_box(0, h - 7, w - 3, 6, "#ad7859")
			_box(2, h - 6, w - 7, 2, "#dfd1b3")
			_box(3, h - 13, w - 3, 6, "#829889")
			_box(5, h - 12, w - 7, 2, "#e3d6ba")
			_box(1, 0, w - 4, h - 14, "#c9b788")
		_:
			return false
	return true

