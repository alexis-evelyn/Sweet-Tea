extends Node

# TODO: Make Client Close if Server Shutdown Forcibly

# It's not necessary to add signal arguments here, but it helps when studying the code
signal server_created # When server is created (successfully)
signal join_success # Successfully joined server
signal join_fail # Failed to join server
signal player_list_changed # Client List Updated
signal player_removed(pinfo) # A Player Was Removed From The Player List

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

# Currently Registered Players
var players = {}

# List of Banned Players (will be saved to file)
var banned_players = {} # If I add actual authentication (via Steam or my own custom implementation, this will be useful)
var banned_ips = {} # Allows banning players via IP address (if player ban is not enough). Use with restraint as multiple players could share the same IP address (e.g. in a university)

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
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

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
	emit_signal("server_created") # Initializes Server World
	
	# Register Server's Player in Player List
	# TODO: Setup Ability To Run Headless (with no server player, since it is headless)
	# I will probably setup headless mode to be activated by commandline (and maybe in the network menu?)
	register_player(gamestate.player_info)

# Attempt to Join Server
func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new() # Create Networking Node (for handling connections)
	
	# Attempt to Connect To Server
	if (net.create_client(ip, port) != OK):
		print("Failed to create client")
		emit_signal("join_fail") # Call Function to Pull Up Failed Join GUI
		return
	
	# Assign NetworkedMultiplayerENet as Handler of Network - https://docs.godotengine.org/en/3.1/classes/class_multiplayerapi.html?highlight=set_network_peer#class-multiplayerapi-property-network-peer
	get_tree().set_network_peer(net)
	#set_network_master(1)

# Clients Notified To Add Player to Player List
remote func register_player(pinfo):
	if get_tree().is_network_server():
		# Distribute Registered Clients Info to Clients
		for id in players:
			# Send Registered Clients to Newly Joined Client
			rpc_id(pinfo.net_id, "register_player", players[int(id)])
			
			# Send Newly Joined Client Info to All Other Clients
			if (id != 1):
				rpc_id(id, "register_player", pinfo)
	
	print("Registering player ", pinfo.name, " (", pinfo.net_id, ") to internal player table")
	players[int(pinfo.net_id)] = pinfo # Add Newly Joined Client to Dictionary of Clients
	emit_signal("player_list_changed") # Notify Clients That Client List Has Changed

# Clients Notified To Remove Player From Player List
remote func unregister_player(id):
	print("Removing player ", players[id].name, " from internal table")
	
	var pinfo = players[id] # Cache player info for removal process
	players.erase(id) # Remove Player From Player List
	
	emit_signal("player_list_changed") # Notify Clients Of List Change
	emit_signal("player_removed", pinfo) # Request Server To Remove Player

# Closes Connection - Client and Server
func close_connection():
	print("Close Connection")
	
	# Do different things depending on if server or client
	if(get_tree().get_network_peer() != null):
		if get_tree().is_network_server():
			pass
		else:
			pass
		
		players.clear() # Clear The Player List
		gamestate.player_info.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
	
	print("Attempt to Change Scene Tree")
	# TODO: Maybe Pull Up A Disconnected Message GUI (which will then go to NetworkMenu)
	get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Bans Player From Server (Arguments Player, Pardon Time in Seconds, and Message)
func ban_player():
	var ban_message = "Player Banned!!!" # Will be replaced by a function argument
	
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	var banned = OS.get_datetime(true)  # true means UTC format (helps consistency even if computer timezone is changed)
	var pardoned = 10 # How many seconds to ban for (0 means indefinitely)
	
	if get_tree().is_network_server():
		# TODO: This for loop will be replaced by a player ID (do not replace with name, but do set a permanent id via third party such as with Steam) specified by chat
		for player in players:
			if player != 1: # If player is not server
				var ban_data = {
					player_id = player, # Player's Network ID
					player_ip_address = str(net.get_peer_address(player)), # Player's IP Address
					banned_time = banned, # Sets Time Player Was Banned
					pardon_time = pardoned # Time User Will be Pardoned
				}
			
				banned_players[player] = ban_data
				kick_player() # Will add arguments later (player id and ban message)

# Bans IP Adress From Server (Arguments IP Address, Pardon Time in Seconds, and Message)
func ban_ip_address():
	var ban_message = "IP Banned!!!" # Will be replaced by a function argument
	
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	var banned = OS.get_datetime(true) # true means UTC format (helps consistency even if computer timezone is changed)
	var pardoned = 10  # How many seconds to ban for (0 means indefinitely)
	
	if get_tree().is_network_server():
		# TODO: This for loop will be replaced by a player ID (do not replace with name, but do set a permanent id via third party such as with Steam) specified by chat
		for player in players:
			if player != 1: # If player is not server
				var ip_address = str(net.get_peer_address(player))
			
				var ban_data = {
					player_id = player, # Player's Network ID
					player_ip_address = ip_address, # Player's IP Address
					banned_time = banned, # Sets Time Player Was Banned
					pardon_time = pardoned # Time User Will be Pardoned
				}
				
				banned_ips[ip_address] = ban_data
				kick_player_by_ip(ip_address) # Will add arguments later (player id and ban message)

