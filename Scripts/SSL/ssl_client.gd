extends Node

# I plan on replacing Chat's RPC sending/receiving with StreamPeerSSL (only if enabled in server) - StreamPeerSSL makes server setup more complicated, so dedicated server owners will manage it, but regular players shouldn't be concerned about SSL Certs.
# I also plan on adding authentication (before connecting to server) over StreamPeerSSL

# Declare member variables here. Examples:
var client : StreamPeerSSL
var tcp_connection : StreamPeerTCP

# Called when the node enters the scene tree for the first time.
func _ready():
	client = StreamPeerSSL.new() # This is a wrapper for TCP_Server. This is not a node, so this will not be added to the scene tree
	tcp_connection = StreamPeerTCP.new() # TCP Client to Connect With
	
	# I plan on having the server return the host and port over rpc (by itself it won't be secure, but I am planning on having server owners use a CA like Let's Encrypt).
	tcp_connection.connect_to_host("127.0.0.1", 4344)
	
	client.connect_to_stream(tcp_connection, true) # TODO: Do I use for_hostname?

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

func cleanup() -> void:
	client.disconnect_from_stream()
	tcp_connection.disconnect_from_host()