extends Node
class_name PlayerRegistrar

# Player Registration is Meant to Keep Track of Player's Public Info (for both server and clients)
# The server will have a copy of a player's info no matter what world the player is in.
# The client will only have a copy of a player's info if the player is in the same world as the client.

# It's not necessary to add signal arguments here, but it helps when studying the code
# Signals - Used to Connect to Other GDScripts
# warning-ignore:unused_signal
signal player_removed(pinfo, id) # A Player Was Removed From The Player List
signal world_set # Server World Name Was Set

# Currently Registered Players
var players : Dictionary = {}

# Clients Notified To Add Player to Player List (Client and Server Side)
remote func register_player(pinfo: Dictionary, net_id: int, new_world : bool = false) -> int:
	# new_world is for spawn handler to make sure player is registered (this is if registry failed through normal rpc call - makes game more robust in the event of packet loss)
	#logger.verbose("Registering Player")

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

	#logger.verbose("Registering Player %s (%s) to Player Registry" % [pinfo.name, net_id])
	# If Character Color is Missing, Then Set Character Color to Default Color
	if not pinfo.has("char_color"):
		pinfo.char_color = Color.white

	players[int(net_id)] = pinfo # Add Newly Joined Client to Dictionary of Clients

	if get_tree().is_network_server():
		# TODO: Change to use a permanent id supplied by auth server
		# The idea is that this id cannot be manipulated by the user. In essence, it is secure (as opposed to char_unique_id or os_unique_id)
		players[int(net_id)].display_name = "%s#%s" % [pinfo.name, net_id] # Setup Player's ID to be Unique
		players[int(net_id)].secure_unique_id = net_id # Copy the id to a value that can be easily retrieved (without parsing overhead)

		# Add Starting World Name to Player Data (names are unique in the same parent node, so it can be treated as an id)
		players[int(net_id)].current_world = world_handler.starting_world_name # Add Current World to Server's Copy of Player Data - I can load last seen world from save instead of sending to spawn everytime the player connects

		# If the server tries to call this on itself it returns method/function failed. This makes sure server only sends this rpc to clients.
		if net_id != 1:
			players[int(net_id)].permission_level = ServerCommands.permission_level.player # Set Default Permission Level
			# Make sure the client knows what world it is supposed to load
			rpc_unreliable_id(int(net_id), "set_current_world", players[int(net_id)].current_world)
		else:
			players[int(net_id)].permission_level = ServerCommands.permission_level.server_owner # Set Default Permission Level

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
		pinfo.display_name = "Unnamed Player"
		return -2 # Allows Client and Server to Know it had to Change Player's Name Due To Name Missing - I May Implement A Custom Error Enum

	return 0

# Clients Notified To Remove Player From Player List
remote func unregister_player(id: int) -> void:
	# The Disconnect Function Already Takes Care of Validating This Data (for the server)
	# Still Validating For Client to Prevent Crash
	if players.has(id):
		#logger.verbose("Removing Player %s From Player Registry" % players[id].name)

		# warning-ignore:unused_variable
		var pinfo : Dictionary = players[id] # Cache player info for removal process
		players.erase(id) # Remove Player From Player List

# Get current world name to download from server
puppet func set_current_world(current_world: String) -> void:
	players[int(gamestate.net_id)].current_world = current_world # Set World to Download From Server
	#logger.verbose("Set Connected Current World: %s" % players[int(gamestate.net_id)].current_world)

	emit_signal("world_set") # Allows Loading World From Server on Successful Connection

# Send client a copy of players in new world - net_id is who I am sending the info to
func update_players(net_id: int, id: int) -> void:
	if not players.has(int(id)):
		#logger.verbose("Update Players Failed: ID does not exists: '%s', id")
		return

	# Can I check if an RPC id exists? I could indirectly with player registration.

	#logger.verbose("Update Players - Player: %s World: %s" % [id, players[int(id)].current_world])
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
	if not players.has(id):
		logger.error("Return Player Name Failed: Player ID '%s' Not Registered!!!" % str(id))
		return ""

	if not players[id].has("name"):
		logger.warning("Return Player Name Failed: Player Name for ID '%s' Is Not Set!!!" % str(id))
		return "Not Set - Failed Name Lookup"

	return players[id].name

# Returns Player's Display Name
func display_name(id: int) -> String:
	if not players.has(id):
		logger.error("Return Player Display Name Failed: Player ID '%s' Not Registered!!!" % str(id))
		return ""

	if not players[id].has("display_name"):
		logger.warning("Return Player Name Failed: Player Display Name for ID '%s' Is Not Set!!!" % str(id))
		return "Not Set - Failed Display Name Lookup"

	return players[id].display_name

# Returns Player's Character's Color
func color(id: int) -> Color:
	if not players.has(id):
		# This should never be called as the player spawn code requires the player to be registered (otherwise the server registers the player anyway)
		logger.error("Return Player Color Failed: Player ID '%s' Not Registered!!!" % str(id))
		return Color.firebrick

	if not players[id].has("char_color"):
		# This should never be called as a default color is assigned during player registry (if color is missing)
		logger.warning("Return Player Color Failed: Player Color for ID '%s' Not Set!!!" % str(id))
		return Color.white # This could potentially happen. Set it to default color.

	return Color(players[id].char_color)

func get_class() -> String:
	return "PlayerRegistrar"
