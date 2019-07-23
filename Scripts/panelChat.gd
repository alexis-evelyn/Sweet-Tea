extends Panel

# Declare member variables here. Examples:
var max_lines = 500 # Max lines in chat before lines are deleted) - Should be settable by user
var max_characters = 500 # Max number of characters in line before cut off - Should be settable by user and server (server overrides user)

# The NWSC is used to break up BBCode submitted by user without deleting characters - Should be able to be disabled by Server Request
var NWSC = PoolByteArray(['U+8203']).get_string_from_utf8() # No Width Space Character (Used to be called RawArray?) - https://docs.godotengine.org/en/3.1/classes/class_poolbytearray.html

onready var chatMessages = $chatMessages
onready var chat = $userChat

# Called when the node enters the scene tree for the first time.
func _ready():
	chat.set_max_length(max_characters)
	
	chat.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	
	# RichTextLabel Fonts
	chatMessages.set("custom_fonts/normal_font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	chatMessages.set("custom_fonts/bold_font", load("res://Fonts/dynamicfont/firacode-bold.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	
	chatMessages.set_scroll_follow(true) # Sets RichTextLabel to AutoScroll if at Bottom

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Process Chat Messages from Server
sync func chat_message_client(message):
	print("Client Message: ", message)
	
	#chatMessages.add_text(message + "\n") # append_bbcode() will allow formatted text without writing a custom interpreter (maybe let servers choose if it is allowed? How about fine grained control?).
	chatMessages.append_bbcode(message + "\n") # Appends Text while Supporting BBCode from Server
	
	if chatMessages.get_line_count() > max_lines:
		chatMessages.remove_line(0)
	
# Process Chat Message from Client
master func chat_message_server(message):
	var addedUsername = ""
	var netid = -1
	
	print("Chat Message: ", message)
	
	if message.length() > max_characters:
		message = message.substr(0, max_characters)
	
	# Insert No Width Space After Open Bracket to Prevent BBCode - Should be able to be turned on and off by server (scratch that, let the server inject bbcode in if it approves the code or command)
	message = message.replace("[", "[" + NWSC)
	
	# Get's The Sender's NetID
	if get_tree().get_rpc_sender_id() == 0:
		netid = gamestate.player_info.net_id
	elif network.players.has(get_tree().get_rpc_sender_id()):
		netid = get_tree().get_rpc_sender_id()

	# The URL Idea Came From: https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html?highlight=bbcode#signals
	var username_start = "[url={\"player_net_id\"=\"" + str(netid) + "\"}][color=red][b][u]"
	var username_end = "[/u][/b][/color][/url]"
	addedUsername = "<" + username_start + str(network.players[netid].name) + username_end + "> " + message

	rpc("chat_message_client", addedUsername)

# Send Chat To Server
func _on_userChat_gui_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and chat.text.rstrip(" ").lstrip(" ") != "":
			print("Enter Key Pressed!!!")
			rpc_id(1, "chat_message_server", chat.text)
			chat.text = ""
