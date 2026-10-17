@tool
extends Node2D
## Garden-only silhouettes. Solid geometry is authored separately in the saved scene.

@export_enum("Tree", "Hedge", "Flowers", "Bench", "Gazebo", "CorpseLily", "Fern", "Rock", "Arbor", "Birdbath", "Wildflowers", "TreeTrunk", "TreeCanopy", "GazeboBase", "GazeboRoof", "GazeboFront") var kind: String = "Tree":
	set(value):
		kind = value
		queue_redraw()
@export var extent: Vector2 = Vector2(96, 128):
	set(value):
		extent = value
		queue_redraw()
@export var variant: int = 0:
	set(value):
		variant = value
		queue_redraw()

func _draw() -> void:
	var w: float = extent.x
	var h: float = extent.y
	match kind:
		"Tree":
			_tree_trunk(w, h)
			_tree_canopy(w, h)
		"TreeTrunk":
			_tree_trunk(w, h)
		"TreeCanopy":
			_tree_canopy(w, h)
		"Hedge":
			_box(0, 4, w, h - 4, "#536f50")
			if w >= h:
				for x in range(0, int(w), 24):
					_oval(Rect2(x - 4, 0, 32, h - 4), "#638352")
					_box(x + 4, 6, 12, 3, "#91a570")
					_box(x + 17, h - 12, 4, 3, "#75925e")
			else:
				for y in range(0, int(h), 24):
					_oval(Rect2(0, y - 4, w - 4, 32), "#638352")
					_box(5, y + 4, 9, 3, "#91a570")
					_box(w - 12, y + 15, 4, 3, "#75925e")
			_box(0, h - 3, w, 3, "#817e64")
		"Flowers":
			_flowers(w, h)
		"Bench":
			_oval(Rect2(2, 10, w + 6, h), "#74845f")
			_box(8, 8, 5, h - 4, "#5c6957")
			_box(w - 13, 8, 5, h - 4, "#5c6957")
			for y in [0, 7, 18, 25]:
				_box(0, y, w, 5, "#a08359" if y < 14 else "#b99a69")
				_box(2, y, w - 4, 1, "#d0b27e")
			_box(4, 13, 4, 13, "#69715a")
			_box(w - 8, 13, 4, 13, "#69715a")
		"Gazebo":
			_gazebo_base(w, h)
			draw_set_transform(Vector2(0, h - 16))
			_gazebo_front(w, h)
			draw_set_transform(Vector2.ZERO)
			_gazebo_roof(w)
		"GazeboBase":
			_gazebo_base(w, h)
		"GazeboRoof":
			_gazebo_roof(w)
		"GazeboFront":
			_gazebo_front(w, h)
		"CorpseLily":
			_lily(w, h)
		"Fern":
			var base := Vector2(w * 0.5, h)
			for i in range(5):
				var angle: float = -PI * 0.86 + i * PI * 0.18
				var end := base + Vector2(cos(angle), sin(angle)) * (h - 4)
				draw_line(base, end, Color("#4f7958"), 2, false)
				for j in range(2, 7):
					var q: Vector2 = base.lerp(end, j / 7.0)
					var length: float = 8 - j * 0.7
					_box(q.x - length, q.y - 2, length * 2, 3, "#82a56b" if i % 2 == 0 else "#6b945e")
					_box(q.x - length + 1, q.y - 2, length - 1, 1, "#a5b982")
		"Wildflowers":
			var clusters := [Vector2(0.18, 0.35), Vector2(0.28, 0.27), Vector2(0.22, 0.54), Vector2(0.43, 0.67), Vector2(0.51, 0.57), Vector2(0.65, 0.28), Vector2(0.72, 0.39), Vector2(0.67, 0.63), Vector2(0.78, 0.73), Vector2(0.36, 0.38), Vector2(0.54, 0.34)]
			for point in clusters:
				var px: float = floorf(point.x * w)
				var py: float = floorf(point.y * h)
				var q := (Vector2(px, py) - extent * 0.5) / (extent * 0.5)
				if q.length_squared() > 0.9:
					continue
				_box(px, py + 2, 1, 5, "#718d5b")
				_box(px - 2, py, 5, 2, "#e6d7aa" if variant % 2 == 0 else "#c2b6c9")
				_box(px, py - 1, 2, 4, "#ede0bc")
				_box(px, py, 1, 1, "#b49d66")
		"Rock":
			_oval(Rect2(0, h * 0.3, w, h * 0.7), "#8d947c")
			_oval(Rect2(2, 0, w - 4, h - 3), "#b8b79b")
			_box(6, 4, maxf(3, w - 16), 3, "#d1cdb0")
			_box(w * 0.6, h * 0.5, 3, h * 0.3, "#959e82")
		"Arbor":
			_box(6, 20, 10, h - 20, "#aa9166")
			_box(w - 16, 20, 10, h - 20, "#aa9166")
			_box(0, 18, w, 10, "#cfba87")
			for x in range(6, int(w), 16):
				_box(x, 6, 4, 27, "#b8a078")
			for x in range(2, int(w), 20):
				_oval(Rect2(x, 8 + x % 7, 30, 16), "#658c5b")
				_box(x + 8, 14, 4, 4, "#e2c5a0")
			_box(9, 36, 3, h - 40, "#e0c89a")
			_box(w - 13, 36, 3, h - 40, "#e0c89a")
		"Birdbath":
			_oval(Rect2(4, h - 10, w - 8, 10), "#8d997f")
			_box(w * 0.5 - 5, 15, 10, h - 18, "#b7b49a")
			_box(w * 0.5 - 3, 15, 3, h - 20, "#d8ceb0")
			_oval(Rect2(0, 0, w, 22), "#a3a68c")
			_oval(Rect2(3, 2, w - 6, 14), "#7eaaa1")
			_box(8, 5, w - 22, 2, "#c3d1b4")

