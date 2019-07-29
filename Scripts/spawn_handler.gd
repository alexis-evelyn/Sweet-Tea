extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	world_handler.connect("server_started", self, "spawn_player_server") # Spawn Server's Player's Character on Emission of Signal
	player_registrar.connect("player_removed", self, "player_removed")

# For the server only
master func spawn_player_server(pinfo):
	# QUESTION: Should I place the player nodes under the world nodes?
	# If I place player nodes under the world nodes, it can make the server more efficiently check if there are players in the world
	# before the server decides to unload the world. It means more complicated spawn/despawn code, but it will make world loading so much easier.
	
	var net_id = -1
	
	if pinfo.has("os_unique_id"):
		print("OS Unique ID: " + pinfo.os_unique_id)
	
	if pinfo.has("char_unique_id"):
		print("Character Unique ID: " + pinfo.char_unique_id)
	
	# Currently Coordinates are Randomly Chosen
	var coor_x = rand_range(100,900)
	var coor_y = rand_range(100,500)
	var coordinates = Vector2(coor_x, coor_y)
	
	if get_tree().get_rpc_sender_id() == 0:
		net_id = gamestate.net_id
	else:
		net_id = get_tree().get_rpc_sender_id()
		
	if (get_tree().is_network_server() && net_id != 1):
		# We Are The Server and The New Player is Not The Server
		
		# TODO: Validate That Player ID is Not Spoofed
		# Apparently the RPC ID (used as Player ID) is safe from spoofing? I need to do more research just to be sure.
		# https://www.reddit.com/r/godot/comments/bf4z8r/is_get_rpc_sender_id_safe_enough/eld38y8?utm_source=share&utm_medium=web2x
		
		# Make Sure Player Registered With Server First (keeps from having invisible clients)
		if !player_registrar.has(net_id):
			return -1
		
		for id in player_registrar.players:
			# Spawn Existing Players for New Client (Not New Player)
			# All clients' coordinates (in same world) (including server's coordinates) get sent to new client (except for the new client)
			if (id != net_id) and (player_registrar.players[int(id)].current_world == player_registrar.players[int(net_id)].current_world):
				var player = get_tree().get_root().get_node("Worlds/" + str(player_registrar.players[int(id)].current_world) + "/Viewport/WorldGrid").get_node(str(id) + "/KinematicBody2D") # Grab Existing Player's Object (Server Only)
				print("Existing: ", id, " For: ", net_id, " At Coordinates: ", player.position, " World: ", player_registrar.players[int(id)].current_world) # player.position grabs existing player's coordinates
				# --------------------------Get rid of coordinates from the function arguments and retrieve coordinates from dictionary)--------------------------
				# Separate Coordinate Variable From Rest of Function
				
				# There seems to be a bug where if the client is kicked three times, then it crashes and can bring down the server either immediately or bring it down upon joining again.
				# The server is brought down by a non-existent client node (I do not know why the client crashes as Godot's ENET code throws errors, not my code). However, solving the server crash issue seems to fix the client crash issue too.
				# I am leaving these comments here incase the bug is still active. I need to make sure the client cannot send malformed packets and crash the server.
				if !get_tree().get_root().get_node("Worlds/" + str(player_registrar.players[int(id)].current_world) + "/Viewport/WorldGrid").get_node(str(id) + "/KinematicBody2D"): # Checks Player Node Exists (incase of malformed client packets)
					print("Node Does Not Exist!!! Client is: ", str(id))
					break # Stops For Loop
				
				rpc_id(net_id, "spawn_player", player_registrar.players[int(id)], id, player.position) # TODO: This line of code is at fault for the current bug
				
			# Spawn the new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			# New Player's Coordinates gets sent to all clients (within the same world) (including new player/client) except the server
			if (id != 1) and (player_registrar.players[int(id)].current_world == player_registrar.players[int(net_id)].current_world):
				print("New: ", id, " For: ", net_id, " At Coordinates: ", coordinates, " World: ", player_registrar.players[int(id)].current_world)
				# Same here, get from dictionary, keep separate
				rpc_id(id, "spawn_player", pinfo, net_id, coordinates)
				
	# TODO: Check to see if this is what causes problems with the Headless Server Mode
	add_player(pinfo, net_id, coordinates)

