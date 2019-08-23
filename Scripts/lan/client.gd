extends Node

# Lan Server Finder - EXTREMELY BUGGY
# PacketPeerUDP Example - https://godotengine.org/qa/20026/to-send-a-udp-packet-godot-3?show=20262#a20262

# Declare member variables here. Examples:
var used_server_port: int

var udp_peer = PacketPeerUDP.new()
var packet_buffer_size : int = 30

var client : Thread = Thread.new()
var calling_card : String = "Nihlistic Sweet Tea: %s" # Text Server watches for (includes game version to determine compatibility).
var delay_broadcast_time_seconds : float = 5.0 # 5 seconds
var search_timer : float = 30 # Only search for servers for 30 seconds until refresh is pressed.

# Broadcast Addresses - IPV6 Does Not Support Broadcast (only using Multicast)
var broadcast_address : String = "255.255.255.255" # For Lan networks.
var localhost_address : String = "127.0.0.1" # For people running client and server on same machine.
# warning-ignore:unused_class_variable
var localhost_broadcast : String = "127.255.255.255" # 127.255.255.255 is the localhost broadcast address (the server cannot detect it :(, how do I fix that?

var addresses : Array = [localhost_address, broadcast_address] # Addresses to Broadcast to

# Called when the node enters the scene tree for the first time.
func _ready():
	set_server_port() # Sets Port to Broadcast to
	#search_for_servers() # Start searching for Servers
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func find_servers(udp_peer: PacketPeerUDP) -> void:
	udp_peer.listen(0, "*", packet_buffer_size) # Listen for replies from server (the server knows your port, so )
	print("Starting To Search for Servers!!!")
	
	var search_timer : SceneTreeTimer = get_tree().create_timer(delay_broadcast_time_seconds) # Creates a One Shot Timer (One Shot means it only runs once)
	
	while udp_peer.is_listening():
		poll_for_servers(udp_peer)
		
		var timer : SceneTreeTimer = get_tree().create_timer(delay_broadcast_time_seconds) # Creates a One Shot Timer (One Shot means it only runs once)
		yield(timer, "timeout")
		timer.call_deferred('free') # Prevents Resume Failed From Object Class Being Expired (Have to Use Call Deferred Free or it will crash free() causes an attempted to remove reference error and queue_free() does not exist)

		if udp_peer.get_available_packet_count() > 0:
			print("Received Packet!!!")
			var bytes = udp_peer.get_packet()
			var client_ip = udp_peer.get_packet_ip()
			var client_port = udp_peer.get_packet_port()
			
			var reply = process_message(client_ip, client_port, bytes) # Process Message From Client

func process_message(client_ip: String, client_port: int, bytes: PoolByteArray):
	print("Server Reply: ", bytes.get_string_from_ascii())
	pass

func poll_for_servers(udp_peer: PacketPeerUDP) -> void:
	# This loops through all addresses to broadcast to and sends a message to see if server replies.
	for address in addresses:
		udp_peer.set_dest_address(address, used_server_port)
		
		var message : String = calling_card % gamestate.game_version
		var bytes : PoolByteArray = message.to_ascii()
		udp_peer.put_packet(bytes)

func set_server_port() -> int:
	# Has to be a hardcoded port? Not if I used a third party server, but I am trying to only use the third party server for auth.
	used_server_port = 4000
	return used_server_port
	
func search_for_servers() -> void:
	"""
		Search for Servers (will be used by refresh button)
	
		This is meant to be called directly.
	"""
	
	if not client.is_active():
		client.start(self, "find_servers", udp_peer)
	
func _exit_tree():
	udp_peer.close()
	#client.wait_to_finish()
