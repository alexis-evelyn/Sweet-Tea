extends Control

onready var server_address : Node = $panelNetwork/manualJoin/txtServerAddress
onready var join_server : Node = $panelNetwork/manualJoin/btnJoinServer

var lan_client : String = "res://Scripts/lan/client.gd"

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	functions.set_title(tr("network_menu_title"))
	
	set_language_text()
	set_theme(gamestate.game_theme)
	find_servers()
	
func set_language_text():
	server_address.placeholder_text = tr("network_menu_address_placeholder")
	join_server.text = tr("network_menu_join_server_button")
	
func find_servers() -> void:
	# Setup Broadcast Listener Script
	var server_finder = Node.new()
	server_finder.set_script(load(lan_client)) # Attach A Script to Node
	server_finder.set_name("ServerFinder") # Give Node A Unique ID
	add_child(server_finder)

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
