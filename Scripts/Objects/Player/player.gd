extends KinematicBody2D

# Declare member variables here:
onready var panelChat : Node = get_tree().get_root().get_node("PlayerUI/panelChat")

const UP : Vector2 = Vector2(0, -1)
const LEFT : Vector2 = Vector2(-1, 0)
const RIGHT : Vector2 = Vector2(1, 0)
const DOWN : Vector2 = Vector2(0, 1)

const ACCELERATION : int = 50
#const GRAVITY : int = 20
const MAX_SPEED : int = 200
#const JUMP_HEIGHT : int = -500
var friction : bool = false

var motion : Vector2 = Vector2()

var player_name: String
var players: Node
var world_generator: Node

var camera: Node

# Called everytime player is spawned 
func _ready() -> void:
	# Get Player's ID
	player_name = get_node("..").name
	
	# Get All Players in This Player's World
	players = get_parent().get_parent()
	
	# Get's World Generator Node (of Current World)
	world_generator = get_parent().get_parent().get_parent().get_node("WorldGen")

	# Checks to See if in Server/Client Mode (I may have a server always started, but refuse connections in single player. That is still up to debate).
	if not get_tree().has_network_peer():
		return # Should Be Connected Here
	
	# Activate Debug Camera if Gamestate Debug Camera Boolean is True
	if is_network_master():
		if gamestate.debug:
			debug_camera(true)
		else:
			player_camera(true)
	
	# Server corrects coordinates of client to keep in sync
	if get_tree().is_network_server():
		world_generator.load_chunks(int(player_name), self.position, true) # Allows Getting Chunks Before Moving
		
		var correct_coordinates_timer : Timer = Timer.new()
		correct_coordinates_timer.name = "correct_coordinates_timer"
		
		# Root of Player Node Will be Busy Setting up Children Right Now, so Defer Adding Another Child For Now
		get_parent().call_deferred("add_child", correct_coordinates_timer) # Add Timer to Root of Player Node
		
		correct_coordinates_timer.connect("timeout", self, "correct_coordinates_server") # Function to Execute After Timer Runs Out
		
		# Every Quarter of A Second Seems to Produce the Most Seamless Experience without Causing the Server to Catch Fire
		# This still needs to be tested in an environment with real latency. The Wait Time Should Be Configurable.
		correct_coordinates_timer.set_wait_time(0.05) # Execute Every Fifth of a Second (almost completely smooth and keeps laptop cool with just one client)
		correct_coordinates_timer.start() # Start Timer
	elif is_network_master() and gamestate.debug:
		world_generator.center_chunk(self.position, true) # Allows DebugCamera to be Updated on Chunk Position

# Called before every rendered frame.
func _process(_delta: float) -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# Checks to See if in Server/Client Mode (I may have a server always started, but refuse connections in single player. That is still up to debate).
	if not get_tree().has_network_peer():
		return # Should Be Connected Here
	
	if is_network_master():
		if Input.is_action_pressed("move_up") and !panelChat.visible:
#			logger.superverbose("Up")
			motion.y = max(motion.y - ACCELERATION, -MAX_SPEED)
		elif Input.is_action_pressed("move_down") and !panelChat.visible:
