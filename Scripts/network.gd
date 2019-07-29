extends Node

# Signals
signal connection_success # Joining Server Was Successful
signal server_created # Server Was Successfully Created

# TODO (IMPORTANT): Figure out how to encrypt ENet!!! How Does Minecraft Do It?
# This is important to prevent MITM attacks which could result in a server owner banning a player
# Some potential options are, have a master certificate that signs other server certs (requires alway online server)
# Or implement the encryption like how SSH would. Also requiring servers to have a hostname and a CA will create a cert
# for the server owner (only usable for dedicated servers)
# https://wiki.vg/Protocol_Encryption
# https://docs.godotengine.org/en/3.1/tutorials/networking/ssl_certificates.html
# https://gamedev.stackexchange.com/a/115626/97290
# https://gamedevcoder.wordpress.com/2011/08/28/packet-encryption-in-multiplayer-games-part-1/

# Reference to Player List
onready var playerList = get_tree().get_root().get_node("PlayerUI/panelPlayerList")
onready var playerUI = get_tree().get_root().get_node("PlayerUI")

# TODO: Make sure to verify the data is valid and coherent
# Server Info to Send to Clients
var server_info = {
	name = "Sweet Tea", # Name of Server
	icon = "res://...something.svg", # Server Icon (for Clients to See)
	motd = "A Message Will Be Displayed to Clients Using This...", # Display A Message To Clients Before Player Joins Server
	website = "https://sweet-tea.senorcontento.com/", # Server Owner's Website (to display rules, purchases, etc...)
	num_player = 0, # Display Current Number of Connected Players (so client can see how busy a server is)
	max_players = 0, # Maximum Number of Players (including server player)
	used_port = 0 # Host Port
}

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready():
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
func create_server():
	# TODO: Godot supports UPNP hole punching, so this could be useful for non-technical players
	
	print("Attempting to Create Server on Port ", server_info.used_port)
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# https://docs.godotengine.org/en/3.1/classes/class_networkedmultiplayerenet.html
	net.set_bind_ip("*") # Sets the IP Address the Server Binds to
	
	# Could Not Create Server (probably port already in use or Failed Permissions)
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		print("Failed to create server")
		return
	
	get_tree().set_network_peer(net) # Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	
	# The world_handler loader is intentionally before registering the server player so that the server player will have a current world marked
	emit_signal("server_created") # Notify world_handler That Server Was Created
	
	# Activate PlayerList Since Server is Close to Finishing Loading
	if(OS.has_feature("Server") == false):
		playerList.loadPlayerList() # Load PlayerList

# Attempt to Join Server (Not Connected Yet)
func join_server(ip, port):
	print("Attempting To Join Server")
	
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# Attempt to Create Client (does not guarantee that joining is successful)
	if (net.create_client(ip, port) != OK):
		print("Cannot Create Client!!!")
		return
	
	# Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	get_tree().set_network_peer(net)
	
	# TODO: Pull up Scene or Popup that says Connecting...
	# Also figure out how to set connection timeout

# Closes Connection - Client and Server
func close_connection():
	#print("Close Connection")
	
	# Clears PlayerUI on Disconnect
	playerUI.cleanup()
	
	# Frees All Worlds From Memory (1 World if Client, All if Server)
	get_tree().get_root().get_node("Worlds").queue_free()
	
	if(get_tree().get_network_peer() != null):
		# Do different things depending on if server or client
		if get_tree().is_network_server():
			# Server Side Only
			pass
		else:
			# Client Side Only
			# TODO: Free Up Resources and Save Data (Client Side)
			pass
		
		player_registrar.cleanup()
		spawn_handler.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
	
	#print("Attempt to Change Scene Tree")
	# TODO: Maybe Pull Up A Disconnected Message GUI (which will then go to NetworkMenu)
	get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Notifies Player as to Why They Were Kicked (does not need to call disconnect)
puppet func player_kicked(message):
	print("Kick Message: ", message)

# Server (and Client) Notified When A New Client Connects (Player Has Not Registered Yet, So, There Is No Player Data)
func _on_player_connected(id):
	
	# Only the server should check if client is banned
	if get_tree().is_network_server():
		#print("Player ", str(id), " Connected to Server")
		#player_control.check_if_banned(id)
		pass

# Server Notified When A Client Disconnects
func _on_player_disconnected(id):
	if player_registrar.has(id):
		print("Player ", player_registrar.name(id), " Disconnected from Server")
	
		# Update the player tables
		if (get_tree().is_network_server()):
			spawn_handler.despawn_player(id)
			player_registrar.unregister_player(id) # Remove Player From Server List
			rpc_unreliable("unregister_player", id) # Notify Clients to do The Same

# Successfully Joined Server (Client Side Only)
func _on_connected_to_server():
	#print("Connected To Server")
	
	emit_signal("connection_success") # Allows Loading World From Server on Successful Connection
	playerList.loadPlayerList() # Load PlayerList

	gamestate.net_id = get_tree().get_network_unique_id() # Record Network ID
	rpc_unreliable_id(1, "register_player", gamestate.player_info, gamestate.net_id) # Ask Server To Update Player Dictionary - Server ID is Always 1
	player_registrar.register_player(gamestate.player_info, 0) # Update Own Dictionary With Ourself
	rpc_unreliable_id(1, "spawn_player_server", gamestate.player_info) # Notify Server To Spawn Client

# Failed To Connect To Server
func _on_connection_failed():
	print("Joining Server Failed!!!")
	close_connection()
	
# How can I remove this and just have the rpc call go directly to player_registrar?
remote func register_player(pinfo, net_id: int):
	player_registrar.register_player(pinfo, net_id)
	
# How can I remove this and just have the rpc call go directly to player_registrar?
remote func unregister_player(net_id: int):
	player_registrar.unregister_player(net_id)

# How can I remove this and just have the rpc call go directly to spawn_handler?
master func spawn_player_server(pinfo):
	print("Client Requested Spawn")
	spawn_handler.spawn_player_server(pinfo)