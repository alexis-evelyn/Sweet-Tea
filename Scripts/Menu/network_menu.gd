extends Control

onready var server_address : Node = $panelNetwork/manualJoin/txtServerAddress
onready var join_server : Node = $panelNetwork/manualJoin/btnJoinServer
onready var lan_servers : Node = $panelNetwork/lanServers

var lan_client : String = "res://Scripts/lan/client.gd"
var default_icon : Resource = load("res://Assets/Blocks/grass-debug.png")

var max_servers : int = 50 # Apply a maximum number of servers to show
var servers : Array # Keep track of already added servers - to avoid duplicates
var server : String # Server to add to servers list
var used_port : int # Server's Port

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	functions.set_title(tr("network_menu_title"))
	
	set_language_text()
	set_theme(gamestate.game_theme)
	
	setup_server_list() # Setup Server List
	find_servers().connect("add_server", self, "add_server") # Add Server to GUI
	
func setup_server_list() -> void:
	lan_servers.set_max_columns(1)
	lan_servers.set_icon_mode(ItemList.ICON_MODE_LEFT)
	lan_servers.set_select_mode(ItemList.SELECT_SINGLE)
	lan_servers.set_fixed_icon_size(Vector2(48, 48))
	
func add_server(json, server_ip, server_port) -> void:
	# If server does not specify port, then the client cannot connect to it, so don't add it to the server list.
	if not json.has("used_port"):
		return
	
	used_port = json.get("used_port")
	server = "%s:%s" % [server_ip, used_port]
	
	# Add Server to List If Not Already on List
	if not servers.has(server):
		servers.append(server)
		#print("Servers: %s" % var2str(servers))
		
		logger.verbose("Server: %s:%s" % [server_ip, server_port])
		logger.verbose("Keys: %s" % json)
		
		# TODO: Make sure to add an icon to represent missing an icon.
		var icon_texture : Texture
		if json.has("icon"):
#			var encoded_icon : PoolByteArray = Marshalls.base64_to_raw(json.get("icon"))
#			var icon : Image = Image.new()
#			var icon_error = icon.load_png_from_buffer(encoded_icon)
#			var icon_texture : Texture = Texture.new()
#			icon_texture.create_from_image(icon)

			logger.warn("Got Icon!!!")
			icon_texture = load(json.get("icon"))
		else:
			logger.warn("Missing Icon!!!")
			icon_texture = default_icon
			
		if not json.has("name"):
			logger.warn("Server Missing Name!!!")
			
		if not json.has("motd"):
			logger.warn("Server Missing MOTD!!!")
			
		if not json.has("num_player"):
			logger.warn("Missing Number Of Players!!!")
			
		if not json.has("max_players"):
			logger.warn("Missing Maximum Number Of Players!!!")
			
		#print("Icon: %s" % icon)
		lan_servers.add_item(server, icon_texture, true)
	
func set_language_text():
	server_address.placeholder_text = tr("network_menu_address_placeholder")
	join_server.text = tr("network_menu_join_server_button")
	
func find_servers() -> Node:
	# Setup Broadcast Listener Script
	var server_finder = Node.new()
	server_finder.set_script(load(lan_client)) # Attach A Script to Node
	server_finder.set_name("ServerFinder") # Give Node A Unique ID
	add_child(server_finder)
	
	return server_finder

func set_theme(theme: Theme) -> void:
	"""
		Set's Network Menu Theme
		
		Supply Theme Resource
	"""
	
	#.set_theme(theme) # Godot's Version of a super - https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	
	# Different Panels In Network Menu - Will Be Changed After Character Creation is Implemented
	#$panelHost.set_theme(theme)
	$panelNetwork.set_theme(theme)
	#$panelPlayer.set_theme(theme)

func _on_btnJoin_pressed() -> void:
	"""
		Join's Server
		
		Will Call Player Selection Screen Before Attempting To Join Server
		
		Not Meant To Be Called Directly
	"""

	var address : PoolStringArray = ($panelNetwork/manualJoin/txtServerAddress.text).split(":", true, 1)
	
	# If IP Address is Empty, Just Return
	if address.size() == 0 or address[0].rstrip(" ").lstrip(" ") == "":
		logger.error("IP Address in Network Menu is Empty!!!")
		return
	
	var ip : String = address[0]
	var port : int
	
	if address.size() != 2 or address[1].rstrip(" ").lstrip(" ") == "":
		# I will be adding support for scanning the server with server finder whos IP address is listed without a port.
		logger.error("Missing Port Number in Network Menu!!!")
		return
	
	port = int(address[1].rstrip(" ").lstrip(" "))
	
	network.join_server(ip, port)