# Spawns a new player actor, using the provided player_info structure and the given spawn index
# http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part03/ - "Spawning A Player"
# TODO (IMPORTANT): Let server decide coordinates and not client
# For client only
puppet func spawn_player(pinfo, net_id: int, coordinates: Vector2):
	#global_position = pinfo
	
	print("Spawning Player: " + str(net_id) + " At Coordinates: " + str(coordinates))
	
	if (get_tree().is_network_server() && net_id != 1):
		# TODO: Validate That Player ID is Not Spoofed
		# We Are The Server and The New Player is Not The Server
		
		for id in player_registrar.players:
			# Spawn Existing Players for New Client (Not New Player)
			# All clients' coordinates (including server's coordinates) get sent to new client (except for the new client)
			if (id != net_id):
				print("Existing: ", id, " For: ", net_id, " At Coordinates: ", coordinates)
				# --------------------------Get rid of coordinates from the function arguments and retrieve coordinates from dictionary)--------------------------
				# Separate Coordinate Variable From Rest of Function
				rpc_id(net_id, "spawn_player", player_registrar.players[int(id)], net_id, coordinates) # TODO: This line of code is at fault for the current bug
				
			# Spawn the new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			# New Player's Coordinates gets sent to all clients (including new player/client) except the server
			if (id != 1):
				print("New: ", id, " For: ", net_id)
				# Same here, get from dictionary, keep separate
				rpc_id(id, "spawn_player", pinfo, net_id, coordinates)
	
	add_player(pinfo, net_id, coordinates)

# Spawns Player in World (Client and Server)
func add_player(pinfo, net_id, coordinates: Vector2):
	# Load the scene and create an instance
	var player_class = load("res://Objects/Players/Player.tscn") # Load Default Player
	if pinfo.has("actor_path"):
		player_class = load(pinfo.actor_path)
		
	var new_actor = player_class.instance()
	
	# TODO: Make Sure Alpha is 255 (fully opaque). We don't want people cheating...
	# Setup Player Customization
	
	var char_color = "ffffff"
	if pinfo.has("char_color"):
		char_color = pinfo.char_color
	
	new_actor.get_node("KinematicBody2D").set_dominant_color(char_color) # The player script is attached to KinematicBody2D, hence retrieving its node
	
	print("Actor: ", net_id)
	new_actor.get_node("KinematicBody2D").position = coordinates # Setup Player's Position
	
	new_actor.set_name(str(net_id)) # Set Player's ID (useful for referencing the player object later)
	
	# Hand off control to player's client (the server already controls itself)
	if (net_id != 1):
		new_actor.set_network_master(net_id)
		
	if player_registrar.has(net_id):
		# Add the player to the world
		#add_child(new_actor)
		var player_current_world = str(player_registrar.players[int(net_id)].current_world)
		
		print("Player ", net_id, " Current World: ", player_current_world)
		get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid").add_child(new_actor) # Adds Player to Respective World Node

# Server and Client - Despawn Player From Local World
remote func despawn_player(net_id):
	# TODO: Fix Error Mentioned at: http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part03/. The error does not break the game at all, it just spams the console.
	# "ERROR: _process_get_node: Invalid packet received. Unabled to find requested cached node. At: core/io/multiplayer_api.cpp:259."
	
	if (get_tree().is_network_server()):
		for id in player_registrar.players:
			# Skip sending the despawn packet to both the disconnected player and the server (itself)
			if (id == net_id || id == 1):
				continue
			
			# Notify players (clients) of despawned player
			rpc_id(id, "despawn_player", net_id)
	
	# Locate Player To Despawn
	if player_registrar.has(net_id):
		var player_current_world = str(player_registrar.players[int(net_id)].current_world)
		var player_node = get_tree().get_root().get_node("Worlds/" + player_current_world + "/Viewport/WorldGrid/" + str(net_id)) # Grab Existing Player's Object (Server Only) - I May Create Some Functions to Shorten This for Readability
	
		if (!player_node):
			printerr("Failed To Find Player To Despawn")
			return
			
		# Despawn Player from World
		player_node.free() # Set to free so the player node gets freed immediately for respawn (if changing world)
	else:
		printerr("Player Registrar Missing ", net_id, " Cannot Locate Player Node to Despawn!!!")
		
# Changing Worlds - Perform Cleanup and Load World
remote func change_world(world_name: String, world_path: String):
	print("Player ", gamestate.net_id, " Change World: ", player_registrar.players[gamestate.net_id].current_world)
	get_tree().get_root().get_node("PlayerUI/panelPlayerList").cleanup() # Cleanup Player List

	# Download World using network.gd and Load it using world_handler.gd
	# If I use HTTP to transfer world, world_path will be replaced by a URL
	# If Using RPC, I can get rid of world_path altogether

	# The Server Would Have Already Updated World Name - No Need to Set Twice
	if not get_tree().is_network_server():
		player_registrar.players[gamestate.net_id].current_world = world_name
		world_handler.load_world(gamestate.net_id, world_path)
	
	rpc_id(1, "spawn_player_server", gamestate.player_info) # Request Server Spawn
	
# Remove Player Nodes From Spawn Handler
func cleanup():
	# Remove Nodes From spawn_handler
	for node in self.get_children():
		node.queue_free()