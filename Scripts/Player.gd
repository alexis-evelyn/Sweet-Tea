extends KinematicBody2D

# Declare member variables here:
onready var panelChat = get_tree().get_root().get_node("GameWorld/PlayerUI/panelChat") #$PlayerUI/panelChat

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
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
		
		# No Matter How It's Sent (UDP or TCP), If "movePlayer" is received, it is processed.
		rpc("movePlayer", motion) #rpc_unreliable("movePlayer", motion) - Disabled until correcting coordinates exists
		motion = move_and_slide(motion)
		
# puppet (formerly slave) sets for all devices except server
puppet func movePlayer(mot):
	motion = move_and_slide(mot)
	
# Sets Player's Color (also sets other players colors too)
func set_dominant_color(color):
	$CollisionShape2D/Sprite.modulate = color # Changes the Player's Color in the World