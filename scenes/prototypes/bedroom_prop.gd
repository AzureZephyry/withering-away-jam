@tool
extends Node2D
## Temporary Bedroom drawings; solid shapes live in the room scene.

@export_enum("Bed", "Desk", "Chair", "Dresser", "Rug", "Basket", "Backpack", "Window", "Wall", "Card") var kind: String = "Bed":
	set(value):
		kind = value
		queue_redraw()
@export var extent: Vector2 = Vector2(88, 136):
	set(value):
		extent = value
		queue_redraw()

func box(x: float, y: float, w: float, h: float, color: String) -> void:
	draw_rect(Rect2(x, y, w, h), Color(color))

func _draw() -> void:
	var w: float = extent.x
	var h: float = extent.y
	match kind:
		"Bed":
			box(2, 5, w, h, "#735c48")
			box(0, 0, w, h, "#584b40")
			box(3, 2, w-6, h-5, "#9c805d")
			box(6, 12, w-12, h-22, "#d8d1b9")
			box(8, 15, w-16, 27, "#f0e8d0")
			box(13, 19, w-26, 17, "#ded8c5")
			box(15, 20, w-30, 2, "#f7f0db")
			box(7, 45, w-14, h-58, "#647f88")
			box(7, 45, w-14, 10, "#a7b6af")
			box(9, 57, 4, h-74, "#78939a")
			for x in range(19, int(w)-12, 12):
				box(x, 57, 1, h-73, "#6e8992")
			box(7, h-31, w-14, 13, "#b6a38a")
			box(7, h-27, w-14, 2, "#d1c3a7")
			for x in range(11,int(w)-8,8):
				box(x,h-18,2,3,"#b6a38a")
			box(0, 0, w, 9, "#7a624c")
			box(4, 2, w-8, 2, "#b4976d")
			box(2, h-9, w-4, 7, "#80644b")
			box(5, h-8, w-10, 2, "#b39267")
		"Desk":
			box(3, 5, w, h, "#715941")
			box(0, 0, w, h-3, "#6b5543")
			box(2, 2, w-4, h-8, "#b19570")
			box(4, 3, w-8, 2, "#ceb38a")
			for y in [19, 37]:
				box(4,y,w-8,1,"#a78b67")
			# Laptop, keyboard, mouse mat, books and a small desk lamp.
			box(37,6,43,24,"#424b50")
			box(40,8,37,18,"#7e9ca0")
			box(42,10,16,1,"#c1d0c5")
			box(42,14,24,1,"#a7bcb7")
			box(35,30,47,12,"#87918f")
			for y in [32,35,38]:
				for x in range(39,77,5):
					box(x,y,3,1,"#c1c4b5")
			box(86,29,15,13,"#708078")
			box(91,32,5,7,"#c4c6b8")
			box(7,27,21,12,"#637f80")
			box(9,30,17,7,"#d6cfb7")
			box(10,23,20,5,"#ab7e65")
			box(14,24,12,1,"#e3d6b8")
			box(108,10,14,4,"#6b705e")
			box(114,6,3,14,"#717864")
			box(106,4,18,9,"#d0c19a")
			box(109,5,12,2,"#eee0b7")
			box(4,h-9,24,5,"#907253")
			box(12,h-8,8,1,"#d6bd8a")
		"Chair":
			box(4,5,w-8,h-5,"#4e5856")
			box(2,2,w-4,10,"#607b80")
			box(4,3,w-8,2,"#95a9a3")
			box(4,16,w-8,h-20,"#6e8988")
			box(7,18,w-14,3,"#8ba39b")
			box(0,13,3,h-16,"#5f5e50")
			box(w-3,13,3,h-16,"#5f5e50")
		"Dresser":
			box(2,4,w,h,"#745c45")
			box(0,0,w,h,"#634e3e")
			box(2,2,w-4,h-5,"#a18764")
			box(3,2,w-6,3,"#c2a47a")
			for x in [4.0,w/2+1]:
				for y in [14,29]:
					box(x,y,w/2-5,12,"#b59770")
					box(x+4,y+2,w/2-13,1,"#c4a87e")
					box(x+w/4-5,y+7,8,2,"#655e4c")
			# Folded clothes and a shallow tray.
			box(w-39,5,30,7,"#718a89")
			box(w-36,6,24,2,"#93a8a0")
			box(6,5,18,6,"#806a53")
			box(8,6,14,3,"#d3b77f")
		"Rug":
			box(3,0,w-6,h,"#586d70")
			box(0,3,w,h-6,"#586d70")
			box(5,5,w-10,h-10,"#b6b7a0")
			box(8,8,w-16,h-16,"#7d9490")
			box(13,13,w-26,h-26,"#8ea199")
			for x in range(18,int(w)-15,16):
				box(x,9,4,2,"#d0c5a6")
				box(x,h-11,4,2,"#d0c5a6")
			for y in range(23,int(h)-16,16):
				for x in range(24,int(w)-18,24):
					box(x,y,4,2,"#98aaa0")
			for y in range(7,int(h)-5,6):
				box(0,y,3,2,"#cec5a8")
				box(w-3,y,3,2,"#cec5a8")
			for step in range(7):
				var span: float = (7 - step) * 4
				box(w/2-span/2,h/2+step*2,span,2,"#aab3a0")
				box(w/2-span/2,h/2-step*2-2,span,2,"#aab3a0")
		"Basket":
			box(2,5,w-4,h-5,"#8b7054")
			box(4,7,w-8,h-10,"#b49970")
			for y in range(11,int(h)-3,5):
				box(4,y,w-8,1,"#816d53")
			for x in range(7,int(w)-4,6):
				box(x,9,1,h-13,"#ceb18a")
			box(0,5,w,4,"#c2a27a")
			box(6,0,w-12,8,"#7c9290")
			box(8,1,7,5,"#a0b0a3")
		"Backpack":
			box(7,0,w-14,3,"#4d6266")
			box(4,4,w-8,h-5,"#506b70")
			box(6,5,w-12,h-9,"#718b8c")
			box(7,h-14,w-14,10,"#5e797d")
			box(9,h-13,w-18,1,"#d2bea0")
			box(0,9,4,h-14,"#4d6266")
			box(w-4,9,4,h-14,"#4d6266")
		"Window":
			box(0,0,w,h,"#686c61")
			box(12,3,w-24,h-7,"#98b8b8")
			box(15,5,w-30,8,"#c8d7c8")
			box(16,h-13,w-32,7,"#839e93")
			box(w/2-1,3,3,h-5,"#e0d6b8")
			box(0,h-4,w,4,"#b29d79")
			box(1,1,13,h-5,"#89968b")
			box(w-14,1,13,h-5,"#89968b")
			box(3,3,3,h-9,"#b5bbaa")
			box(w-8,3,3,h-9,"#b5bbaa")
			box(0,0,w,3,"#c4b48e")
		"Wall":
			box(0,0,w,h,"#8c9b98")
			box(0,h-10,w,9,"#b1b8a7")
			for x in range(0,int(w),32):
				box(x,h-9,1,7,"#9ca99c")
			box(0,h-2,w,2,"#736752")
		"Card":
			box(0,1,w,h-1,"#9f8060")
			box(1,0,w-2,h-2,"#e4d9b9")
			box(3,2,w-6,h-6,"#a3b5a7")
			box(4,3,4,3,"#d3c89b")
			box(3,h-6,w-6,2,"#7a9292")
