extends Node
class_name SpawnHandler

# Signals
signal player_list_changed # Player's Spawned in World

# Load the scene and create an instance
var player_class : Resource = preload("res://Objects/Players/Player.tscn") # Load Default Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_handler.connect("server_started", self, "spawn_player_server") # Spawn Server's Player's Character on Emission of Signal
	player_registrar.connect("player_removed", self, "player_removed")

# For the server only
master func spawn_player_server(pinfo: Dictionary) -> int:
	# QUESTION: Should I place the player nodes under the world nodes?
	# If I place player nodes under the world nodes, it can make the server more efficiently check if there are players in the world
	# before the server decides to unload the world. It means more complicated spawn/despawn code, but it will make world loading so much easier.

	var net_id : int = -1

	if pinfo.has("os_unique_id"):
		logger.verbose("Player ID: %s OS Unique ID: %s" % [net_id, pinfo.os_unique_id])

	if pinfo.has("char_unique_id"):
		logger.verbose("Player ID: %s Character Unique ID: %s" % [net_id, pinfo.char_unique_id])

	if get_tree().get_rpc_sender_id() == 0:
		net_id = gamestate.net_id
	else:
		net_id = get_tree().get_rpc_sender_id()

	var coordinates : Vector2
	# Currently Coordinates are Randomly Chosen
	# warning-ignore:narrowing_conversion
	var coor_x : int = rand_range(100,900)
	# warning-ignore:narrowing_conversion
	var coor_y : int = rand_range(100,500)
	if player_registrar.players[net_id].has("world_spawn"):
		coordinates = get_world_generator_node(get_world_name(net_id)).find_safe_spawn(Vector2(coor_x, coor_y), player_registrar.players[net_id].world_spawn)
		player_registrar.players[net_id].erase("world_spawn")

	elif player_registrar.players[net_id].has("spawn_coordinates"):
		# TODO: Add /tp command and use this to set spawn coordinates...
		coordinates = get_world_generator_node(get_world_name(net_id)).find_safe_spawn(player_registrar.players[net_id].spawn_coordinates)
		player_registrar.players[net_id].erase("spawn_coordinates")

	elif player_registrar.players[net_id].has("spawn_coordinates_safety_off"):
		# TODO: Add /tp command and use this to set spawn coordinates...
		coordinates = player_registrar.players[net_id].spawn_coordinates_safety_off
		player_registrar.players[net_id].erase("spawn_coordinates_safety_off")

	else:
		coordinates = get_world_generator_node(get_world_name(net_id)).find_safe_spawn(Vector2(coor_x, coor_y))

	if (get_tree().is_network_server()):
		# We Are The Server and The New Player is Not The Server

		# Apparently the RPC ID (used as Player ID) is safe from spoofing? I need to do more research just to be sure.
		# https://www.reddit.com/r/godot/comments/bf4z8r/is_get_rpc_sender_id_safe_enough/eld38y8?utm_source=share&utm_medium=web2x

		# Make Sure Player Registered With Server First (keeps from having invisible clients)
		if !player_registrar.has(net_id):
			return ERR_DOES_NOT_EXIST

		for id in player_registrar.players:
			# Spawn Existing Players for New Client (Not New Player)
			# All clients' coordinates (in same world) (including server's coordinates) get sent to new client (except for the new client)
			# There's a bug where if a client crashes during spawn, then somehow the server tries to rpc itself. This won't crash the server but it can unnecessarily add to the server log.

			if (id != net_id) and (get_world_name(id) == player_registrar.players[int(net_id)].current_world):
				var player : Node # Player Object
				if get_players_node(str(get_world_name(id))).has_node(str(id)):
					player = get_players_node(str(get_world_name(id))).get_node(str(id) + "/KinematicBody2D") # Grab Existing Player's Object (Server Only)
					#logger.verbose("Existing: %s For: %s At Coordinates: %s World: %s" % [id, net_id, player.position, get_world_name(id)]) # player.position grabs existing player's coordinates

					player_registrar.update_players(int(net_id), int(id)) # Updates Client's Player Registry to let it know about clients already in the world
					#logger.verbose("Your NetID: %s" % net_id)
					if net_id != 1:
						rpc_unreliable_id(net_id, "spawn_player", player_registrar.players[int(id)], id, player.position) # Send Existing Clients' Info to New Client
					else:
						spawn_player(player_registrar.players[int(id)], id, player.position) # Send Existing Clients' Info to New Client

			# Spawn the new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			# New Player's Coordinates gets sent to all clients (within the same world) (including new player/client) except the server
			if (id != 1) and (get_world_name(id) == get_world_name(net_id)):
				#logger.verbose("New: %s For: %s At Coordinates: %s World: %s" % [id, net_id, coordinates, get_world_name(id)])
				player_registrar.update_players(int(id), int(net_id)) # Updates Client's Player Registry to let it know about new client joining world
				rpc_unreliable_id(id, "spawn_player", pinfo, net_id, coordinates) # Send New Client's Info to Existing Clients

	logger.verbose("NetID: %s Gamestate ID: %s" % [net_id, gamestate.net_id])

	# Run Specific RPC calls on Player Spawn
	if net_id == gamestate.net_id:
		network.set_client_title(tr("spawn_world_title") % gamestate.player_info.current_world) # This won't show up on server start (I think because the player selection menu is lagging behind due to not threading the world loader)
	else:
		var client_locale : String = "en" # English is default as it is the international business language
		if player_registrar.players[int(net_id)].has("locale"):
			client_locale = player_registrar.players[int(net_id)].locale

		var message : String = functions.get_translation("spawn_world_title", client_locale)

		# Psuedo Code
		# var client_title : String = TranslationServer.get_translation("set_client_title", "language")
		network.rpc_id(net_id, "set_client_title", message % player_registrar.players[int(net_id)].current_world)

	add_player(pinfo, net_id, coordinates) # TODO: Check to see if this is what causes problems with the Headless Server Mode
	return OK

