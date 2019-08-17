extends Node

# Player Registration is Meant to Keep Track of Player's Public Info (for both server and clients)
# The server will have a copy of a player's info no matter what world the player is in.
# The client will only have a copy of a player's info if the player is in the same world as the client.

# It's not necessary to add signal arguments here, but it helps when studying the code
# Signals - Used to Connect to Other GDScripts
# warning-ignore:unused_signal
signal player_removed(pinfo, id) # A Player Was Removed From The Player List

# Currently Registered Players
var players : Dictionary = {}
	
# Clients Notified To Add Player to Player List (Client and Server Side)
remote func register_player(pinfo: Dictionary, net_id: int, new_world : bool = false) -> int:
	# new_world is for spawn handler to make sure player is registered (this is if registry failed through normal rpc call - makes game more robust in the event of packet loss)
	#print("Registering Player")
	
	# Only check new_world if caller is self - prevents net_id spoofing
	if (get_tree().get_rpc_sender_id() == 0) and (new_world == false):
		net_id = gamestate.net_id
	else:
		# If rpc_sender is not server, don't trust the given net_id
		if get_tree().get_rpc_sender_id() != 1:
			net_id = get_tree().get_rpc_sender_id()
	
	# Because of Server Adding To Registry Data - I Cannot Allow Client to Update Data Mid-Session
	# This is overriden if the server is sender - allows updating player info on world change and modded servers can change player's info on a vanilla client
	if players.has(int(net_id)) and get_tree().get_rpc_sender_id() != 1:
		return -1
	
	#print("Registering player ", pinfo.name, " (", net_id, ") to internal player table")
	players[int(net_id)] = pinfo # Add Newly Joined Client to Dictionary of Clients
	
	if get_tree().is_network_server():
		# Add Starting World Name to Player Data (names are unique in the same parent node, so it can be treated as an id)
		players[int(net_id)].current_world = world_handler.starting_world_name # Add Current World to Server's Copy of Player Data - I can load last seen world from save instead of sending to spawn everytime the player connects
		
		# If the server tries to call this on itself it returns method/function failed. This makes sure server only sends this rpc to clients.
		if net_id != 1:
			# Make sure the client knows what world it is supposed to load
			rpc_unreliable_id(int(net_id), "set_current_world", players[int(net_id)].current_world)
		
		# Distribute Registered Clients Info to Clients
		for id in players:
			# Checks to Make Sure to Only Send Players in the Same World to New Player and Vice Versa
			
			# Player registry happens before player spawn, so I cannot just loop the players node.
			# After game release (if the game goes well), I am planning on rewriting the network code to make this more efficient.
			# This will make it easier for servers to handle large amounts of players at once.
			if players[int(id)].current_world == players[int(net_id)].current_world:
				# Make Sure Not To Call Yourself or Other Clients Already Registered
				if id != net_id:
					# Send Registered Clients to Newly Joined Client
					rpc_unreliable_id(net_id, "register_player", players[int(id)], id)
				
				# Send Newly Joined Client Info to All Other Clients
				if (id != 1):
					rpc_unreliable_id(id, "register_player", players[int(net_id)], net_id)
	
	if not pinfo.has("name"):
		pinfo.name = "Unnamed Player"
		return -2 # Allows Client and Server to Know it had to Change Player's Name Due To Name Missing - I May Implement A Custom Error Enum
		
	return 0

# Clients Notified To Remove Player From Player List
remote func unregister_player(id: int) -> void:
	# The Disconnect Function Already Takes Care of Validating This Data (for the server)
	# Still Validating For Client to Prevent Crash
	if players.has(id):
		#print("Removing player ", players[id].name, " from internal table")
		
	# warning-ignore:unused_variable
		var pinfo : Dictionary = players[id] # Cache player info for removal process
		players.erase(id) # Remove Player From Player List

# Get current world name to download from server
puppet func set_current_world(current_world: String) -> void:
	players[int(gamestate.net_id)].current_world = current_world # Set World to Download From Server
	#print("Set Connected Current World: ", players[int(gamestate.net_id)].current_world)
	
	world_handler.load_world_client() # Download World From Server

# Send client a copy of players in new world - net_id is who I am sending the info to
func update_players(net_id: int, id: int) -> void:
	print("Update Players - Player: ", id, " World: ", players[int(id)].current_world)
	if net_id != 1:
		rpc_unreliable_id(net_id, "register_player", players[int(id)], id)

# Cleanup Connected Player List
func cleanup() -> void:
	players.clear()
	
# Standard Function to Check If players has player id (net_id)
func has(id: int) -> bool:
	return players.has(id)
	
# Returns Player's Name
func name(id: int) -> String:
	return players[id].name
	
# Returns Player's Character's Color
func color(id: int) -> Color:
	return Color(players[id].char_color)
