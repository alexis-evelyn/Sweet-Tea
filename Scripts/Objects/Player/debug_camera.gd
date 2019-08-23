extends Camera2D

# NOTE (IMPORTANT): The coordinates are measured in pixels.
# The tilemap quadrant size is 16x16 blocks
# The block size is 32x32 pixels.
# To convert coordinates to chunk positions you need to run the formula ((coordinate_x_or_y/16)/32)
# The decimal after the chunk position shows where in the chunk the coordinate is located (if no decimal, then you are at the start of the chunk).
# You may have to give or take a one depending on if the coordinate was negative or positive.

# Declare member variables here. Examples:
var cam_speed = 70
var player : Node
onready var coor_label = $PlayerCoordinates
onready var cam_coor_label = $CameraCoordinates
onready var chunk_position_label = $ChunkPosition
onready var world_name_label = $WorldName
# warning-ignore:unused_class_variable
onready var crosshair = $Crosshair

onready var world : Node = get_parent().get_parent()
onready var world_generator : Node = world.get_node("Viewport/WorldGrid/WorldGen")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_generator.connect("chunk_change", self, "update_chunk_label")
	
	update_world_label()
	
	set_physics_process(true)
	
	player = get_player_node()
	
	update_camera_pos(player.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("debug_up"):
		translate(Vector2(0, -cam_speed))
	if Input.is_action_pressed("debug_down"):
		translate(Vector2(0, cam_speed))
	if Input.is_action_pressed("debug_left"):
		translate(Vector2(-cam_speed, 0))
	if Input.is_action_pressed("debug_right"):
		translate(Vector2(cam_speed, 0))
	
	update_player_pos_label()
	update_camera_pos_label()

func get_player_node() -> Node:
	#logger.verbose("Parent: ", get_parent().name)
	
	var players : Node
	if get_parent().has_node("WorldGrid/Players"):
		players = get_parent().get_node("WorldGrid/Players")
	
	return players.get_node(str(gamestate.net_id)).get_node("KinematicBody2D")
	
func update_chunk_label(chunk: Vector2) -> void:
	chunk_position_label.text = "Chunk: " + str(chunk)
	
func update_world_label():
	world_name_label.text = "World: " + world.name
	
func update_player_pos_label() -> void:
	# Player's position is based on center of Player, not the edges
	if player != null:
		coor_label.text = "Player: " + str(player.position)
	
func update_camera_pos_label() -> void:
	# Get Builtin Screen Size and Find center of screen (add center coordinates to coordinates of camera)
	# This helps locate where the crosshair is (which is only a visual reference for the user. The gdscript does not get position from crosshair)
	var cross_x = self.position.x + (ProjectSettings.get_setting("display/window/size/width")/2)
	var cross_y = self.position.y + (ProjectSettings.get_setting("display/window/size/height")/2)
	var cross_coor = Vector2(cross_x, cross_y)
	
	# Prints center of screen's position in world
	cam_coor_label.text = "Camera: " + str(cross_coor)

# Relocate Camera to this Specified Position (in middle of screen)
func update_camera_pos(position: Vector2) -> void:
	var cross_x = position.x - (ProjectSettings.get_setting("display/window/size/width")/2)
	var cross_y = position.y - (ProjectSettings.get_setting("display/window/size/height")/2)
	
	self.position = Vector2(cross_x, cross_y)
