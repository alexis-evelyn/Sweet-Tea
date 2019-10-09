extends KinematicBody2D
class_name Player

# Declare member variables here:
onready var panelChat : Panel = get_tree().get_root().get_node("PlayerUI/panelChat")
onready var playerStats : Panel = get_tree().get_root().get_node("PlayerUI/panelPlayerStats")
onready var pauseMenu : Control = get_tree().get_root().get_node("PlayerUI/PauseMenu")

const UP : Vector2 = Vector2(0, -1)
const LEFT : Vector2 = Vector2(-1, 0)
const RIGHT : Vector2 = Vector2(1, 0)
const DOWN : Vector2 = Vector2(0, 1)

const ACCELERATION : int = 50 # Originally 50 (Moonwalk 200)
const GRAVITY : int = 20 # Originally 20 (Moonwalk 20)
const MAX_SPEED : int = 200 # Originally 200 (Moonwalk 400)
const JUMP_HEIGHT : int = -400 # Originally -500 (Moonwalk -500)

const MAX_DASH_SPEED_MULTIPLIER : Vector2 = Vector2(30.0, 30.0) # Max Dash Speeed
const DASH_TIMEOUT : float = 1.0 # How long before allow dash again

const CORRECT_COORDINATES_TIMEOUT : float = 0.05 # Execute Every Fifth of a Second (almost completely smooth and keeps laptop cool with just one client)

# Only apply friction when controls are not actively being used.
# This is meant as a way to implement a sliding stop.
var friction : bool = false # Is player moving?
var gravity_enabled : bool = true # Enable Gravity (and Disable Flying)

#var player_transform : Transform2D = Transform2D(0, get_position())
var motion : Vector2 = Vector2()

var player_name: String
var players: Node
var world_generator: TileMap

var camera: Camera2D

func _enter_tree() -> void:
	# Activate Debug Camera if Gamestate Debug Camera Boolean is True
	# Get the camera initialized immediately so the camera is centered on the player before the player sees the world screen.
	# Works in conjunction with loading screen timer.
	if is_network_master():
		if gamestate.debug:
			debug_camera(true)
		else:
			player_camera(true)

# Called everytime player is spawned
func _ready() -> void:
	if is_network_master():
		# Used to prevent game from freezing on loading screen if player presses movement keys on loading screen.
		set_physics_process(false)
		detect_loading_screen_closed()

	# Get Player's ID
	player_name = get_node("..").name

	# Get All Players in This Player's World
	players = get_parent().get_parent()

	# Get's World Generator Node (of Current World)
	world_generator = get_parent().get_parent().get_parent().get_node("WorldGen")

	# Checks to See if in Server/Client Mode (I may have a server always started, but refuse connections in single player. That is still up to debate).
	if not get_tree().has_network_peer():
		return # Should Be Connected Here

	# Should this be moved to a separate file? - https://www.youtube.com/watch?v=AStJd_Ia2p4
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
		correct_coordinates_timer.set_wait_time(CORRECT_COORDINATES_TIMEOUT) # Execute Every Fifth of a Second (almost completely smooth and keeps laptop cool with just one client)
		correct_coordinates_timer.start() # Start Timer
	elif is_network_master() and gamestate.debug:
		world_generator.center_chunk(self.position, true) # Allows DebugCamera to be Updated on Chunk Position

func detect_loading_screen_closed() -> void:
	if get_tree().get_root().has_node("LoadingScreen"):
		# For Server - Loading Screen
		var loading_screen : LoadingScreen = get_tree().get_root().get_node("LoadingScreen")
		loading_screen.connect("loading_screen_closed", self, "loading_screen_closed")
	else:
		# For Clients - Loading Screen Not Implemented Yet
		loading_screen_closed()

func loading_screen_closed() -> void:
	set_physics_process(true)
	playerStats.show_playerstats()

#	functions.set_world_shader(load("res://Scripts/Shaders/third_party/Official Godot Shaders/sepia.shader"))
#	functions.set_world_shader_param("base", Color.green)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# Checks to See if in Server/Client Mode (I may have a server always started, but refuse connections in single player. That is still up to debate).
	if not get_tree().has_network_peer():
		return # Should Be Connected Here

	if gravity_enabled and not is_on_floor():
		motion.y += GRAVITY
#		move_and_slide(Vector2(0, GRAVITY), UP)

	if not main_loop_events.game_is_focused:
		return

	if is_network_master() and (not pauseMenu.is_paused() or pauseMenu.is_open_to_lan):
		if Input.is_action_pressed("move_up") and !panelChat.visible and not pauseMenu.is_paused():
			if not gravity_enabled:
				friction = false
