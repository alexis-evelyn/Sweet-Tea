extends Node
class_name GameConnection

# Signals
signal server_created # Server Was Successfully Created
signal cleanup_worlds # Cleanup World Handler
signal failed_server # Failed to Start Server - Alert User or Change Ports
# warning-ignore:unused_signal
signal failed_server_finder_helper # Failed to Load Lan Server
# warning-ignore:unused_signal
signal failed_client # Failed to Start Client (Is this necessary?)
signal game_forwarded # UPNP Game Port Forwarded

# Keep Alive Thread
var keep_alive : Thread = Thread.new()

# Other Vars
var connected : bool = false # For GUIs to Determine if Game is Connected

var server_icon : String = "res://Assets/Icons/game_icon.png" # Default Server Icon
var server_icon_resource : Resource
var server_icon_bytes : PoolByteArray
var server_icon_encoded : String

# Lan Broadcast Listener
const lan_server : String = "res://Scripts/lan/server.gd"

# StreamPeerSSL
const enc_server : String = "res://Scripts/Security/server_encryption.gd"
const enc_client : String = "res://Scripts/Security/client_encryption.gd"

# UPNP Game Forwarding
const game_forwarding : String = "res://Scripts/upnp/upnp.gd"

onready var pauseMenu : PauseMenu = get_tree().get_root().get_node("Player_UI/PauseMenu")

# Reference to Player List
onready var playerUI = get_tree().get_root().get_node("Player_UI")
onready var playerList : Panel = get_tree().get_root().get_node("Player_UI/panelPlayerList")
onready var playerStats : Panel = get_tree().get_root().get_node("Player_UI/panelPlayerStats")
onready var playerChat : Panel = get_tree().get_root().get_node("Player_UI/panelChat")

var max_pixel_width : int = 32

var refuse_new_connections : bool = true

# TODO: Make sure to verify the data is valid and coherent
# Server Info to Send to Clients
var server_info : Dictionary = {
	name = "Sweet Tea", # Name of Server
	icon = {
		bytes = functions.not_set_string, # Raw Bytes Encoded In Base64
		width = -1, # Icon Width
		height = -1, # Icon Height
		format = -1, # Image Format
	}, # Server Icon (for Clients to See)
	motd = "A Message Will Be Displayed to Clients Using This...", # Display A Message To Clients Before Player Joins Server
	website = "https://sweet-tea.senorcontento.com/", # Server Owner's Website (to display rules, purchases, etc...)
	num_players = 0, # Display Current Number of Connected Players (so client can see how busy a server is)
	max_players = 4, # Maximum Number of Players (including server player)
	bind_address = "*", # IP Address to Bind To (Use). Asterisk (*) means all available IPs to the Computer.
	used_port = 0, # Host Port
	max_chunks = 3 # Max chunks to send to client (client does not request, server sends based on position of client - this helps mitigate DOS abuse)
}

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "close_connection")

	load_server_icon()
	logger.debug("Game Version: %s" % gamestate.game_version)
#	logger.superverbose("Server Info: %s" % server_info) # This screws with the logging because of the icon

# Loads Server Icon For Transmission to Clients
func load_server_icon():
	var server_icon_file = File.new()
	var server_icon_image : Image

	if server_icon_file.file_exists(server_icon):
		server_icon_resource = load(server_icon)

		# TODO: Shrink and Size Server Icon To Decrease Transmission Size
		# Also, lower quality of high res icons as needed to decrease transmission size
		server_icon_image = server_icon_resource.get_data()
		server_icon_bytes = server_icon_image.get_data() #var2bytes(server_icon_resource, true)
		server_icon_encoded = Marshalls.raw_to_base64(server_icon_bytes)

		if server_icon_image.get_width() == server_icon_image.get_height() and server_icon_image.get_width() <= max_pixel_width:
			server_info.icon.bytes = server_icon_encoded #server_icon_encoded
			server_info.icon.width = server_icon_image.get_width()
			server_info.icon.height = server_icon_image.get_height()
			server_info.icon.format = server_icon_image.get_format()
		else:
			logger.error("Cannot Use Icon!!! Shrink Image Here!!!")


