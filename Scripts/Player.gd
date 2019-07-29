extends KinematicBody2D

# Declare member variables here:
onready var panelChat = get_tree().get_root().get_node("PlayerUI/panelChat")

const UP = Vector2(0, -1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)

const ACCELERATION = 50
#const GRAVITY = 20
const MAX_SPEED = 200
#const JUMP_HEIGHT = -500
var friction = false

var motion = Vector2()

var player_name
var player_current_world
var players

# Called everytime player is spawned 
func _ready():
	player_name = get_node("..").name
	player_current_world = get_node("../../../../../").name # Get Current World's Name (for this player node - used by server-side)
	print("(Player) Current World: ", player_current_world)

func _process(_delta):
	# Server corrects coordinates of client to keep in sync
	if get_tree().is_network_server():
		#rpc_unreliable("correct_coordinates", self.position)
		
		if (int(abs(motion.x)) != int(abs(0))) or (int(abs(motion.y)) != int(abs(0))):
			# Get All Players in This Player's World
			players = get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid/Players/")
			
			# Loop Through All Players
			for player in players.get_children():
				if int(player.name) != 1:
					rpc_unreliable_id(int(player.name), "correct_coordinates", self.position)
		
		# This fixes the sync issue, but it won't play nice with clients not in same world.
		# TODO: Detect motion and if moving, start correcting coordinates of player (I want to wait for motion, so the server is not constantly running a for loop and heating up the computer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	# Checks to See if in Server/Client Mode (I may have a server always started, but refuse connections in single player. That is still up to debate).
	if not get_tree().has_network_peer():
		return -1 # Should Be Connected Here
	
	if is_network_master():
		if Input.is_key_pressed(KEY_W) and !panelChat.visible:
			#print("Up")
			motion.y = max(motion.y - ACCELERATION, -MAX_SPEED)
		elif Input.is_key_pressed(KEY_S) and !panelChat.visible:
			#print("Down")
			motion.y = min(motion.y + ACCELERATION, MAX_SPEED)
		else:
			friction = true;
			#$Sprite.play("Idle");
			
		if Input.is_key_pressed(KEY_A) and !panelChat.visible:
			#print("Left")
			motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		elif Input.is_key_pressed(KEY_D) and !panelChat.visible:
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
func send_to_clients(mot: Vector2):
	# Get All Players in This Player's World
	players = get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid/Players/")
	
	# Loop Through All Players
	for player in players.get_children():
		# Note: I could take away the calling player's ability to move from client side and have the server move the calling player.
		if (int(gamestate.net_id) != int(player.name)):
			#print("Sending To: ", player.name)
			rpc_unreliable_id(int(player.name), "move_player", mot)

# puppet (formerly slave) sets for all devices except master (the calling client)
puppet func move_player(mot: Vector2):
	move_and_slide(mot) # This works because this move_and_slide is tied to this node (even on the other clients).
	
# Could also be used for teleporting (designed to correct coordinates from lag, etc...)
# Server is also guilty of getting out of sync with client, but server is arbiter and executor, so it overrides other clients positions
remotesync func correct_coordinates(coordinates: Vector2):
	#print(coordinates)
	self.position = coordinates
	
# Sets Player's Color (also sets other players colors too)
func set_dominant_color(color):
	$CollisionShape2D/Sprite.modulate = color # Changes the Player's Color in the World