#				logger.superverbose("Up")

				# Action Strength is a Value Between 0 and 1.
				# The keyboard always produces 1 when pressed.
				# An analog joystick can produce any value.
				# This will allow finer control when a joystick is used.
				motion.y = max((motion.y - ACCELERATION) * Input.get_action_strength("move_up"), -MAX_SPEED)
		elif Input.is_action_pressed("move_down") and !panelChat.visible and not pauseMenu.is_paused():
			if not gravity_enabled:
				friction = false

#				logger.superverbose("Down")
				motion.y = min((motion.y + ACCELERATION) * Input.get_action_strength("move_down"), MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");

		if Input.is_action_pressed("move_left") and !panelChat.visible and not pauseMenu.is_paused():
			friction = false

#			logger.superverbose("Left")
			motion.x = max((motion.x - ACCELERATION) * Input.get_action_strength("move_left"), -MAX_SPEED)
		elif Input.is_action_pressed("move_right") and !panelChat.visible and not pauseMenu.is_paused():
			friction = false

#			logger.superverbose("Right")
			motion.x = min((motion.x + ACCELERATION) * Input.get_action_strength("move_right"), MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");

		if Input.is_action_pressed("player_jump") and !panelChat.visible and not pauseMenu.is_paused():
			# Look at old project for jump code and then add in a feature for detecting how long jump is held.
			if is_on_floor() and gravity_enabled:
				# Why does the jump height get exponentially higher when moving left or right?
				# Fix this!!!
				motion.y = JUMP_HEIGHT

		if is_on_floor():
			if friction:
				motion.x = lerp(motion.x, 0, 0.2)
				motion.y = lerp(motion.y, 0, 0.2)
				friction = false
		elif gravity_enabled:
			motion.x = lerp(motion.x, 0, 0.05)
			motion.y = lerp(motion.y, 0, 0.05)
			friction = false
		elif not gravity_enabled:
			# For When Gravity is Disabled
			if friction:
				motion.x = lerp(motion.x, 0, 0.2)
				motion.y = lerp(motion.y, 0, 0.2)
				friction = false

		#if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))):
		if motion.abs() != Vector2(0, 0):
#			logger.superverbose("Motion: (%s, %s)" % [abs(motion.x), abs(motion.y)])
			motion = move_and_slide(motion, UP)
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
#	player_transform = Transform2D(get_rotation(), get_position())

	# Can test_move(...) be used to make is_locked() stop complaining? This function is server side as the player's client is the master of this node.
	# Yes, test move can severely limit is_locked(), but it causes new problems.
#	if test_move(player_transform, mot):
	move_and_slide(mot) # This works because this move_and_slide is tied to this node (even on the other clients).

	# Load Chunks to Send to Client
	if get_tree().is_network_server():
		world_generator.load_chunks(get_tree().get_rpc_sender_id(), self.position)

# Called by Timer to Correct Client's Coordinates
func correct_coordinates_server() -> void:
	# Replace With A Predictive Formula to Determine Where The Player is Going (May Have To Adjust Timer Too)
	# This is so Client doesn't seem jerky when the connection lags behind too much.

	#rpc_unreliable("correct_coordinates", self.position)

	#if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))): # Can be used to only send rpc if client is moving (will be slightly off due to latency)

	# Loop Through All Players
	for player in players.get_children():
		if int(player.name) != 1:
			rpc_unreliable_id(int(player.name), "correct_coordinates", self.position)

# Could also be used for teleporting (designed to correct coordinates from lag, etc...)
# Server is also guilty of getting out of sync with client, but server is arbiter and executor, so it overrides other clients' positions
remotesync func correct_coordinates(coordinates: Vector2) -> void:
#	logger.superverbose("Coordinates: %s" % coordinates)
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
		camera = preload("res://Objects/Players/DebugCamera.tscn").instance()
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
		camera = preload("res://Objects/Players/PlayerCamera.tscn").instance()
		camera.name = "PlayerCamera"

		# This allows me to align camera to Player
		add_child(camera)

func get_gravity_state() -> bool:
	return self.gravity_enabled

func set_gravity_state(enable_gravity: bool = true) -> void:
	self.gravity_enabled = enable_gravity

# Disable the camera when the player is despawned
func _exit_tree() -> void:
	# When exiting the server, the camera will be freed before this code has a chance to free it.
	# camera.is_inside_tree() checks to see if the camera has already been freed to prevent the game from crashing
	if camera != null and camera.is_inside_tree():
		camera.free()

func get_class() -> String:
	return "Player"
