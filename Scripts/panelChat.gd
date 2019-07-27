extends Panel

# Declare member variables here. Examples:
# TODO: Implement a Way For Server to Notify Client about Chat Char/Lines Limits
var max_lines = 500 # Max lines in chat before lines are deleted) - Should be settable by user
var max_characters = 500 # Max number of characters in line before cut off - Should be settable by user and server (server overrides user)

# The NWSC is used to break up BBCode submitted by user without deleting characters - Should be able to be disabled by Server Request
var NWSC = PoolByteArray(['U+8203']).get_string_from_utf8() # No Width Space Character (Used to be called RawArray?) - https://docs.godotengine.org/en/3.1/classes/class_poolbytearray.html

onready var chatMessages = $chatMessages
onready var chatInput = $userChat

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders
	
	chatInput.set_max_length(max_characters)
	
	chatInput.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	
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
	
	# Only Update ChatBox if Not Headless
	if(OS.has_feature("Server") == false):
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
	#print("Chat Message: ", message) - May Replace With Saving To File (dependent on server owner settings)
	
	# Check and Shorten The Length of Characters in Message
	if message.length() > max_characters:
		message = message.substr(0, max_characters)
	
	# Get's The Sender's NetID
	if get_tree().get_rpc_sender_id() == 0:
		net_id = gamestate.net_id
	elif player_registrar.has(get_tree().get_rpc_sender_id()):
		net_id = get_tree().get_rpc_sender_id()

	# Make Sure Player Registered With Server First (keeps from having unregistered clients chatting)
		if !player_registrar.has(net_id):
			return -1

	# Check to See if Message is a Command
	if message.substr(0,1) == "/":
		var response = $commands.process_command(net_id, message)
		
		#if response != null and response != "":
		#	rpc_id(net_id, "chat_message_client", response)
		
		return # Prevents executing the rest of the function

	# Set Color for Player's Username
	chat_color = "#" + player_registrar.color(int(net_id)) # For now, I am specify chat color as color of character. I may change how color is set later.

	# Insert No Width Space After Open Bracket to Prevent BBCode - Should be able to be turned on and off by server (scratch that, let the server inject bbcode in if it approves the code or command)
	message = message.replace("[", "[" + NWSC)

	# The URL Idea Came From: https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html?highlight=bbcode#signals
	var username_start = "[url={\"player_net_id\":\"" + str(net_id) + "\"}][color=" + chat_color + "][b][u]"
	var username_end = "[/u][/b][/color][/url]"
	added_username = "<" + username_start + str(player_registrar.name(int(net_id))) + username_end + "> " + message

	rpc("chat_message_client", added_username)

# Send Chat To Server
func _on_userChat_gui_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and chatInput.text.rstrip(" ").lstrip(" ") != "":
			#print("Enter Key Pressed!!!")
			rpc_id(1, "chat_message_server", chatInput.text)
			chatInput.text = ""

# When URLs are Clicked in Chat Window
func _on_chatMessages_meta_clicked(meta):
	if typeof(meta) == TYPE_STRING:
		#print("URL Text: ", meta)
		
		var json = JSON.parse(meta)
		
		# Checks to Make Sure JSON was Parsed
		if json.error == OK:
			#print("JSON Type: ", typeof(json.result))
			
			# JSON will either be a Dictionary or Array. If it is an object, you forgot to call json.result (instead you called json)
			match typeof(json.result): # Similar to Switch Statement
				TYPE_DICTIONARY:
					#print("JSON is Dictionary")
					handle_url_click(json.result) # Send to another function to process
				TYPE_ARRAY:
					#print("JSON is Array")
					pass # I may add a handler for this later, but to be honest, a dictionary is much more useful in this context
				TYPE_OBJECT:
					print("JSON is Object and it Shouldn't Be")
				
# Handles Client Clicking on URL
func handle_url_click(dictionary):
	# Checks to Make Sure Metadata Is What We Expect (Server Could Send Something Different)
	if dictionary.has("player_net_id"):
		var net_id = dictionary["player_net_id"]
		
		# Checks if Players Dictionary Has Net_ID (player could have disconnected by then)
		if player_registrar.has(int(net_id)):
			#print("Clicked Player Name: " + player_registrar.name(int(net_id)) + " Player ID: " + net_id)
			chat_message_client("Clicked Player Name: " + player_registrar.name(int(net_id)) + " Player ID: " + net_id)
		else:
			print("The Players Dictionary is Missing ID: ", net_id)
			
# Cleanup PlayerChat - Meant to be Called by PlayerUI
func cleanup():
	#print("Clearing PlayerChat")
	
	self.visible = false # Hides PlayerChat
	chatMessages.clear() # Clear Chat Messages