# Attempt to Create Server
# warning-ignore:unused_argument
func start_server() -> void:
	set_port() # Choose A Port to Use
	#logger.verbose("Port: %s" % server_info.used_port) # Print Current Port

	# TODO: Godot supports UDP hole punching and/or UPNP, so this could be useful for non-technical players

	#logger.verbose("Attempting to Create Server on Port %s" % server_info.used_port)
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	# Disabled Because Not Implemented - #logger.verbose("Port: %s" % net.get_port())

	# https://docs.godotengine.org/en/3.1/classes/class_networkedmultiplayerenet.html
	net.set_bind_ip(server_info.bind_address) # Sets the IP Address the Server Binds to

	# https://docs.godotengine.org/en/3.1/classes/class_packetpeer.html#class-packetpeer-property-allow-object-decoding
	net.set_allow_object_decoding(false) # Prevents Allowing An Object to Be Decoded To Prevent Remote Code Execution

	# Could Not Create Server (probably port already in use or Failed Permissions)
	var server_error : int = net.create_server(server_info.used_port, server_info.max_players - 1)
	if (server_error != OK): # The -1 for max players is so the player count correctly matches the max player count (as apparently the max player amount does not include the server player)
		logger.fatal("Failed to create server")
		emit_signal("failed_server", server_error) # Something else will listen for this signal and act accordingly
		return

	net.set_refuse_new_connections(refuse_new_connections) # Refuse New Connections - Can be Disabled By Opening to Lan

	# Disabled Because Not Implemented - #logger.verbose("Port: %s" % net.get_port())

	# Ensures UDP Packets are Ordered (Has less overhead than TCP)
	#net.set_always_ordered(NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED)

	get_tree().set_network_peer(net) # Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	connected = true # Set Connected to True

	# The world_handler loader is intentionally before registering the server player so that the server player will have a current world marked
	emit_signal("server_created") # Notify world_handler That Server Was Created

	forward_game() # Forward Game

	# Activate PlayerList Since Server is Close to Finishing Loading
	if not gamestate.server_mode:
		playerList.loadPlayerList() # Load PlayerList

func start_server_finder_helper() -> void:
	# Setup Broadcast Listener Script (For Clients To Find Server on Lan)
	var broadcast_listener = Node.new()
	broadcast_listener.set_script(preload(lan_server)) # Attach A Script to Node
	broadcast_listener.set_name("BroadcastListener") # Give Node A Unique ID
	get_tree().get_root().add_child(broadcast_listener)

func forward_game() -> void:
	# Setup Encryption Script
	var port_forwarding = Node.new()
	port_forwarding.set_script(preload(game_forwarding)) # Attach A Script to Node
	port_forwarding.set_name("GameForwarding") # Give Node A Unique ID
	get_tree().get_root().add_child(port_forwarding)

	var successful : int = port_forwarding.forward_game(int(server_info.used_port))

	emit_signal("game_forwarded", successful)

func start_encryption_server() -> void:
	# Setup Encryption Script
	var encryption = Node.new()
	encryption.set_script(preload(enc_server)) # Attach A Script to Node
	encryption.set_name("EncryptionServer") # Give Node A Unique ID
	get_tree().get_root().add_child(encryption)

# Attempt to Join Server (Not Connected Yet)
func join_server(ip: String, port: int) -> void:
	#logger.verbose("Attempting To Join Server")
	var net : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)

	# Ensures UDP Packets are Ordered (Has less overhead than TCP)
	#net.set_always_ordered(NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED)

	# Attempt to Create Client (does not guarantee that joining is successful)
	if (net.create_client(ip, port) != OK):
		#logger.verbose("Cannot Create Client!!!")
		return

	# Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	get_tree().set_network_peer(net)

	# TODO: Pull up Scene or Popup that says Connecting...
	# Also figure out how to set connection timeout

