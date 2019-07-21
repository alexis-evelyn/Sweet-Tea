extends Node2D

# panelPlayerStats is meant for information like health and a hotbar

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready():
	network.connect("player_list_changed", self, "_on_player_list_changed")
	
	# Do Not Run Below Code if Headless
	$HUD/panelPlayerList/lblLocalPlayer.text = gamestate.player_info.name # Display Local Client's Text on Screen

	if (get_tree().is_network_server()):
		# TODO: Make Sure Not To Execute spawn_player(...) if Running Headless
		spawn_players_server(gamestate.player_info) # Spawn Players (Currently Only Server's Player)
	else:
		rpc_id(1, "spawn_players_server", gamestate.player_info) # Request for Server To Spawn Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass

# For the server only
master func spawn_players_server(pinfo):
	var coordinates = Vector2(300, 300) # Get rid of all references to this
	
	if (get_tree().is_network_server() && pinfo.net_id != 1):
		# TODO: Validate That Player ID is Not Spoofed
		# We Are The Server and The New Player is Not The Server
		
		for id in network.players:
			# Spawn Existing Players for New Client (Not New Player)
			# All clients' coordinates (including server's coordinates) get sent to new client (except for the new client)
			if (id != pinfo.net_id):
				print("Existing: ", id, " For: ", pinfo.net_id, " At Coordinates: ", coordinates)
				# --------------------------Get rid of coordinates from the function arguments and retrieve coordinates from dictionary)--------------------------
				# Separate Coordinate Variable From Rest of Function
				rpc_id(pinfo.net_id, "spawn_players", network.players[id], coordinates) # TODO: This line of code is at fault for the current bug
				
			# Spawn the new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			# New Player's Coordinates gets sent to all clients (including new player/client) except the server
			if (id != 1):
				print("New: ", id, " For: ", pinfo.net_id, " At Coordinates: ", coordinates)
				# Same here, get from dictionary, keep separate
				rpc_id(id, "spawn_players", pinfo, coordinates)
				
	add_player(pinfo, coordinates)

# Spawns a new player actor, using the provided player_info structure and the given spawn index
# http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part03/ - "Spawning A Player"
# TODO (IMPORTANT): Let server decide coordinates and not client
# For client only
remote func spawn_players(pinfo, coordinates: Vector2):
	# TODO: Get Rid of Spawnpoint System (Use Code From Previous Server)
	#global_position = pinfo
	
	print("Spawning Player: ", pinfo.net_id, " At Coordinates: ", coordinates)
	
	if (get_tree().is_network_server() && pinfo.net_id != 1):
		# TODO: Validate That Player ID is Not Spoofed
		# We Are The Server and The New Player is Not The Server
		
		for id in network.players:
			# Spawn Existing Players for New Client (Not New Player)
			# All clients' coordinates (including server's coordinates) get sent to new client (except for the new client)
			if (id != pinfo.net_id):
				print("Existing: ", id, " For: ", pinfo.net_id, " At Coordinates: ", coordinates)
				# --------------------------Get rid of coordinates from the function arguments and retrieve coordinates from dictionary)--------------------------
				# Separate Coordinate Variable From Rest of Function
				rpc_id(pinfo.net_id, "spawn_players", network.players[id], coordinates) # TODO: This line of code is at fault for the current bug
				
			# Spawn the new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			# New Player's Coordinates gets sent to all clients (including new player/client) except the server
			if (id != 1):
				print("New: ", id, " For: ", pinfo.net_id)
				# Same here, get from dictionary, keep separate
				rpc_id(id, "spawn_players", pinfo, coordinates)
	
	add_player(pinfo, coordinates)
	
func add_player(pinfo, coordinates: Vector2):
	# Load the scene and create an instance
	var player_class = load(pinfo.actor_path)
	var new_actor = player_class.instance()
	# Setup player customization (well, the color)
	#nactor.set_dominant_color(pinfo.char_color)
	# And the actor position
	print("Actor: ", pinfo.net_id)
	# --------------------------
	new_actor.get_node("KinematicBody2D").position = coordinates # Note To Self: This Works Fine
	new_actor.set_name(str(pinfo.net_id))
	
	# If this actor does not belong to the server, change the network master accordingly
	if (pinfo.net_id != 1):
		new_actor.set_network_master(pinfo.net_id)
		
	# Finally add the actor into the world
	add_child(new_actor)

# Update Player List in GUI
func _on_player_list_changed():
	# Remove Nodes From Boxlist
	for node in $HUD/panelPlayerList/boxList.get_children():
		node.queue_free()
	
	# Populate Boxlist With Player Names
	for player in network.players:
		if (player != gamestate.player_info.net_id):
			var nlabel = Label.new()
			nlabel.text = network.players[player].name
			$HUD/panelPlayerList/boxList.add_child(nlabel)