extends Node

signal server_created # When server is created (successfully)
signal join_success # Successfully joined server
signal join_fail # Failed to join server

# I followed the below tutorial to learn how to create a multiplayer server
# http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part02/

# TODO: Make sure to verify the data is valid and coherent
var server_info = {
	name = "Server",      # Holds the name of the server
	max_players = 0,      # Maximum allowed connections
	used_port = 0         # Listening port
}

func create_server():
	# Initialize the networking system
	var net = NetworkedMultiplayerENet.new()
	
	# Try to create the server
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		print("Failed to create server")
		return
	
	# Assign it into the tree
	get_tree().set_network_peer(net)
	
	# Tell the server has been created successfully
	emit_signal("server_created")

func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new()
	
	if (net.create_client(ip, port) != OK):
		print("Failed to create client")
		emit_signal("join_fail")
		return
		
	get_tree().set_network_peer(net)

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

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(id):
	pass

# Everyone gets notified whenever someone disconnects from the server
func _on_player_disconnected(id):
	pass

# Peer trying to connect to server is notified on success
func _on_connected_to_server():
	emit_signal("join_success")

# Peer trying to connect to server is notified on failure
func _on_connection_failed():
	emit_signal("join_fail")
	get_tree().set_network_peer(null)

# Peer is notified when disconnected from server
func _on_disconnected_from_server():
	pass