func _tree_trunk(w: float, h: float) -> void:
	_oval(Rect2(0, h - 22, w + 8, 26), "#748a61")
	var birch: bool = variant % 3 == 1
	var bark: String = "#bbba91" if birch else "#927b53"
	_box(w * 0.5 - 6, h - 44, 12, 40, bark)
	_box(w * 0.5 - 4, h - 42, 4, 35, "#d4cda5" if birch else "#baa06c")
	for y in range(int(h) - 37, int(h) - 6, 9):
		_box(w * 0.5 - 4, y, 5, 2, "#858b70" if birch else "#7d6f4e")
	draw_line(Vector2(w * 0.5, h - 26), Vector2(w * 0.22, h - 70), Color(bark), 6, false)

func _tree_canopy(w: float, h: float) -> void:
	var dark: String = "#537956" if variant % 2 == 0 else "#658253"
	var mid: String = "#7b9d66" if variant % 2 == 0 else "#83a06b"
	var light: String = "#a0b87e" if variant % 2 == 0 else "#adbe86"
	_oval(Rect2(2, 16, w - 4, h - 40), dark)
	var lobes: Array[Rect2] = [Rect2(0, 27, w * 0.57, h * 0.48), Rect2(w * 0.4, 23, w * 0.6, h * 0.49), Rect2(w * 0.12, 3, w * 0.55, h * 0.55), Rect2(w * 0.47, 0, w * 0.42, h * 0.44)]
	for i in range(lobes.size()):
		_oval(lobes[i], mid if i % 2 == 0 else light)
		var inset: Rect2 = lobes[i].grow(-9)
		inset.size.y *= 0.4
		_oval(inset, light)
	for i in range(28):
		var x: float = 12 + (i * 19 + variant * 7) % maxi(1, int(w - 28))
		var y: float = 18 + (i * 13 + variant * 3) % maxi(1, int(h * 0.54 - 18))
		_box(x, y, 5, 2, "#bcc990" if i % 3 == 0 else mid)
		if i % 5 == 0:
			_box(x + 2, y + 3, 3, 2, dark)
	if variant % 7 == 0:
		for i in range(9):
			_box(18 + (i * 13) % maxi(1, int(w - 40)), 22 + (i * 7) % 33, 4, 3, "#dbd3a8")

