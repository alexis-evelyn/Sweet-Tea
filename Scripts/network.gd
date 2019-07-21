extends Node

signal server_created # When server is created (successfully)
signal join_success # Successfully joined server
signal join_fail # Failed to join server
signal player_list_changed # Client List Updated

# TODO (IMPORTANT): Figure out how to encrypt ENet!!! How Does Minecraft Do It?
# This is important to prevent MITM attacks which could result in a server owner banning a player
# Some potential options are, have a master certificate that signs other server certs (requires alway online server)
# Or implement the encryption like how SSH would. Also requiring servers to have a hostname and a CA will create a cert
# for the server owner (only usable for dedicated servers)
# https://wiki.vg/Protocol_Encryption
# https://docs.godotengine.org/en/3.1/tutorials/networking/ssl_certificates.html
# https://gamedev.stackexchange.com/a/115626/97290
# https://gamedevcoder.wordpress.com/2011/08/28/packet-encryption-in-multiplayer-games-part-1/

# I followed the below tutorial to learn how to create a multiplayer server
# http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part02/

var players = {}

# TODO: Make sure to verify the data is valid and coherent
var server_info = {
	name = "Sweet Tea", # Name of Server
	max_players = 0, # Maximum Number of Players (including server player)
	used_port = 0 # Host Port
}

func create_server():
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# Could Not Create Server (probably port already in use or Failed Permissions)
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		print("Failed to create server")
		return
	
	get_tree().set_network_peer(net) # Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	emit_signal("server_created") # Initializes Server World
	
	# Register Server's Player in Player List
	# TODO: Setup Ability To Run Headless (with no server player, since it is headless)
	# I will probably setup headless mode to be activated by commandline (and maybe in the network menu?)
	register_player(gamestate.player_info)

func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# Attempt to Connect To Server
	if (net.create_client(ip, port) != OK):
		print("Failed to create client")
		emit_signal("join_fail") # Call Function to Pull Up Failed Join GUI
		return
		
	# Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	get_tree().set_network_peer(net)

remote func register_player(pinfo):
	if get_tree().is_network_server():
		# Distribute Registered Clients Info to Clients
		for id in players:
			# Send Registered Clients to Newly Joined Client
			rpc_id(pinfo.net_id, "register_player", players[id])
			
			# Send Newly Joined Client Info to All Other Clients
			if (id != 1):
				rpc_id(id, "register_player", pinfo)
	
	print("Registering player ", pinfo.name, " (", pinfo.net_id, ") to internal player table")
	players[pinfo.net_id] = pinfo # Add Newly Joined Client to Dictionary of Clients
	emit_signal("player_list_changed") # Notify Clients That Client List Has Changed

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
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

# Live Clients Notified When A New Client Connects
func _on_player_connected(id):
	pass

# Live Clients Notified When A Client Disconnects
func _on_player_disconnected(id):
	pass

# Successfully Joined Server
func _on_connected_to_server():
	emit_signal("join_success")

	gamestate.player_info.net_id = get_tree().get_network_unique_id() # Record Network ID
	rpc_id(1, "register_player", gamestate.player_info) # Ask Server To Update Player Dictionary - Server ID is Always 1
	register_player(gamestate.player_info) # Update Own Dictionary With Ourself

# Failed To Connect To Server
func _on_connection_failed():
	emit_signal("join_fail") # Call Function to do Something on Fail (probably show GUI)
	get_tree().set_network_peer(null) # Disable Network Peer

# Disconnected From Server
# TODO: Free Up Resources and Save Data (Client Side)
func _on_disconnected_from_server():
	pass