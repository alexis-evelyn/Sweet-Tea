extends Camera2D

# Declare member variables here. Examples:
var cam_speed = 70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("debug_up"):
		translate(Vector2(0, -cam_speed))
	if Input.is_action_pressed("debug_down"):
		translate(Vector2(0, cam_speed))
	if Input.is_action_pressed("debug_left"):
		translate(Vector2(-cam_speed, 0))
	if Input.is_action_pressed("debug_right"):
		translate(Vector2(cam_speed, 0))
