extends Control

onready var server_address : Node = $panelNetwork/manualJoin/txtServerAddress
onready var join_server : Node = $panelNetwork/manualJoin/btnJoinServer
onready var lan_servers : Node = $panelNetwork/lanServers

var lan_client : String = "res://Scripts/lan/client.gd"
var default_icon : Resource = load("res://Assets/Blocks/grass-debug.png")

var max_servers : int = 50 # Apply a maximum number of servers to show
var servers : Array # Keep track of already added servers - to avoid duplicates
var server_list : Dictionary # Used to Store Server Information
var server : String # Server to add to servers list
var used_port : int # Server's Port

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	functions.set_title(tr("network_menu_title"))
	
	set_language_text()
	set_theme(gamestate.game_theme)
	
	setup_server_list() # Setup Server List
	find_servers().connect("add_server", self, "add_server") # Add Server to GUI
	
	# ItemList Handling - https://docs.godotengine.org/en/3.1/classes/class_itemlist.html
	lan_servers.connect("item_selected", self, "item_selected") # Detect Selected Item
	lan_servers.connect("item_activated", self, "item_activated") # Detect When Item Is Double Clicked (or Enter Pressed)
	
func setup_server_list() -> void:
	lan_servers.set_max_columns(1)
	lan_servers.set_icon_mode(ItemList.ICON_MODE_LEFT)
	lan_servers.set_select_mode(ItemList.SELECT_SINGLE)
	lan_servers.set_fixed_icon_size(Vector2(48, 48))
	
func add_server(json: Dictionary, server_ip: String, server_port: int) -> void:
	# If server does not specify port, then the client cannot connect to it, so don't add it to the server list.
	if not json.has("used_port"):
		return
	
	used_port = json.get("used_port")
	server = "%s:%s" % [server_ip, used_port]
	
	# Add Server to List If Not Already on List
	if not servers.has(server):
		servers.append(server) # Add Current Server's Dictionary to Other Dictionary
		#print("Servers: %s" % var2str(servers))
		
		logger.verbose("Server: %s:%s" % [server_ip, server_port])
		logger.verbose("Keys: %s" % json)
		
		# TODO: Make sure to add an icon to represent missing an icon.
		var icon_texture : Texture
		if json.has("icon"):
			# TODO: Detect If Server Icon Says "Not Set". If it does, the server failed to load it.
			var decoded_icon : PoolByteArray = Marshalls.base64_to_raw(json.get("icon"))
			icon_texture = bytes2var(decoded_icon, true)
			
#			logger.superverbose("Got Icon!!!")
		else:
			logger.warn("Missing Icon For Server %s!!!" % server)
			icon_texture = default_icon
			
		if not json.has("name"):
			logger.warn("Server %s Missing Name!!!" % server)
			json.name = tr("default_server_name")
			
		if not json.has("motd"):
			logger.warn("Server %s Missing MOTD!!!" % server)
			json.motd = tr("default_server_motd")
			
		if not json.has("num_players"):
			logger.warn("Missing Number Of Players For Server %s!!!" % server)
			json.num_players = tr("missing_player_count")
			
		if not json.has("max_players"):
			logger.warn("Missing Maximum Number Of Players For Server %s!!!" % server)
			json.max_players = tr("missing_max_player_count")
			
		json.ip_address = server_ip
		server_list = json.duplicate() # Copy The Dictionary For Manipulation
		server_list.erase("icon") # Helps Keep Memory Footprint Smaller
			
		#print("Icon: %s" % icon)
		var server_text : String = (tr("server_list_format") % [json.name, json.motd]) + "    " + tr("player_count_format") % [json.num_players, json.max_players]
		lan_servers.add_item(server_text, icon_texture, true)
		lan_servers.set_item_metadata(lan_servers.get_item_count() - 1, server_list)

func item_selected(index: int) -> void:
	logger.debug("Selected Item: %s" % index)
	print("Metadata: %s" % lan_servers.get_item_metadata(index))
	
func item_activated(index: int) -> void:
	logger.debug("Activated Item: %s" % index)
	print("Metadata: %s" % lan_servers.get_item_metadata(index))
	
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
