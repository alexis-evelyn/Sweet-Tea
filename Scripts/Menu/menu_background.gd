extends ParallaxBackground
class_name MenuBackground

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#$ParallaxLayer.motion_offset.x += SPEED # Allows Background to Move
	pass

func get_class() -> String:
	return "MenuBackground"
