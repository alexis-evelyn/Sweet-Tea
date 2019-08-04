extends Node

# I plan on replacing Chat's RPC sending/receiving with StreamPeerSSL (only if enabled in server) - StreamPeerSSL makes server setup more complicated, so dedicated server owners will manage it, but regular players shouldn't be concerned about SSL Certs.
# I also plan on adding authentication (before connecting to server) over StreamPeerSSL

# Declare member variables here. Examples:
var server : StreamPeerSSL
var tcp_server : TCP_Server
var connection_thread : Thread

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tcp_server = TCP_Server.new() # TCP Server to Listen With
	
	# Host and Port to Listen On
	tcp_server.listen(network.server_info.ssl_port, network.server_info.ssl_bind_address)
	
	# It doesn't appear that TCP_Server handles threading, so I would have to do it myself to take more than one connection at the same time
	# https://github.com/godotengine/godot/blob/550f436f8fbea86984a845c821270fba78189143/core/io/tcp_server.cpp#L96
	connection_thread = Thread.new()
	connection_thread.start(self, "_listen")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _listen(thread_data) -> void:
	# Godot's Threading Requires Having Some Variable in the Function (see link below for Godot's Threading Source)
	# https://github.com/godotengine/godot/blob/20a3bb9c484431439ffa60a158d7563c466cd530/core/bind/core_bind.cpp#L2629
	print("TCP Server Listening!!!")
	
	while true:
		if tcp_server.is_connection_available():
			print("Connection Available!!!")
			tcp_connection(tcp_server.take_connection())

func tcp_connection(connection: StreamPeerTCP) -> void:
	server = StreamPeerSSL.new() # This is a wrapper for TCP_Server. This is not a node, so this will not be added to the scene tree
	server.connect_to_stream(connection) # TODO: Do I use for_hostname?
	
	# Check if Connected
	if server.is_connected_to_host():
		# StreamPeerSSL Polls for Data - https://docs.godotengine.org/en/3.1/classes/class_streampeerssl.html
		server.poll()
		
		# Get Number of Available Bytes
		var available_bytes : int = server.get_available_bytes()
	
		# Print Data Received and IP Address and Port
		print("Byte Count: ", available_bytes)
		print("Bytes: ", server.get_string(available_bytes))
		print("IP Address and Port: ", server.get_connected_host(), ":", server.get_connected_port())

func cleanup() -> void:
	server.disconnect_from_stream()
	tcp_server.stop()