# Spawns a new player actor, using the provided player_info structure and the given spawn index
# http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part03/ - "Spawning A Player"
# For client only
puppet func spawn_player(pinfo: Dictionary, net_id: int, coordinates: Vector2) -> void:
	#logger.verbose("Spawning Player: " + str(net_id) + " At Coordinates: " + str(coordinates))
	add_player(pinfo, net_id, coordinates)

# Spawns Player in World (Client and Server)
func add_player(pinfo: Dictionary, net_id: int, coordinates: Vector2) -> void:
	#if pinfo.has("actor_path"):
	#	player_class = load(pinfo.actor_path)

	var new_actor : Node2D = player_class.instance()

	# TODO: Make Sure Alpha is 255 (fully opaque). We don't want people cheating...
	# Setup Player Customization
	# Player Customizations (by json) will be performed in another function that will be called here!!!

	var char_color : Color = Color.white
	if pinfo.has("char_color"):
		char_color = Color(pinfo.char_color).to_html(false) # Since alpha is disabled, transparency should be disabled.

	new_actor.get_node("KinematicBody2D").set_dominant_color(char_color) # The player script is attached to KinematicBody2D, hence retrieving its node

	#logger.verbose("Actor: %s" % net_id)
	new_actor.get_node("KinematicBody2D").position = coordinates # Setup Player's Position

	new_actor.set_name(str(net_id)) # Set Player's ID (useful for referencing the player object later)

	# Hand off control to player's client (the server already controls itself)
	if (net_id != 1):
		new_actor.set_network_master(net_id)

	# If the player does not exist in the registry, then the client will keep having rpc errors from a non-existant player node
	# I don't know how to get Godot to silently ignore these rpc errors
	if player_registrar.has(net_id):
		# Add the player to the world
		#add_child(new_actor)
		var player_current_world : String = get_world_name(net_id)
		var world_grid : TileMap = get_world_grid(player_current_world)

		if world_grid == null:
			return

		# Add Players Node (just a plain node) to put Players in
		if get_players_node(player_current_world) == null:
			var players_node : Node = Node.new()
			players_node.name = "Players"

			world_grid.add_child(players_node)

		#logger.superverbose("Player %s Current World: %s" % [net_id, player_current_world])

		# Make sure client does not try to spawn player twice (to cause server crash)
		if not get_players_node(player_current_world).has_node(new_actor.name):
			get_players_node(player_current_world).add_child(new_actor) # Adds Player to Respective World Node
			network.server_info.num_players += 1 # Add One To Player Count

			emit_signal("player_list_changed") # Notify Client Of List Change
		else:
			logger.verbose("Cannot Spawn Twice: %s" % net_id)
	else:
		# Player was not registered, so there is going to be an invisible client
		# That is not good, so add player to registry and call ourself again
		#logger.verbose("Player Missing From Registry!!! Trying to Add to Registry!!!")
		player_registrar.register_player(pinfo, net_id, true)
		add_player(pinfo, net_id, coordinates)

