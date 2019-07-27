extends Node

# It's not necessary to add signal arguments here, but it helps when studying the code
# Signals - Used to Connect to Other GDScripts
signal player_list_changed # 
signal player_removed(pinfo, id) # A Player Was Removed From The Player List

# Currently Registered Players
var players = {}
	
# Clients Notified To Add Player to Player List (Client-Side)
puppet func register_player(pinfo, net_id: int):
	if get_tree().get_rpc_sender_id() == 0:
		net_id = gamestate.net_id
	else:
		# If rpc_sender is not server, don't trust the given net_id
		if get_tree().get_rpc_sender_id() != 1:
			net_id = get_tree().get_rpc_sender_id()
	
	if get_tree().is_network_server():
		# Distribute Registered Clients Info to Clients
		for id in players:
			# Send Registered Clients to Newly Joined Client
			rpc_id(net_id, "register_player", players[int(id)], id)
			
			# Send Newly Joined Client Info to All Other Clients
			if (id != 1):
				rpc_id(id, "register_player", pinfo, net_id)
	
	if not pinfo.has("name"):
		pinfo.name = "Unnamed Player"
	
	print("Registering player ", pinfo.name, " (", net_id, ") to internal player table")
	players[int(net_id)] = pinfo # Add Newly Joined Client to Dictionary of Clients
	emit_signal("player_list_changed") # Notify Clients That Client List Has Changed

# Clients Notified To Remove Player From Player List
remote func unregister_player(id: int):
	print("Removing player ", players[id].name, " from internal table")
	
	var pinfo = players[id] # Cache player info for removal process
	players.erase(id) # Remove Player From Player List
	
	emit_signal("player_list_changed") # Notify Clients Of List Change
	emit_signal("player_removed", pinfo, id) # Request Server To Remove Player
	
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