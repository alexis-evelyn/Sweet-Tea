extends Node

# Signals
signal connection_success # Joining Server Was Successful
signal server_created # Server Was Successfully Created
signal cleanup_worlds # Cleanup World Handler

# Keep Alive Thread
var keep_alive: Thread

# StreamPeerSSL
var enc_server : String = "res://Scripts/Security/server_encryption.gd"
var enc_client : String = "res://Scripts/Security/client_encryption.gd"

# Reference to Player List
onready var playerList : Node = get_tree().get_root().get_node("PlayerUI/panelPlayerList")
onready var playerUI : Node = get_tree().get_root().get_node("PlayerUI")

# TODO: Make sure to verify the data is valid and coherent
# Server Info to Send to Clients
var server_info : Dictionary = {
	name = "Sweet Tea", # Name of Server
	icon = "res://...something.svg", # Server Icon (for Clients to See)
	motd = "A Message Will Be Displayed to Clients Using This...", # Display A Message To Clients Before Player Joins Server
	website = "https://sweet-tea.senorcontento.com/", # Server Owner's Website (to display rules, purchases, etc...)
	num_player = 0, # Display Current Number of Connected Players (so client can see how busy a server is)
	max_players = 0, # Maximum Number of Players (including server player)
	bind_address = "*",
	used_port = 0, # Host Port
	ssl_bind_address = "*",
	ssl_port = 4344 # StreamPeerSSL Port
}

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	# Why don't we have block ignore warnings?
	#warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	#warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	#warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	#warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	#warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "close_connection")

# Attempt to Create Server
func create_server() -> void:
	# TODO: Godot supports UPNP hole punching, so this could be useful for non-technical players
	
	# Setup Encryption Script
	var encryption = Node.new()
	encryption.set_script(load(enc_server)) # Attach A Script to Node
	encryption.set_name("EncryptionServer") # Give Node A Unique ID
	get_tree().get_root().add_child(encryption)
	
	#print("Attempting to Create Server on Port ", server_info.used_port)
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# https://docs.godotengine.org/en/3.1/classes/class_networkedmultiplayerenet.html
	net.set_bind_ip(server_info.bind_address) # Sets the IP Address the Server Binds to
	
	# Could Not Create Server (probably port already in use or Failed Permissions)
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		#print("Failed to create server")
		return
	
	get_tree().set_network_peer(net) # Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	
	# The world_handler loader is intentionally before registering the server player so that the server player will have a current world marked
	emit_signal("server_created") # Notify world_handler That Server Was Created
	
	# Activate PlayerList Since Server is Close to Finishing Loading
	if not gamestate.server_mode:
		playerList.loadPlayerList() # Load PlayerList

# Attempt to Join Server (Not Connected Yet)
func join_server(ip: String, port: int) -> void:
	#print("Attempting To Join Server")
	
	var net : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# Attempt to Create Client (does not guarantee that joining is successful)
	if (net.create_client(ip, port) != OK):
		#print("Cannot Create Client!!!")
		return
	
	# Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	get_tree().set_network_peer(net)
	
	# TODO: Pull up Scene or Popup that says Connecting...
	# Also figure out how to set connection timeout