# Closes Connection - Client and Server
func close_connection() -> void:
	connected = false

	#logger.verbose("Close Connection")

	# Clears PlayerUI on Disconnect
	playerUI.cleanup()

	if(get_tree().get_network_peer() != null):
		# Do different things depending on if server or client
		if get_tree().is_network_server():
			# Server Side Only

			# Saves Worlds to Disk (in a separate folder per world)
			if get_tree().get_root().has_node("Worlds"):
				var worlds = get_tree().get_root().get_node("Worlds")
				for world in worlds.get_children():
					world_handler.save_world(world)

			if get_tree().get_root().has_node("EncryptionServer"):
				get_tree().get_root().get_node("EncryptionServer").queue_free()

			if get_tree().get_root().has_node("BroadcastListener"):
				get_tree().get_root().get_node("BroadcastListener").queue_free()

			if get_tree().get_root().has_node("GameForwarding"):
				get_tree().get_root().get_node("GameForwarding").queue_free()
		else:
			# Client Side Only
			# Free Up Resources and Save Data (Client Side)

			# If has ping_timer, remove it
			if get_tree().get_root().has_node("ping_timer"):
				# If Client - Cleanup Ping Timer Thread (server doesn't have one).
				keep_alive.wait_to_finish()
				get_tree().get_root().get_node("ping_timer").queue_free()

			if get_tree().get_root().has_node("EncryptionClient"):
				get_tree().get_root().get_node("EncryptionClient").queue_free()

		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		gamestate.debug = false # Reset Debug Flag Incase Next World Doesn't Specify It
		server_info.num_players = 0 # Reset Player Count
		get_tree().set_network_peer(null) # Disable Network Peer

	# Frees All Worlds From Memory (1 World if Client, All if Server)
	if get_tree().get_root().has_node("Worlds"):
		var worlds = get_tree().get_root().get_node("Worlds")
		if worlds != null:
			worlds.queue_free()

	emit_signal("cleanup_worlds")

	# TODO: Standardize These Function Names
	playerStats.hide_playerstats()
	playerChat.hide_panelchat()
	playerList.hide_player_list()

	#logger.verbose("Attempt to Change Scene Tree To Main Menu")
	# TODO: Maybe Pull Up A Disconnected Message GUI (which will then go to NetworkMenu)
	get_tree().change_scene(ProjectSettings.get_setting("application/run/main_menu"))

# Notifies Player as to Why They Were Kicked (does not need to call disconnect)
puppet func player_kicked(message: String) -> void:
	logger.info("Kick Message: %s" % message)

# Server (and Client) Notified When A New Client Connects (Player Has Not Registered Yet, So, There Is No Player Data)
# warning-ignore:unused_argument
func _on_player_connected(id: int) -> void:

	# Only the server should check if client is banned
	if get_tree().is_network_server():
		#logger.verbose("Player %s Connected to Server" % str(id))
		#player_control.check_if_banned(id)

		# Used to keep track of number of players currently on server
		if server_info.has("num_player"):
			server_info.num_player = server_info.num_player + 1

# Server Notified When A Client Disconnects
func _on_player_disconnected(id: int) -> void:
	if player_registrar.has(id):
		#logger.verbose("Player %s Disconnected from Server" % player_registrar.name(id))

		# Update the player tables
		if (get_tree().is_network_server()):
			spawn_handler.despawn_player(id)
			player_registrar.unregister_player(id) # Remove Player From Server List
			player_registrar.rpc_unreliable("unregister_player", id) # Notify Clients to do The Same

			# Used to keep track of number of players currently on server
			if server_info.has("num_player"):
				server_info.num_player = server_info.num_player - 1