func _flowers(w: float, h: float) -> void:
	_oval(Rect2(0, 0, w, h), "#ada98a")
	_oval(Rect2(4, 4, w - 8, h - 8), "#7a8660")
	var palettes: Array = [["#b2a8c4", "#c2b6ce", "#ded1bb"], ["#d39987", "#e3b096", "#e7cf9c"], ["#ead9ac", "#daca93", "#d1b1b7"]]
	var colors: Array = palettes[variant % 3]
	for y in range(12, int(h) - 8, 13):
		for x in range(12, int(w) - 8, 14):
			var q := (Vector2(x, y) - extent * 0.5) / (extent * 0.5 - Vector2(6, 6))
			if q.length_squared() > 0.85:
				continue
			var px: float = x + (y * 3 + x * 7 + variant) % 9 - 4
			var py: float = y + (x * 7 + y * 3 + variant) % 9 - 4
			_box(px, py + 2, 2, 6, "#59784d")
			_box(px - 4, py + 5, 5, 2, "#9aac75")
			var color: String = colors[(int(x / 14) + variant) % colors.size()]
			_box(px - 3, py, 8, 4, color)
			_box(px - 1, py - 2, 4, 8, color)
			_box(px, py + 1, 2, 2, "#f1dfa5")

func _gazebo_base(w: float, h: float) -> void:
	_oval(Rect2(-8, 36, w + 16, h - 18), "#71815e")
	draw_colored_polygon(PackedVector2Array([Vector2(24, 40), Vector2(w - 24, 40), Vector2(w, 64), Vector2(w, h - 24), Vector2(w - 24, h), Vector2(24, h), Vector2(0, h - 24), Vector2(0, 64)]), Color("#9d865e"))
	draw_colored_polygon(PackedVector2Array([Vector2(26, 47), Vector2(w - 26, 47), Vector2(w - 7, 67), Vector2(w - 7, h - 27), Vector2(w - 27, h - 7), Vector2(27, h - 7), Vector2(7, h - 27), Vector2(7, 67)]), Color("#cfb787"))
	for y in range(80, int(h) - 12, 12):
		_box(16, y, w - 32, 1, "#b79e70")
		for x in range(30 + (y % 24) * 2, int(w) - 16, 48):
			_box(x, y - 10, 1, 10, "#bfa777")
	_box(22, 75, 9, h - 91, "#9c8159")
	_box(w - 31, 75, 9, h - 91, "#9c8159")
	for x in [34.0, w - 46]:
		_box(x, 64, 12, 38, "#947952")
		_box(x + 2, 66, 4, 32, "#e2c99a")
		_box(x - 2, 95, 16, 7, "#b39c71")
	_box(24, 60, w - 48, 8, "#9c8159")
	_box(26, 60, w - 52, 2, "#d0b57e")
	_box(w * 0.5 - 39, h - 4, 78, 5, "#bca57c")
	_box(w * 0.5 - 43, h + 2, 86, 4, "#d6c39a")

func _gazebo_roof(w: float) -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-4, 48), Vector2(40, 12), Vector2(w * 0.5, -12), Vector2(w - 40, 12), Vector2(w + 4, 48), Vector2(w - 28, 76), Vector2(28, 76)]), Color("#526f65"))
	draw_colored_polygon(PackedVector2Array([Vector2(4, 45), Vector2(44, 16), Vector2(w * 0.5, -7), Vector2(w - 44, 16), Vector2(w - 4, 45), Vector2(w - 31, 66), Vector2(31, 66)]), Color("#7caa99"))
	for x in range(30, int(w) - 20, 24):
		draw_line(Vector2(w * 0.5, -3), Vector2(x, 63), Color("#669487"), 2, false)
	for y in range(18, 60, 10):
		var left: int = int(w * 0.5 - (w * 0.5 - 9) * (y + 12) / 76.0)
		for x in range(left, int(w) - left, 12):
			_box(x, y, 8, 1, "#91b5a0")
	_box(27, 68, w - 54, 5, "#d0b57e")
	_box(w * 0.5 - 4, -20, 8, 15, "#c0ac76")
	_box(w * 0.5 - 7, -20, 14, 3, "#dfc694")

func _gazebo_front(w: float, _h: float) -> void:
	for x in [18.0, w - 30]:
		_box(x, -32, 12, 38, "#947952")
		_box(x + 2, -30, 4, 32, "#e2c99a")
		_box(x - 2, -1, 16, 7, "#b39c71")
	for x in [24.0, w - 88]:
		_box(x, -8, 64, 4, "#a58a5f")
		_box(x, -8, 64, 1, "#ddc495")
		_box(x, 3, 64, 4, "#b89d6c")
		for rail_x in range(int(x) + 6, int(x) + 62, 14):
			_box(rail_x, -4, 3, 9, "#947d56")