# Closes Connection - Client and Server
func close_connection() -> void:
	#print("Close Connection")
	
	# Clears PlayerUI on Disconnect
	playerUI.cleanup()
	
	var worlds = get_tree().get_root().get_node("Worlds")
	
	if(get_tree().get_network_peer() != null):
		# Do different things depending on if server or client
		if get_tree().is_network_server():
			# Server Side Only
			
			# Saves Worlds to Disk (in a separate folder per world)
			for world in worlds.get_children():
				world_handler.save_world(world)
			
			if get_tree().get_root().has_node("EncryptionServer"):
				get_tree().get_root().get_node("EncryptionServer").queue_free()
		else:
			# Client Side Only
			# Free Up Resources and Save Data (Client Side)
			
			# If Client - Cleanup Ping Timer Thread (server doesn't have one).
			keep_alive.wait_to_finish()
		
			# If has ping_timer, remove it
			if get_tree().get_root().has_node("ping_timer"):
				get_tree().get_root().get_node("ping_timer").queue_free()
				
			if get_tree().get_root().has_node("EncryptionClient"):
				get_tree().get_root().get_node("EncryptionClient").queue_free()
		
		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
	
	# Frees All Worlds From Memory (1 World if Client, All if Server)
	worlds.queue_free()
	
	emit_signal("cleanup_worlds")
	
	#print("Attempt to Change Scene Tree")
	# TODO: Maybe Pull Up A Disconnected Message GUI (which will then go to NetworkMenu)
	get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Notifies Player as to Why They Were Kicked (does not need to call disconnect)
puppet func player_kicked(message: String) -> void:
	print("Kick Message: ", message)

# Server (and Client) Notified When A New Client Connects (Player Has Not Registered Yet, So, There Is No Player Data)
func _on_player_connected(id: int) -> void:
	
	# Only the server should check if client is banned
	if get_tree().is_network_server():
		#print("Player ", str(id), " Connected to Server")
		#player_control.check_if_banned(id)
		pass

# Server Notified When A Client Disconnects
func _on_player_disconnected(id: int) -> void:
	if player_registrar.has(id):
		#print("Player ", player_registrar.name(id), " Disconnected from Server")
	
		# Update the player tables
		if (get_tree().is_network_server()):
			spawn_handler.despawn_player(id)
			player_registrar.unregister_player(id) # Remove Player From Server List
			player_registrar.rpc_unreliable("unregister_player", id) # Notify Clients to do The Same

# Successfully Joined Server (Client Side Only)
func _on_connected_to_server() -> void:
	#print("Connected To Server")
	
	# Setup Encryption Script
	var encryption = Node.new()
	encryption.set_script(load(enc_client)) # Attach A Script to Node
	encryption.set_name("EncryptionClient") # Give Node A Unique ID
	get_tree().get_root().add_child(encryption)
	
	# Put Ping Timer on New Thread - Is the Timer Already on New Thread? Does this Affect Timer's Thread (given that it is a node)?
	keep_alive = Thread.new()
	keep_alive.start(self, "start_ping", "Test Connection")
	
	emit_signal("connection_success") # Allows Loading World From Server on Successful Connection
	playerList.loadPlayerList() # Load PlayerList

	gamestate.net_id = get_tree().get_network_unique_id() # Record Network ID
	player_registrar.register_player(gamestate.player_info, 0) # Update Own Dictionary With Ourself
	
	# Server will send current_world to client through the register_player function. The above line of code makes sure to already have a copy of player info registered before calling the server's register_player function
	player_registrar.rpc_unreliable_id(1, "register_player", gamestate.player_info, gamestate.net_id) # Ask Server To Update Player Dictionary - Server ID is Always 1
	
	#print("Connected Current World: ", player_registrar.has_current_world())
	
	# Callbacks would be nice - waiting on current world to be set. see player_registrar.gd
	# spawn_handler.rpc_unreliable_id(1, "spawn_player_server", gamestate.player_info) # Notify Server To Spawn Client

# Failed To Connect To Server
func _on_connection_failed() -> void:
	#print("Joining Server Failed!!!")
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
	#print("Send Ping: ", message)
	rpc_unreliable_id(1, "server_ping", message)
	
# Recieve Ping From Client (and send ping back)
master func server_ping(message: String) -> void:
	#print("Received Ping: ", message)
	rpc_unreliable_id(int(get_tree().get_rpc_sender_id()), "client_ping", message)
	
# Receive Ping Back From Server
puppet func client_ping(message: String) -> void:
	#print("Message From Server: ", message)
	pass
	
	# Track Last Ping Back and Do Something if Ping Back Fails