# Successfully Joined Server (Client Side Only)
func _on_connected_to_server() -> void:
	connected = true

	pauseMenu.set_client_mode() # Remove Open to Lan Button

	var net : NetworkedMultiplayerENet = get_tree().get_network_peer()
	#functions.set_title(tr("connected_to_server_title") % [net.get_peer_address(gamestate.standard_netids.server), net.get_peer_port(gamestate.standard_netids.server)]) # 1 is the server's id
	#functions.set_title(tr("connected_to_server_title").format({"server_host": net.get_peer_address(gamestate.standard_netids.server), "server_port": net.get_peer_port(gamestate.standard_netids.server)}))

	#logger.verbose("Connected To Server")

	# Setup Encryption Script
	# If EncryptionClient already exists, then recreate it (old EncryptionClient wasn't removed correctly).
	if get_tree().get_root().has_node("EncryptionClient"):
		get_tree().get_root().get_node("EncryptionClient").free()

	# If ping timer already exists, then recreate it (old timer wasn't removed correctly).
	if get_tree().get_root().has_node("ping_timer"):
		get_tree().get_root().get_node("ping_timer").free()

	var encryption = Node.new()
	encryption.set_script(preload(enc_client)) # Attach A Script to Node
	encryption.set_name("EncryptionClient") # Give Node A Unique ID
	get_tree().get_root().add_child(encryption)

	# Put Ping Timer on New Thread - Is the Timer Already on New Thread? Does this Affect Timer's Thread (given that it is a node)?
	keep_alive.start(self, "start_ping", "Test Connection")

	playerList.loadPlayerList() # Load PlayerList

	gamestate.net_id = get_tree().get_network_unique_id() # Record Network ID
	player_registrar.register_player(gamestate.player_info, 0) # Update Own Dictionary With Ourself

	# Server will send current_world to client through the register_player function. The above line of code makes sure to already have a copy of player info registered before calling the server's register_player function
	player_registrar.rpc_unreliable_id(gamestate.standard_netids.server, "register_player", gamestate.player_info, gamestate.net_id) # Ask Server To Update Player Dictionary - Server ID is Always 1

# Failed To Connect To Server
func _on_connection_failed() -> void:
	#logger.verbose("Joining Server Failed!!!")
	close_connection()

# Start Timer to Send Pings to Server
func start_ping(message: String = "Ping") -> void:
	# Create Timer Node
	var timer : Timer = Timer.new()
	timer.name = "ping_timer"

	# https://docs.godotengine.org/en/3.1/tutorials/threads/thread_safe_apis.html
	get_tree().get_root().call_deferred("add_child", timer)

	timer.connect("timeout", self, "send_ping", [message]) # Function to Execute After Timer Runs Out
	timer.set_wait_time(10) # Execute Every 10 Seconds
	timer.start() # Start Timer

# Send Ping to Server
func send_ping(message: String = "Ping") -> void:
	#logger.verbose("Send Ping: %s" % message)
	rpc_unreliable_id(gamestate.standard_netids.server, "server_ping", message)

# Recieve Ping From Client (and send ping back)
master func server_ping(message: String) -> void:
	#logger.verbose("Received Ping: %s" % message)
	rpc_unreliable_id(int(get_tree().get_rpc_sender_id()), "client_ping", message)

# Receive Ping Back From Server
# warning-ignore:unused_argument
puppet func client_ping(message: String) -> void:
	#logger.verbose("Message From Server: %s" % message)
	pass

	# Track Last Ping Back and Do Something if Ping Back Fails

# Allows the server to set the client's title
puppet func set_client_title(title: String) -> void:
	functions.set_title(title)

# Pick A Port to Use
func set_port() -> int:
	var port = int(floor(rand_range(1025, 65535.1))) # Currently, there is no way of knowing what port is used by querying net, so I have to pick one myself and hope it is unused (setting port 0 tells the system to give you a port) - The .1 allows using 65535 after being processed by floor()
	server_info.used_port = port # Sets Port

	return port

func get_class() -> String:
	return "GameConnection"
