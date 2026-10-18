extends Label

@export var new_text: String
@export var new_text2: String
@export var wait_time: float
@export var start_delay: float 

func _ready():
	await _type_out(new_text)
	await _type_out(new_text2)
	hide()
	
func _type_out(line: String):
	text = ""
	await get_tree().create_timer(start_delay).timeout
	for i in line:
		text += i
		
		await get_tree().create_timer(wait_time).timeout
	await get_tree().create_timer(1.0).timeout
