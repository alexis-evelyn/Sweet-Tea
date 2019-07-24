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
	var added_username = "" # Used for Custom Username Formatting
	var net_id = -1 # Invalid NetID (will be corrected later)
	var chat_color = "red" # Default Chat Color
	
	# Record Chat Message in Server Log (e.g. if harassment needs to be reported)
	print("Chat Message: ", message)
	
	# Check and Shorten The Length of Characters in Message
	if message.length() > max_characters:
		message = message.substr(0, max_characters)
	
	# Get's The Sender's NetID
	if get_tree().get_rpc_sender_id() == 0:
		net_id = gamestate.player_info.net_id
	elif network.players.has(get_tree().get_rpc_sender_id()):
		net_id = get_tree().get_rpc_sender_id()

	# Check to See if Message is a Command
	if message.substr(0,1) == "/":
		var response = $commands.process_command(net_id, message)
		
		#if response != null and response != "":
		#	rpc_id(net_id, "chat_message_client", response)
		
		return # Prevents executing the rest of the function

	# Set Color for Player's Username
	chat_color = "#" + network.players[int(net_id)].char_color # For now, I am specify chat color as color of character. I may change how color is set later.

	# Insert No Width Space After Open Bracket to Prevent BBCode - Should be able to be turned on and off by server (scratch that, let the server inject bbcode in if it approves the code or command)
	message = message.replace("[", "[" + NWSC)

	# The URL Idea Came From: https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html?highlight=bbcode#signals
	var username_start = "[url={\"player_net_id\":\"" + str(net_id) + "\"}][color=" + chat_color + "][b][u]"
	var username_end = "[/u][/b][/color][/url]"
	added_username = "<" + username_start + str(network.players[int(net_id)].name) + username_end + "> " + message

	rpc("chat_message_client", added_username)

# Send Chat To Server
func _on_userChat_gui_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and chat.text.rstrip(" ").lstrip(" ") != "":
			print("Enter Key Pressed!!!")
			rpc_id(1, "chat_message_server", chat.text)
			chat.text = ""

# When URLs are Clicked in Chat Window
func _on_chatMessages_meta_clicked(meta):
	if typeof(meta) == TYPE_STRING:
		print("URL Text: ", meta)
		
		var json = JSON.parse(meta)
		
		# Checks to Make Sure JSON was Parsed
		if json.error == OK:
			print("JSON Type: ", typeof(json.result))
			
			# JSON will either be a Dictionary or Array. If it is an object, you forgot to call json.result (instead you called json)
			if typeof(json.result) == TYPE_DICTIONARY: # Type 18 (Under Variant.Type) - https://docs.godotengine.org/en/3.1/classes/class_@globalscope.html
				print("JSON is Dictionary")
			
				handle_url_click(json.result) # Send to another function to process
			elif typeof(json.result) == TYPE_ARRAY: # Type 19 (Under Variant.Type) - https://docs.godotengine.org/en/3.1/classes/class_@globalscope.html
				print("JSON is Array")
			elif typeof(json.result) == TYPE_OBJECT: # 17 - Means You Didn't Grab .result
				print("JSON is Object")
				
# Handles Client Clicking on URL
func handle_url_click(dictionary):
	# Checks to Make Sure Metadata Is What We Expect (Server Could Send Something Different)
	if dictionary.has("player_net_id"):
		var net_id = dictionary["player_net_id"]
		
		# Checks if Players Dictionary Has Net_ID (player could have disconnected by then)
		if network.players.has(int(net_id)):
			print("Clicked Player Name: " + network.players[int(net_id)].name + " Player ID: " + net_id)
			chat_message_client("Clicked Player Name: " + network.players[int(net_id)].name + " Player ID: " + net_id)
		else:
			print("The Players Dictionary is Missing ID: ", net_id)