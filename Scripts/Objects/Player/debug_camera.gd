extends Camera2D

# Declare member variables here. Examples:
var cam_speed = 70
onready var player = get_player_node()
onready var coor_label = $Coordinates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_theme(gamestate.game_theme)
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
		
	coor_label.text = str(player.position)

# Sets Debug Label's Theme
func set_theme(theme: Theme) -> void:
	#get_node("Coordinates").set_theme(theme)
	#coor_label.align = Label.ALIGN_CENTER # Aligns the Text To Center
	
	# Something here is broken.
	get_node("Coordinates").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres"))

func get_player_node() -> Node:
	print("Parent: ", get_parent().name)
	
	var players = get_parent().get_node("WorldGrid/Players")
	
	return players.get_node(str(gamestate.net_id)).get_node("KinematicBody2D")
