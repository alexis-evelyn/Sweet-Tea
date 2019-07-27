extends Node

# Signals
signal join_success
signal join_fail # Failed to join server
signal server_created

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
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# https://docs.godotengine.org/en/3.1/classes/class_networkedmultiplayerenet.html
	net.set_bind_ip("*") # Sets the IP Address the Server Binds to
	
	# Could Not Create Server (probably port already in use or Failed Permissions)
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		print("Failed to create server")
		return
	
	get_tree().set_network_peer(net) # Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	emit_signal("server_created") # Notify world_handler That Server Was Created
	
	# Register Server's Player in Player List
	# TODO: Setup Ability To Run Headless (with no server player, since it is headless)
	# I will probably setup headless mode to be activated by commandline (and maybe in the network menu?)
	player_registrar.register_player(gamestate.player_info, 0)
	playerList.loadPlayerList() # Load PlayerList

# Attempt to Join Server (Not Connected Yet)
func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# Attempt to Connect To Server
	if (net.create_client(ip, port) != OK):
		emit_signal("connection_failed") # Call Function to Signal Failed Joining Server
		return
	
	# Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	get_tree().set_network_peer(net)
	#set_network_master(1)

	emit_signal("join_success")
	playerList.loadPlayerList() # Load PlayerList

# Closes Connection - Client and Server
func close_connection():
	#print("Close Connection")
	
	# Clears PlayerUI on Disconnect
	playerUI.cleanup()
	
	# Do different things depending on if server or client
	if(get_tree().get_network_peer() != null):
		if get_tree().is_network_server():
			# Server Side Only
			pass
		else:
			# Client Side Only
			# TODO: Free Up Resources and Save Data (Client Side)
			pass
		
		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
	
	#print("Attempt to Change Scene Tree")
	# TODO: Maybe Pull Up A Disconnected Message GUI (which will then go to NetworkMenu)
	get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Notifies Player as to Why They Were Kicked (does not need to call disconnect)
puppet func player_kicked(message):
	print("Kick Message: ", message)

# Server (and Client) Notified When A New Client Connects
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
			player_registrar.unregister_player(id) # Remove Player From Server List
			rpc("unregister_player", id) # Notify Clients to do The Same

# Successfully Joined Server (Client Side Only)
func _on_connected_to_server():
	#print("Connected To Server")

	gamestate.net_id = get_tree().get_network_unique_id() # Record Network ID
	rpc_id(1, "register_player", gamestate.player_info, gamestate.net_id) # Ask Server To Update Player Dictionary - Server ID is Always 1
	player_registrar.register_player(gamestate.player_info, 0) # Update Own Dictionary With Ourself
	rpc_id(1, "spawn_player_server", gamestate.player_info) # Notify Server To Spawn Client

# Failed To Connect To Server
func _on_connection_failed():
	emit_signal("join_fail") # Call Function to do Something on Fail (probably show GUI)
	get_tree().set_network_peer(null) # Disable Network Peer
	
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