#			logger.superverbose("Down")
			motion.y = min(motion.y + ACCELERATION, MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");
			
		if Input.is_action_pressed("move_left") and !panelChat.visible:
#			logger.superverbose("Left")
			motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		elif Input.is_action_pressed("move_right") and !panelChat.visible:
#			logger.superverbose("Right")
			motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");
		
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
			motion.y = lerp(motion.y, 0, 0.2)
			friction = false
		
		#if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))):
		if motion.abs() != Vector2(0, 0):
			logger.superverbose("Motion: (%s, %s)" % [abs(motion.x), abs(motion.y)])
			motion = move_and_slide(motion)
			send_to_clients(motion)
			
			# Load Chunks to Send to Server Player
			if get_tree().is_network_server():
				world_generator.load_chunks(gamestate.net_id, self.position)
			elif is_network_master() and gamestate.debug:
				world_generator.center_chunk(self.position, true) # Allows DebugCamera to be Updated on Chunk Position

# Handles relaying client's position to other clients in same world
func send_to_clients(mot: Vector2) -> void:
	# Loop Through All Players
	for player in players.get_children():
		# Make sure to not send to self or server (server will be told about it later)
		if (int(gamestate.net_id) != int(player.name)) and (1 != int(player.name)):
			#logger.verbose("Sending To: %s" % player.name)
			rpc_unreliable_id(int(player.name), "move_player", mot)

	# Send copy to server regardless of it is in the world - Server won't update otherwise if not in same world
	if int(gamestate.net_id) != 1:
		rpc_unreliable_id(1, "move_player", mot)

# puppet (formerly slave) sets for all devices except master (the calling client)
puppet func move_player(mot: Vector2) -> void:
	# https://github.com/godotengine/godot/blob/71a6d2cd17b9b48027a6a36b4e7b8adee0eb373c/servers/physics_2d/physics_2d_server_sw.cpp#L1064
	# Condition ' body->get_space()->is_locked() ' is true. returned: false
	# This error is heavily dependent on how smoothly the client can move (the faster the timer ends on correcting coordinates, the less of this error that will show up when a player decides to change to the opposite direction all of a sudden).
	# I think this error is a movement check (making sure the KinematicBody2d is not stuck). Hence, why it triggers on move_and_slide(...). It fails the space locked test in body_test_ray_separation of Godot's physics engine code.
	# Adjust timer to your needs. The faster the timer, the smoother the player movement on client side. The slower the timer, the less processing power the server needs to correct coordinates. Timer will cause jerky movement when lagging.
	
	# Can test_move(...) be used to make is_locked() stop complaining? This function is server side as the player's client is the master of this node.
	move_and_slide(mot) # This works because this move_and_slide is tied to this node (even on the other clients).
	
	# Load Chunks to Send to Client
	if get_tree().is_network_server():
		world_generator.load_chunks(get_tree().get_rpc_sender_id(), self.position)
	
# Called by Timer to Correct Client's Coordinates
func correct_coordinates_server() -> void:
	#rpc_unreliable("correct_coordinates", self.position)
		
	#if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))): # Can be used to only send rpc if client is moving (will be slightly off due to latency)
	
	# Loop Through All Players
	for player in players.get_children():
		if int(player.name) != 1:
			rpc_unreliable_id(int(player.name), "correct_coordinates", self.position)
	
# Could also be used for teleporting (designed to correct coordinates from lag, etc...)
# Server is also guilty of getting out of sync with client, but server is arbiter and executor, so it overrides other clients' positions
remotesync func correct_coordinates(coordinates: Vector2) -> void:
	logger.superverbose("Coordinates: %s" % coordinates)
	self.position = coordinates
	
# Sets Player's Color (also sets other players colors too)
func set_dominant_color(color: Color) -> void:
	$CollisionShape2D/Sprite.modulate = color # Changes the Player's Color in the World
	
# I put debug camera here as it is guaranteed that the player is placed in a loaded world by this point
# warning-ignore:unused_argument
func debug_camera(activated : bool = true):
	# The camera is automatically cleaned up when the player is unloaded (e.g. world change)
	if not get_tree().get_root().get_node("Worlds").get_node(player_registrar.players[gamestate.net_id].current_world).get_node("Viewport").has_node("DebugCamera"):
		# Check to Make Sure Camera isn't Already Loaded - Prevents Duplicate Cameras (to save memory)
		camera = load("res://Objects/Players/DebugCamera.tscn").instance()
		camera.name = "DebugCamera"
		
		# This allows me to align camera to World
		get_tree().get_root().get_node("Worlds").get_node(player_registrar.players[gamestate.net_id].current_world).get_node("Viewport").add_child(camera)
		
		# This allows me to align camera to Player
		#add_child(camera)

# I put player camera here as it is guaranteed that the player is placed in a loaded world by this point
# warning-ignore:unused_argument
func player_camera(activated : bool = true):
	# The camera is automatically cleaned up when the player is unloaded (e.g. world change)
	if not has_node("PlayerCamera"):
		# Check to Make Sure Camera isn't Already Loaded - Prevents Duplicate Cameras (to save memory)
		camera = load("res://Objects/Players/PlayerCamera.tscn").instance()
		camera.name = "PlayerCamera"
		
		# This allows me to align camera to Player
		add_child(camera)

# Disable the camera when the player is despawned
func _exit_tree() -> void:
	# When exiting the server, the camera will be freed before this code has a chance to free it.
	# camera.is_inside_tree() checks to see if the camera has already been freed to prevent the game from crashign
	if camera != null and camera.is_inside_tree():
		camera.free()