# Server and Client - Despawn Player From Local World
remote func despawn_player(net_id: int) -> void:
	if (get_tree().is_network_server()):
		for id in player_registrar.players:
			# Skip sending the despawn packet to both the disconnected player and the server (itself)
			if (id == net_id || id == gamestate.standard_netids.server):
				continue

			# Notify players (clients) of despawned player
			rpc_unreliable_id(id, "despawn_player", net_id)

	# Locate Player To Despawn
	if player_registrar.has(net_id):
		var player_current_world : String = get_world_name(net_id)
		var players : Node = get_players_node(player_current_world)

		if (players == null):
			#logger.verbose("World Already Cleaned Up!!!")
			return

		var player_node : Node # Player Object
		if players.has_node(str(net_id)): # Check to Make Sure Node Exists
			player_node = players.get_node(str(net_id)) # Grab Existing Player's Node (Server and Client)

		if (!player_node):
			logger.warning("Failed To Find Player To Despawn")
			return

		# Despawn Player from World
		network.server_info.num_players -= 1 # Remove One From Player Count
		player_node.free() # Set to free so the player node gets freed immediately for respawn (if changing world) - Now that the player nodes are in different sections of the tree, do I really need to immediately disconnect the player?
		emit_signal("player_list_changed") # Notify Client Of List Change
	else:
		logger.error("Player Registrar Missing %s Cannot Locate Player Node to Despawn!!!" % net_id)

# Changing Worlds - Perform Cleanup and Load World
remote func change_world(world_name: String, same_world: bool = false) -> void:
	#logger.verbose("Player %s Change World: %s" % [gamestate.net_id, get_world_name(gamestate.net_id)])
	get_tree().get_root().get_node("PlayerUI/panelPlayerList").cleanup() # Cleanup Player List

	# Download World using network.gd and Load it using world_handler.gd
	# If I use HTTP to transfer world, world_path will be replaced by a URL
	# If Using RPC, I can get rid of world_path altogether

	# The Server Would Have Already Updated World Name - No Need to Set Twice
	if not get_tree().is_network_server():
		# Don't despawn world if the same world
		if not same_world:
			var worlds = get_tree().get_root().get_node("Worlds")
			worlds.get_node(get_world_name(gamestate.net_id)).free() # Frees the World and It's Children From Memory (Client Side Only)

			set_world_name(world_name)

			var spawn = load(world_handler.world_template).instance()
			spawn.name = world_name

			worlds.add_child(spawn)
		# TODO (IMPORTANT): Every once in a blue moon, the client does not spawn it's own player in (after it loads the world) after changing worlds. Figure out why!!!
		rpc_unreliable_id(gamestate.standard_netids.server, "spawn_player_server", gamestate.player_info) # Request Server Spawn
	elif get_tree().is_network_server():
		# There's a bug specific to the server player changing to a world with existing clients
		# The existing clients won't see the server player (this does not affect a client with existing clients)
		# To fix the issue and be more efficient with cpu cycles, I am updating the player registry on the client with the server here

		var world : String = get_world_name(gamestate.net_id) # net_id should be 1 since this is the server

		# Check to make sure Players node exists and if so, loop through players to update
		if has_players_node(world):
			var players : Node = get_players_node(world) # Get Players Node from World

			for player in players.get_children():
				#logger.verbose("Updating: %s With Server Info!!!" % player.name)

				# First argument is who I am sending the update to, second is who's info I am sending
				player_registrar.update_players(int(player.name), int(gamestate.net_id)) # Updates Client's Player Registry to let it know about server joining world

		spawn_player_server(gamestate.player_info)

