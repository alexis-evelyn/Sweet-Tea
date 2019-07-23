extends Panel

# Declare member variables here. Examples:
var max_lines = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	var chat = $userChat
	chat.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	# $ScrollContainer.set_scroll_follow(true) # Why doesn't this exist for ScrollContainer?

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Process Chat Messages from Server
sync func chat_message_client(message):
	print("Client Message: ", message)
	
	var chatMessages = $ScrollContainer/chatMessages
	var chatMessage = Label.new()
	chatMessage.text = message
	chatMessage.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	
	if(chatMessages.get_child_count() >= max_lines):
		chatMessages.remove_child(chatMessages.get_child(0))
	
	chatMessages.add_child(chatMessage)
	
	print("V-Scrollbar Position: ", $ScrollContainer.get_v_scroll()) # Current Scroll Position (Starts at 0)
	
	# Pseudo-Code explained in scroll_started/ended
	# Psuedo-Code: if scrollbar.auto = true
		#$ScrollContainer.set_v_scroll($ScrollContainer.MAX_SCROLL)
	
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

# TODO: I am trying to figure out how to detect if the user manually scrolled to the bottom. If the user did scroll to the bottom, autoscroll should be enabled. Otherwise if the user scrolls up, autoscroll turns off.
# What are deadzones?
func _on_ScrollContainer_scroll_ended():
	# I cannot get this to be called. How do I activate it?
	print("Scroll Ended")

func _on_ScrollContainer_scroll_started():
	# I cannot get this to be called. How do I activate it?
	print("Scroll Started")