# Allows Kicking All Players On A Particular IP Address
func kick_player_by_ip(ip_address):
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	# TODO: Make Efficient for Large Player Base
	
	for player in players:
		if player != 1: # If player is not server
			if str(net.get_peer_address(player)) == ip_address:
				kick_player() # Will specify Player ID "player"

# Kicks Player From Server (outside of a server shutdown)
func kick_player(): # Arguments (Player and Kick/Ban Message)
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	# TODO: Currently, the server disconnects everyone, but as chat gets added, the ability to select a peer (client) will be added to
	
	# The server will do the kicking of players, but mods can request the server to do so (with the right permissions)
	if get_tree().is_network_server():
		# TODO: This for loop will be replaced by a player ID (do not replace with name, but do set a permanent id via third party such as with Steam) specified by chat
		for player in players:
			if player != 1: # If player is not server
				rpc_id(player, "player_kicked", "You, " + str(player) + ", has been kicked!!! Your IP address is: " + str(net.get_peer_address(player))) # Notify Player They Have Been Kicked
				net.disconnect_peer(player, false) # Disconnect the peer immediately (true means no flushing messages)

# Notifies Player as to Why They Were Kicked (does not need to call disconnect)
puppet func player_kicked(message):
	print("Kick Message: ", message)

func check_if_banned(id):
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	print("Ban Check - Player ID: ", str(id), " Player IP: ", str(net.get_peer_address(id)))
	
	if banned_players.has(id) or banned_ips.has(net.get_peer_address(id)):
		print("Player Was Previously Banned")
		
		rpc_id(id, "player_kicked", "You were banned!!!") # Notify Player They Have Been Kicked
		net.disconnect_peer(id, false) # Disconnect the peer immediately (true means no flushing messages)

# Server (and Client) Notified When A New Client Connects
func _on_player_connected(id):
	
	# Only the server should check if client is banned
	if get_tree().is_network_server():
		print("Player ", str(id), " Connected to Server")
		check_if_banned(id)

# Server Notified When A Client Disconnects
func _on_player_disconnected(id):
	if players.has(id):
		print("Player ", players[id].name, " Disconnected from Server")
	
		# Update the player tables
		if (get_tree().is_network_server()):
			unregister_player(id) # Remove Player From Server List
			rpc("unregister_player", id) # Notify Clients to do The Same

# Successfully Joined Server
func _on_connected_to_server():
	print("Connected To Server")
	
	# TODO: If client keeps spamming connect (say if player was banned), it will crash. This does not affect the server.
	# This comment is here, because it seems to have something to do with the client not being connected when it tries to run the connected code.
	# Also, there is no error from the crash except from the Godot code itself. I think this is a race condition bug in Godot.
	# I tried setting a timer on the set_network_peer to hold off on connecting, but that did not solve the crash.
	# The last error I got was (it "randomizes" the error message and sometimes doesn't display one at all).
	  # E 0:00:09:0516   Error calling method from signal 'join_success': 'CanvasLayer(NetworkMenu.gd)::_load_game_client': Method not found.
      # <C Source>     core/object.cpp:1238 @ emit_signal()
      # <Stack Trace>  network.gd:247 @ _on_connected_to_server()
	# The crash only happens if the player spams join when a server is available, so I am marking this comment to remind me to place another gui on screen on disconnect to prevent the player from being able to spam the join button.
	
	# If the crash really is about the signal, then I need to figure out how to verify the signal exists
	#if "join_success" in self.get_signal_list():
	#	emit_signal("join_success")
	emit_signal("join_success")

	gamestate.player_info.net_id = get_tree().get_network_unique_id() # Record Network ID
	rpc_id(1, "register_player", gamestate.player_info) # Ask Server To Update Player Dictionary - Server ID is Always 1
	register_player(gamestate.player_info) # Update Own Dictionary With Ourself

# Successfully Disconnected From Server
# TODO: Free Up Resources and Save Data (Client Side)
func _on_disconnected_from_server():
	print("Disconnected From Server")
	
	if(get_tree().get_network_peer() != null):
		players.clear() # Clear The Player List
		gamestate.player_info.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
		
		print("Attempt to Change Scene Tree - Disconnected From Server")
		
		# TODO: Maybe Pull Up A Disconnected Message GUI (which will then go to NetworkMenu)
		get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Failed To Connect To Server
func _on_connection_failed():
	emit_signal("join_fail") # Call Function to do Something on Fail (probably show GUI)
	get_tree().set_network_peer(null) # Disable Network Peer