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

var player_current_world
var players
var id

func _ready():
	player_current_world = str(player_registrar.players[int(gamestate.net_id)].current_world)
	players = get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid/")

	print("(Player) Current World: ", player_current_world)

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
		
		# Figure Out How To Only Send RPC Packets to Clients only in Current World
		# This rpc acts weird. It was causing spamming at first (which caused my laptop to get really hot), but as I tried to fix it, the problem only got worse.
		# Now, the weird thing is, I reverted back to the old code and it works fine (minus a temporary delay where a playernode wasn't spawned back in). This only happens when switching worlds.
		rpc("movePlayer", motion) #rpc_unreliable("movePlayer", motion) - Disabled until correcting coordinates exists
		motion = move_and_slide(motion)
		
# puppet (formerly slave) sets for all devices except server - Should this be puppet?
puppet func movePlayer(mot):
	motion = move_and_slide(mot)
	
# Sets Player's Color (also sets other players colors too)
func set_dominant_color(color):
	$CollisionShape2D/Sprite.modulate = color # Changes the Player's Color in the World