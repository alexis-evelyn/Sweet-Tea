extends Node

# Player Registration is Meant to Keep Track of Player's Public Info (for both server and clients)
# The server will have a copy of a player's info no matter what world the player is in.
# The client will only have a copy of a player's info if the player is in the same world as the client.

# It's not necessary to add signal arguments here, but it helps when studying the code
# Signals - Used to Connect to Other GDScripts
signal player_removed(pinfo, id) # A Player Was Removed From The Player List

# Currently Registered Players
var players = {}
	
# Clients Notified To Add Player to Player List (Client and Server Side)
remote func register_player(pinfo, net_id: int):
	#print("Registering Player")
	
	if get_tree().get_rpc_sender_id() == 0:
		net_id = gamestate.net_id
	else:
		# If rpc_sender is not server, don't trust the given net_id
		if get_tree().get_rpc_sender_id() != 1:
			net_id = get_tree().get_rpc_sender_id()
	
	# Because of Server Adding To Registry Data - I Cannot Allow Client to Update Data Mid-Session
	if players.has(int(net_id)):
		return -1
	
	print("Registering player ", pinfo.name, " (", net_id, ") to internal player table")
	players[int(net_id)] = pinfo # Add Newly Joined Client to Dictionary of Clients
	
	if get_tree().is_network_server():
		# Add Starting World Name to Player Data (names are unique in the same parent node, so it can be treated as an id)
		players[int(net_id)].current_world = world_handler.starting_world_name # Add Current World to Server's Copy of Player Data - I can load last seen world from save instead of sending to spawn everytime the player connects
		
		# Make sure the client knows what world it is supposed to load
		rpc_unreliable_id(int(net_id), "set_current_world", players[int(net_id)].current_world)
		
		# Distribute Registered Clients Info to Clients
		for id in players:
			# Checks to Make Sure to Only Send Players in the Same World to New Player and Vice Versa
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

# Clients Notified To Remove Player From Player List
remote func unregister_player(id: int):
	# The Disconnect Function Already Takes Care of Validating This Data (for the server)
	# Still Validating For Client to Prevent Crash
	if players.has(id):
		print("Removing player ", players[id].name, " from internal table")
		
		var pinfo = players[id] # Cache player info for removal process
		players.erase(id) # Remove Player From Player List

puppet func set_current_world(current_world: String):
	players[int(gamestate.net_id)].current_world = current_world
	#print("Set Connected Current World: ", players[int(gamestate.net_id)].current_world)
	
	# Now that the current world has been set, ask server to spawn player
	rpc_unreliable_id(1, "spawn_player_server", gamestate.player_info) # Notify Server To Spawn Client
	
# How can I remove this and just have the rpc call go directly to spawn_handler?
master func spawn_player_server(pinfo) -> void:
	print("Client Requested Spawn")
	spawn_handler.spawn_player_server(pinfo)	

# Cleanup Connected Player List
func cleanup():
	players.clear()
	
# Standard Function to Check If players has player id (net_id)
func has(id: int):
	return players.has(id)
	
# Returns Player's Name
func name(id: int):
	return players[id].name
	
# Returns Player's Character's Color
func color(id: int):
	return players[id].char_color