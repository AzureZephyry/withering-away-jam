extends CanvasLayer # Changed to CanvasLayer

# Drag your ColorRect child node here in the inspector, or use its path
@onready var color_rect: ColorRect = $ColorRect 

func _ready() -> void:
	# Access the shader on the child ColorRect
	color_rect.material.set_shader_parameter("open_amount", 0.0)
	
	await get_tree().create_timer(1.0).timeout
	play_wake_up_sequence()

func play_wake_up_sequence() -> void:
	var tween = create_tween()
	
	# Blink 1
	tween.tween_property(color_rect.material, "shader_parameter/open_amount", 0.25, 0.4)
	tween.tween_property(color_rect.material, "shader_parameter/open_amount", 0.0, 0.2)
	tween.tween_interval(0.3)
	
	# Blink 2
	tween.tween_property(color_rect.material, "shader_parameter/open_amount", 0.5, 0.6)
	tween.tween_property(color_rect.material, "shader_parameter/open_amount", 0.1, 0.3)
	tween.tween_interval(0.2)
	
	# Final Awake
	tween.tween_property(color_rect.material, "shader_parameter/open_amount", 1.0, 1.5)
	
	# CRITICAL: This deletes the entire effect scene from the game permanently 
	# once the animation finishes, leaving your starting scene completely vanilla.
	tween.tween_callback(queue_free)
