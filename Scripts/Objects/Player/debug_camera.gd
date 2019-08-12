extends Camera2D

# Declare member variables here. Examples:
var cam_speed = 70
var player
onready var coor_label = $PlayerCoordinates
onready var cam_coor_label = $CameraCoordinates
onready var crosshair = $Crosshair

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_theme(gamestate.game_theme)
	set_physics_process(true)
	
	player = get_player_node()

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
		
	# Player's position is based on center of Player, not the edges
	if player != null:
		coor_label.text = "Player: " + str(player.position)
	
	# Get Builtin Screen Size and Find center of screen (add center coordinates to coordinates of camera)
	# This helps locate where the crosshair is (which is only a visual reference for the user. The gdscript does not get position from crosshair)
	var cross_x = self.position.x + (ProjectSettings.get_setting("display/window/size/width")/2)
	var cross_y = self.position.y + (ProjectSettings.get_setting("display/window/size/height")/2)
	var cross_coor = Vector2(cross_x, cross_y)
	
	# Prints center of screen's position in world
	cam_coor_label.text = "Camera: " + str(cross_coor)

# Sets Debug Label's Theme
func set_theme(theme: Theme) -> void:
	#get_node("Coordinates").set_theme(theme)
	#coor_label.align = Label.ALIGN_CENTER # Aligns the Text To Center
	
	# Something here is broken.
	coor_label.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres"))
	cam_coor_label.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres"))
	crosshair.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres"))

func get_player_node() -> Node:
	print("Parent: ", get_parent().name)
	
	var players = get_parent().get_node("WorldGrid/Players")
	
	return players.get_node(str(gamestate.net_id)).get_node("KinematicBody2D")