func _lily(w: float, h: float) -> void:
	var c := Vector2(w * 0.5, h * 0.5)
	_oval(Rect2(0, h - 34, w, 32), "#70885b")
	for side in [-1, 1]:
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, 20), c + Vector2(side * 47, 11), c + Vector2(side * 39, 36), c + Vector2(side * 9, 33)]), Color("#668459"))
		draw_line(c + Vector2(0, 24), c + Vector2(side * 36, 26), Color("#a2ae77"), 2, false)
	var palette: Array[String] = ["#c48773", "#d39a80", "#bc806d", "#cf937e", "#c98c77"]
	for i in range(5):
		var a: float = -PI * 0.5 + i * TAU / 5.0
		var d := Vector2(cos(a), sin(a))
		var t := Vector2(-d.y, d.x)
		var polygon := PackedVector2Array()
		for p in [Vector2(15, -10), Vector2(30, -19), Vector2(43, -13), Vector2(48, -2), Vector2(44, 12), Vector2(30, 20), Vector2(14, 10)]:
			polygon.append((c + d * p.x + t * p.y).snapped(Vector2(2, 2)))
		draw_colored_polygon(polygon, Color(palette[i]))
		var fold := PackedVector2Array([(c + d * 17).snapped(Vector2(2, 2)), (c + d * 39 + t * 9).snapped(Vector2(2, 2)), (c + d * 43).snapped(Vector2(2, 2)), (c + d * 26 - t * 3).snapped(Vector2(2, 2))])
		draw_colored_polygon(fold, Color("#dca58c"))
		draw_line((c + d * 22 - t * 6).snapped(Vector2(2, 2)), (c + d * 39 - t * 6).snapped(Vector2(2, 2)), Color("#b57d6b"), 2, false)
		for k in range(4):
			var spot: Vector2 = (c + d * (27 + k * 4) + t * (-7 + k % 3 * 6)).snapped(Vector2(2, 2))
			_box(spot.x, spot.y, 3, 2, "#e9c8a1")
	_oval(Rect2(c - Vector2(19, 16), Vector2(38, 32)), "#937951")
	_oval(Rect2(c - Vector2(15, 13), Vector2(30, 26)), "#dfbd88")
	_oval(Rect2(c - Vector2(10, 9), Vector2(20, 18)), "#776e4e")
	_box(c.x - 3, c.y - 4, 6, 6, "#a99864")
	_box(c.x - 1, c.y - 6, 2, 3, "#e2c99b")

func occlusion_ellipses() -> Array[Rect2]:
	if kind != "TreeCanopy":
		return []
	var w: float = extent.x
	var h: float = extent.y
	return [Rect2(2, 16, w - 4, h - 40), Rect2(0, 27, w * 0.57, h * 0.48), Rect2(w * 0.4, 23, w * 0.6, h * 0.49), Rect2(w * 0.12, 3, w * 0.55, h * 0.55), Rect2(w * 0.47, 0, w * 0.42, h * 0.44)]

func occlusion_polygon() -> PackedVector2Array:
	if kind != "GazeboRoof":
		return PackedVector2Array()
	var w: float = extent.x
	return PackedVector2Array([Vector2(-4, 48), Vector2(40, 12), Vector2(w * 0.5, -12), Vector2(w - 40, 12), Vector2(w + 4, 48), Vector2(w - 28, 76), Vector2(28, 76)])

func _box(x: float, y: float, w: float, h: float, color: String) -> void:
	draw_rect(Rect2(x, y, w, h), Color(color))

func _oval(rect: Rect2, color: String) -> void:
	var c: Vector2 = rect.get_center()
	for y in range(int(rect.position.y), int(rect.end.y), 4):
		var t: float = (y + 2 - c.y) / (rect.size.y * 0.5)
		var half: float = floorf(sqrt(maxf(0, 1 - t * t)) * rect.size.x * 0.25) * 2
		if half > 0:
			_box(c.x - half, y, half * 2, 4, color)

