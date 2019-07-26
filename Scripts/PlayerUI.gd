extends CanvasLayer

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
	if Input.is_key_pressed(KEY_TAB):
		panelPlayerList.visible = true
	else:
		panelPlayerList.visible = false
	
	# Makes Chat Window Visible
	if Input.is_key_pressed(KEY_SLASH) and !panelChat.visible:
		panelChat.visible = true
		panelChat.get_node("userChat").grab_focus() # Causes LineEdit (where user types) to grab focus of keyboard
		panelChat.get_node("userChat").set_text("/") # Replaces text with a Forward Slash
		panelChat.get_node("userChat").set_cursor_position(1) # Moves Caret In Front of Slash
	
	if Input.is_key_pressed(KEY_ENTER) and !panelChat.visible:
		panelChat.visible = true
		panelChat.get_node("userChat").grab_focus() # Causes LineEdit (where user types) to grab focus of keyboard
	
	# Makes Chat Window Invisible
	if Input.is_key_pressed(KEY_ESCAPE) and panelChat.visible:
		panelChat.visible = false
	
	# Closes Connection (Client and Server)
	if Input.is_key_pressed(KEY_Q) and !panelChat.visible:
		network.close_connection()
		
	# Kicks Player (Server) - Will be replaced by chat command
	if Input.is_key_pressed(KEY_K) and !panelChat.visible:
		network.kick_player()
		
	# Bans Player (Server) - Will be replaced by chat command
	if Input.is_key_pressed(KEY_B) and !panelChat.visible:
		network.ban_player()
	
	# Bans IP (Server) - Will be replaced by chat command
	if Input.is_key_pressed(KEY_N) and !panelChat.visible:
		network.ban_ip_address()

# Just a reference to Cleanup() - Standardize References
func clear():
	cleanup()

# Cleanup PlayerUI
func cleanup():
	print("Cleanup PlayerUI")
	
	panelStats.cleanup() # Call PlayerStats's Cleanup Function
	panelChat.cleanup() # Call PlayerChat's Cleanup Function
	panelPlayerList.cleanup() # Call PlayerList's Cleanup Function

# Sets PlayerUI Theme
func set_theme(theme):
	$panelPlayerList.set_theme(theme)
	$panelPlayerStats.set_theme(theme)
	$panelChat.set_theme(theme)