extends Node

# Lan Server Finder Helper - EXTREMELY BUGGY
# Declare member variables here. Examples:
var used_port: int
var packet_buffer_size: int = 100 # Clients repeatedly send packets, so there is no reason to cache 65536 packets.
var server : Thread = Thread.new()
var calling_card : String = "Nihilistic Sweet Tea:"
var delay_packet_processing_time_milliseconds : int = 1000 # Delay processing to prevent cpu usage rising dramatically by a flood of packets (won't prevent DOS, but helps out on normal usage)
var udp_peer = PacketPeerUDP.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	server.start(self, "listen_for_clients", null)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# warning-ignore:unused_argument
func listen_for_clients(thread_data) -> void:
	if udp_peer.listen(set_port(), network.server_info.bind_address, packet_buffer_size) != OK:
		#logger.verbose("Failed to Bind to Port %s for Clients to Poll!!! Clients will not find you in LAN!!!" % used_port)
		return
	
	#logger.verbose("Starting To Listen For Clients!!!")
	while udp_peer.is_listening():
		udp_peer.wait() # Makes PacketPeerUDP wait until it receives a packet (to save on CPU usage) - This works because listen_for_clients(...) is on a different thread.
#		#logger.verbose("Listening!!!")
		
		while udp_peer.get_available_packet_count() > 0:
#			#logger.verbose("Received Packet!!!")
			var bytes : PoolByteArray = udp_peer.get_packet()
			var client_ip : String = udp_peer.get_packet_ip()
			var client_port : int = udp_peer.get_packet_port()
			
			var reply = process_message(client_ip, client_port, bytes) # Process Message From Client
			
			#logger.verbose("Client Response Type: %s" % typeof(reply)) # https://docs.godotengine.org/en/3.1/classes/class_@globalscope.html#enum-globalscope-variant-type
			if typeof(reply) == TYPE_RAW_ARRAY: # PoolByteArray
				#logger.verbose("Sending Reply!!!")
				udp_peer.set_dest_address(client_ip, client_port) # Set Client as Receiver of Response
				udp_peer.put_packet(reply) # Send response back to client
				
			# Apparently using yield with a timer here causes the server to crash when the client uses /changeworld or /spawn. Using OS.delay_msec(...) solves this issue.
			OS.delay_msec(delay_packet_processing_time_milliseconds)

func process_message(client_ip: String, client_port: int, bytes: PoolByteArray):
	# If Failed to Retrieve Client Info, Then Don't Continue
	if client_ip == null or client_port == 0:
		#logger.verbose("(Lan Server - Client Finder) Couldn't Get Packet's Source IP and/or Port!!! Packets Sender looks Like: %s:%s" % [client_ip, client_port])
		return false
	
	var message : String = bytes.get_string_from_ascii()
	
	if calling_card in message:
		var split_message : PoolStringArray = message.split(":", true, 1)
		#logger.verbose("(%s:%s) Client's Game Version: '%s'" % [client_ip, str(client_port), split_message[1].trim_prefix(" ").trim_suffix(" ")])
		return JSON.print(network.server_info).to_ascii() # This converts dictionary to json, which then gets converted to a PoolByteArray to be sent as a packet.
	else:
		logger.verbose("Unknown Message: %s" % message)
	
	return false # Nothing to reply to? Let server know.
	
func set_port() -> int:
#	var port = int(floor(rand_range(1025, 65535.1))) # Currently, there is no way of knowing what port is used by querying net, so I have to pick one myself and hope it is unused (setting port 0 tells the system to give you a port) - The .1 allows using 65535 after being processed by floor()
#	used_port = port # Sets Port
#
#	return port
	
	used_port = 4000
	return used_port

func _exit_tree():
	udp_peer.close()
	#server.wait_to_finish()