# Sets Player's Current World Name - Added To Make Code More Legible
func set_world_name(world_name: String) -> void:
	player_registrar.players[gamestate.net_id].current_world = world_name

# Gets Player's Current World Name - Added To Make Code More Legible
func get_world_name(net_id: int) -> String:
	if not player_registrar.players.has(int(net_id)) or not player_registrar.players[int(net_id)].has("current_world"):
		return functions.empty_string

	return str(player_registrar.players[int(net_id)].current_world)

func get_world_node(world_name: String) -> Node:
	"""
		Get World Node By Name
	"""

	var worlds : Node

	if not get_tree().get_root().has_node("Worlds"):
		return null

	worlds = get_tree().get_root().get_node("Worlds") # Get Worlds node

	if worlds.has_node(world_name):
		return worlds.get_node(world_name)

	return null

# Get World Grid Node - Added To Make Code More Legible
func get_world_grid(world_name: String) -> Node:
	logger.superverbose("WorldGrid: %s" % world_name)

	if not get_tree().get_root().has_node("Worlds/" + world_name + "/Viewport/WorldGrid/"):
		return null

	return get_tree().get_root().get_node("Worlds/" + world_name + "/Viewport/WorldGrid/")

# Check for Players Node - Added To Make Code More Legible
func has_players_node(world: String) -> bool:
	return get_world_grid(world).has_node("Players")

# Get Players Node - Added To Make Code More Legible
func get_players_node(world: String) -> Node:
	# This can cause crash (changeworld client first, then server)
	if get_world_grid(world) == null or not get_world_grid(world).has_node("Players"):
		return null

	return get_world_grid(world).get_node("Players")

func get_player_node(net_id: int) -> Node:
	# This can cause crash (changeworld client first, then server)
	if get_world_grid(get_world_name(net_id)) == null or not get_world_grid(get_world_name(net_id)).has_node("Players"):
		return null

	if not get_world_grid(get_world_name(net_id)).get_node("Players").has_node(str(net_id)):
		return null

	return get_world_grid(get_world_name(net_id)).get_node("Players").get_node(str(net_id))

func get_player_body_node(net_id: int) -> Node:
	# This can cause crash (changeworld client first, then server)
	if get_world_grid(get_world_name(net_id)) == null or not get_world_grid(get_world_name(net_id)).has_node("Players"):
		return null

	if not get_world_grid(get_world_name(net_id)).get_node("Players").has_node(str(net_id)):
		return null

	if not get_world_grid(get_world_name(net_id)).get_node("Players").get_node(str(net_id)).has_node("KinematicBody2D"):
		return null

	return get_world_grid(get_world_name(net_id)).get_node("Players").get_node(str(net_id)).get_node("KinematicBody2D")

func get_world_generator_node(world: String) -> Node:
	if not get_world_grid(world).has_node("WorldGen"):
		return null

	return get_world_grid(world).get_node("WorldGen")

func get_class() -> String:
	return "SpawnHandler"
