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

var player_name
var player_current_world
var players

# Called everytime player is spawned 
func _ready() -> void:
	player_name = get_node("..").name
	player_current_world = get_node("../../../../../").name # Get Current World's Name (for this player node - used by server-side)
	#print("(Player) Current World: ", player_current_world)

	# Checks to See if in Server/Client Mode (I may have a server always started, but refuse connections in single player. That is still up to debate).
	if not get_tree().has_network_peer():
		return # Should Be Connected Here
	
	# Server corrects coordinates of client to keep in sync
	if get_tree().is_network_server():
		var correct_coordinates_timer : Timer = Timer.new()
		correct_coordinates_timer.name = "correct_coordinates_timer"
		
		# Root of Player Node Will be Busy Setting up Children Right Now, so Defer Adding Another Child For Now
		get_parent().call_deferred("add_child", correct_coordinates_timer) # Add Timer to Root of Player Node
		
		correct_coordinates_timer.connect("timeout", self, "correct_coordinates_server") # Function to Execute After Timer Runs Out
		
		# Every Quarter of A Second Seems to Produce the Most Seamless Experience without Causing the Server to Catch Fire
		# This still needs to be tested in an environment with real latency. The Wait Time Should Be Configurable.
		correct_coordinates_timer.set_wait_time(0.05) # Execute Every Fifth of a Second (almost completely smooth and keeps laptop cool with just one client)
		correct_coordinates_timer.start() # Start Timer 

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
			#print("Up")
			motion.y = max(motion.y - ACCELERATION, -MAX_SPEED)
		elif Input.is_action_pressed("move_down") and !panelChat.visible:
			#print("Down")
			motion.y = min(motion.y + ACCELERATION, MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");
			
		if Input.is_action_pressed("move_left") and !panelChat.visible:
			#print("Left")
			motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		elif Input.is_action_pressed("move_right") and !panelChat.visible:
			#print("Right")
			motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");
		
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
			motion.y = lerp(motion.y, 0, 0.2)
			friction = false
		
		# TODO (VERY IMPORTANT): Apparently, the client and server positions are just not going to stay synced using the performance saving code.
		# I am probably going to have to sync coordinates from the server to client. May cause rebound issues which I will not like.
		if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))):
			#print("Motion: (", abs(motion.x), ", ", abs(motion.y), ")")
			motion = move_and_slide(motion)
			send_to_clients(motion)

# Handles relaying client's position to other clients in same world
func send_to_clients(mot: Vector2) -> void:
	# Get All Players in This Player's World
	players = get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid/Players/")
	
	# Loop Through All Players
	for player in players.get_children():
		# Make sure to not send to self or server (server will be told about it later)
		if (int(gamestate.net_id) != int(player.name)) and (1 != int(player.name)):
			#print("Sending To: ", player.name)
			rpc_unreliable_id(int(player.name), "move_player", mot)

	# Send copy to server regardless of it is in the world - Server won't update otherwise if not in same world
	if int(gamestate.net_id) != 1:
		rpc_unreliable_id(1, "move_player", mot)

# puppet (formerly slave) sets for all devices except master (the calling client)
puppet func move_player(mot: Vector2) -> void:
	# https://github.com/godotengine/godot/blob/master/servers/physics_2d/physics_2d_server_sw.cpp#L1071
	# Condition ' body->get_space()->is_locked() ' is true. returned: false
	# This error is heavily dependent on how smoothly the client can move (the faster the timer ends on correcting coordinates, the less of this error that will show up when a player decides to change to the opposite direction all of a sudden).
	# I think this error is a movement check (making sure the KinematicBody2d is not stuck). Hence, why it triggers on move_and_slide(...). It fails the space locked test in body_test_ray_separation of Godot's physics engine code.
	# Adjust timer to your needs. The faster the timer, the smoother the player movement on client side. The slower the timer, the less processing power the server needs to correct coordinates. Timer will cause jerky movement when lagging.
	
	move_and_slide(mot) # This works because this move_and_slide is tied to this node (even on the other clients).
	
# Called by Timer to Correct Client's Coordinates
func correct_coordinates_server() -> void:
	#rpc_unreliable("correct_coordinates", self.position)
		
	#if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))): # Can be used to only send rpc if client is moving (will be slightly off due to latency)
	
	# Get All Players in This Player's World
	players = get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid/Players/")
	
	# Loop Through All Players
	for player in players.get_children():
		if int(player.name) != 1:
			rpc_unreliable_id(int(player.name), "correct_coordinates", self.position)
	
# Could also be used for teleporting (designed to correct coordinates from lag, etc...)
# Server is also guilty of getting out of sync with client, but server is arbiter and executor, so it overrides other clients' positions
remotesync func correct_coordinates(coordinates: Vector2) -> void:
	#print(coordinates)
	self.position = coordinates
	
# Sets Player's Color (also sets other players colors too)
func set_dominant_color(color: Color) -> void:
	$CollisionShape2D/Sprite.modulate = color # Changes the Player's Color in the World