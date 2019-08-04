extends CanvasLayer

# Signals
signal cleanup_ui

# Declare member variables here. Examples:
onready var panelPlayerList = $panelPlayerList
onready var panelChat = $panelChat
onready var panelStats = $panelPlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	set_theme(gamestate.game_theme)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Checks to See if connected to server (if not, just return)
	if not get_tree().has_network_peer():
		return 0
	
	# This allows user to see player list (I will eventually add support to change keys and maybe joystick support)
	if Input.is_action_pressed("show_playerlist"):
		panelPlayerList.visible = true
	else:
		panelPlayerList.visible = false
	
	# Makes Chat Window Visible
	if Input.is_action_pressed("chat_command") and !panelChat.visible:
		panelChat.visible = true
		panelChat.get_node("userChat").grab_focus() # Causes LineEdit (where user types) to grab focus of keyboard
		panelChat.get_node("userChat").set_text("/") # Replaces text with a Forward Slash
		panelChat.get_node("userChat").set_cursor_position(1) # Moves Caret In Front of Slash
	
	if Input.is_action_pressed("chat_show") and !panelChat.visible:
		panelChat.visible = true
		panelChat.get_node("userChat").grab_focus() # Causes LineEdit (where user types) to grab focus of keyboard
	
	# Makes Chat Window Invisible
	if Input.is_action_pressed("chat_hide") and panelChat.visible:
		panelChat.visible = false
	
	# Closes Connection (Client and Server)
	# I plan on replacing this with a "pause" menu - it will only pause on singleplayer
	if Input.is_action_pressed("quit_world") and !panelChat.visible:
		network.close_connection()

# Cleanup PlayerUI
func cleanup():
	#print("Cleanup PlayerUI")
	emit_signal("cleanup_ui") # Both Standard Code and Modded Code Should Listen for this Signal

# Sets PlayerUI Theme
func set_theme(theme):
	$panelPlayerList.set_theme(theme)
	$panelPlayerStats.set_theme(theme)
	$panelChat.set_theme(theme)