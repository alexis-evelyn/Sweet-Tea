extends Node
class_name ServerFinder

# PacketPeerUDP Example - https://godotengine.org/qa/20026/to-send-a-udp-packet-godot-3?show=20262#a20262

signal add_server(json, server_ip, server_port)

# Declare member variables here. Examples:
var used_server_port: int

var udp_peer = PacketPeerUDP.new()
var packet_buffer_size : int = 65536

var client : Thread = Thread.new() # I cannot switch to to OS.delay_msec(...) like I did for the server as then the client will not be able to set one way collisions and will crash. More info can be found at https://www.reddit.com/r/godot/comments/cu8jed/where_is_the_best_place_i_can_get_help_with/
const calling_card : String = "Nihilistic Sweet Tea: %s" # Text Server watches for (includes game version to determine compatibility).
var delay_broadcast_time_seconds : float = 0.01 # 5 seconds
var search_time : float = 30.0 # Only search for servers for 30 seconds until refresh is pressed.
var delay_broadcast_search : Timer # Search For Servers Timer

# Broadcast Addresses - IPV6 Does Not Support Broadcast (only using Multicast)
const broadcast_address : String = "255.255.255.255" # For Lan networks.
const localhost_address : String = "127.0.0.1" # For people running client and server on same machine.
# warning-ignore:unused_class_variable
const localhost_broadcast : String = "127.255.255.255" # 127.255.255.255 is the localhost broadcast address (the server cannot detect it :(, how do I fix that?

var addresses : Array = [localhost_address, broadcast_address] # Addresses to Broadcast to

# Called when the node enters the scene tree for the first time.
func _ready():
	set_server_port() # Sets Port to Broadcast to
	search_for_servers() # Start searching for Servers

func find_servers(peer: PacketPeerUDP) -> void:
	peer.listen(0, "*", packet_buffer_size) # Listen for replies from server (the server knows your port, so )
	#logger.verbose("Starting To Search for Servers!!!")

	var search_timer : SceneTreeTimer = get_tree().create_timer(search_time) # Creates a One Shot Timer (One Shot means it only runs once)

	while peer.is_listening() and search_timer.time_left > 0:
		#logger.verbose("Find Servers Time Left (Seconds): %s" % search_timer.time_left)
		poll_for_servers(peer)

		delay_broadcast_search = Timer.new() # Create Search For Servers Timer
		get_tree().get_root().call_deferred("add_child", delay_broadcast_search)
		yield(delay_broadcast_search, "ready") # Wait Until Timer Has Been Added to SceneTree

		delay_broadcast_search.set_wait_time(delay_broadcast_time_seconds) # Execute Every delay_broadcast_time_seconds Seconds
		delay_broadcast_search.start() # Start Timer
		yield(delay_broadcast_search, "timeout") # Wait Until Timer Times Out

		delay_broadcast_search.queue_free() # Supposed To Prevent Resume Failed From Object Class Being Expired (It Doesn't)

		if peer.get_available_packet_count() > 0:
			#logger.verbose("Received Packet!!!")
			var bytes : PoolByteArray = peer.get_packet()
			var server_ip : String = peer.get_packet_ip()
			var server_port : int = peer.get_packet_port()

			process_message(server_ip, server_port, bytes) # Process Message From Client

	search_timer.call_deferred('free') # Prevents Resume Failed From Object Class Being Expired (Have to Use Call Deferred Free or it will crash free() causes an attempted to remove reference error and queue_free() does not exist)
	logger.verbose("Find Servers Finished!!!")
	client.wait_to_finish()

# Parse Dictionary Sent By Server
func parse_server_info(server_ip: String, server_port: int, json: Dictionary) -> void:
#	logger.verbose("---------------------------------------------------")
#	logger.verbose("Server Finder Helper: %s:%s" % [server_ip, server_port])
#	for key in json.keys():
#		logger.verbose("%s: %s" % [key, json.get(key)])
#	logger.verbose("---------------------------------------------------")

	emit_signal("add_server", json, server_ip, server_port) # Add server to GUI

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func process_message(server_ip: String, server_port: int, bytes: PoolByteArray):
	#logger.verbose("Server Reply: %s" % bytes.get_string_from_ascii())

	var json : JSONParseResult = JSON.parse(bytes.get_string_from_ascii())

	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		# warning-ignore:unsafe_property_access
		# warning-ignore:unsafe_property_access
		if typeof(json.result) == TYPE_DICTIONARY:
			parse_server_info(server_ip, server_port, json.result)

func poll_for_servers(peer: PacketPeerUDP) -> void:
	# This loops through all addresses to broadcast to and sends a message to see if server replies.
	var message : String
	var bytes : PoolByteArray

	for address in addresses:
		peer.set_dest_address(address, used_server_port)

		message = calling_card % gamestate.game_version
		message += "\nname: %s" % gamestate.player_info.name
		message += "\ncharacter_unique_id: %s" % gamestate.player_info.char_unique_id

		bytes = message.to_ascii()
		peer.put_packet(bytes)

func set_server_port() -> int:
	# Has to be a hardcoded port? Not if I used a third party server, but I am trying to only use the third party server for auth.
	used_server_port = 4000
	return used_server_port

func search_for_servers() -> void:
	"""
		Search for Servers (will be used by refresh button)

		This is meant to be called directly.
	"""

	logger.verbose("Client is Active: %s!!!" % client.is_active())
	if not client.is_active():
		logger.verbose("Finding Servers!!!")
		client.start(self, "find_servers", udp_peer)

func _exit_tree():
	if is_instance_valid(delay_broadcast_search): # Make sure to only attempt to free the timer if the timer wasn't already freed (say due to running out of timer).
		delay_broadcast_search.queue_free()

	udp_peer.close()
	#client.wait_to_finish()

func get_class() -> String:
	return "ServerFinder"
