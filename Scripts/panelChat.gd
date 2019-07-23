extends Panel

# Declare member variables here. Examples:
onready var chatMessages = $chatMessages
onready var chat = $userChat

# Called when the node enters the scene tree for the first time.
func _ready():
	chat.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	chatMessages.set("custom_fonts/normal_font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	
	chatMessages.set_scroll_follow(true) # Sets RichTextLabel to AutoScroll if at Bottom

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Process Chat Messages from Server
sync func chat_message_client(message):
	print("Client Message: ", message)
	
	chatMessages.add_text(message + "\n")
	
# Process Chat Message from Client
master func chat_message_server(message):
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	print("Chat Message: ", message)
	
	if get_tree().get_rpc_sender_id() == 0:
		var addedUsername = "<" + str(network.players[gamestate.player_info.net_id].name) + "> " + message
		rpc("chat_message_client", addedUsername)
	elif network.players.has(get_tree().get_rpc_sender_id()):
		var addedUsername = "<" + str(network.players[get_tree().get_rpc_sender_id()].name) + "> " + message
		rpc("chat_message_client", addedUsername)

# Send Chat To Server
func _on_userChat_gui_input(event):
	var chat = $userChat
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and chat.text.rstrip(" ").lstrip(" ") != "":
			print("Enter Key Pressed!!!")
			rpc_id(1, "chat_message_server", chat.text)
			chat.text = ""
