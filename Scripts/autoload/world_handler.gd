extends Node
class_name WorldHandler

signal server_started(gamestate_player_info) # Server Started Up and World is Loaded - Spawns Server Player
signal cleanup_worlds

signal missing_starting_world
signal missing_starting_world_reference
signal missing_current_world_reference
signal failed_loading_world

signal world_created
signal world_loaded_server
signal world_loaded_client

# Chunk Loading (like in Minecraft) is perfectly possible with Godot - https://www.reddit.com/r/godot/comments/8shad4/how_do_large_open_worlds_work_in_godot/
# I ultimately plan on having multiple worlds which the players can join on the server. As for singleplayer, it is going to be a server that refuses connections unless the player opens it up to other players.
# I also want to have a "home" that players spawn at before they join the world_template (like how Starbound has a spaceship. but I want my home to be an actual world that will be the player's home world. The player can then use portals to join the server world.
const world_template : String = "res://WorldGen/WorldTemplate.tscn" # What Scene to use to instance the world into (Client Side)
const loading_screen_name : String = "res://Menus/LoadingScreen.tscn" # Loading Screen
var starting_world : String = "Not Set" # Template From World (Server Side - Includes Single Player)
var starting_world_name : String = "Not Set" # Spawn World's Name (Server Side - Includes Single Player)

# Server Gets Currently Loaded Worlds
var loaded_worlds : Dictionary = {}

var file_check : File = File.new() # Check to see if world's file path exists

var world_data_dict : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	network.connect("server_created", self, "start_server")
	network.connect("cleanup_worlds", self, "cleanup")
	
	player_registrar.connect("world_set", self, "load_world_client") # The player has to be registered to download the world information.

# Server Starting Function
func start_server() -> void:
	#logger.verbose("Server Loading")
	# Load World From Drive
	# For Simplicity, We Are Starting Off Non Infinite So The Whole World Will Be Loaded At Once
	# QUESTION: Do I want to Use Scenes For World Data Or Just To Populate A Scene From A Save File?
	
	# Enable Physics - Growing Plants, Moving Mobs, etc... (May Be Done In Respective Scenes Instead)
	
	# https://godotengine.org/qa/27962/running-multiple-viewports-and-switching-which-one-active?show=28262#a28262
	# NOTE (IMPORTANT): Apparently, I can use ViewPorts to separate displayed scenes.
	# This is important, because if the server is not running headless,
	# then having multiple worlds loaded can causes problems for the server player.
	
	if not get_tree().get_root().has_node("Worlds"):
		var worlds : Node = Node.new()
		worlds.name = "Worlds"
		get_tree().get_root().add_child(worlds)
	
	# TODO: If Headless Make Sure Loaded, but Not Displayed
	# The server needs to keep all worlds (chunks surrounding players when infinite) loaded that has players inside. Eventually after game release options to keep specific worlds loaded regardless will be available to server owners that can support it.
	if gamestate.player_info.has("starting_world"):
		starting_world = gamestate.player_info.starting_world
	else:
		#logger.verbose("This should never be reached (once character creation exists). This is because Host Server will not be in network menu anymore.")
		
		# Cleans Up Connection on Error
		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
		emit_signal("missing_starting_world_reference")
		
		return
	
	# Setup loading screen on separate thread here and listen or signals from world loader.
	var loading_screen : Node = preload(loading_screen_name).instance()
	loading_screen.name = "LoadingScreen"
	get_tree().get_root().add_child(loading_screen) # Call Deferred Will Make This Too Late
	
	# Unload Current Scene (Single Player Menu on Main Menu)
	get_tree().get_current_scene().call_deferred("free")
	
	var load_world_server_thread : Thread = Thread.new()
	load_world_server_thread.start(self, "load_world_server_threaded", [-1, starting_world]) # Specify -1 (server only) to let server know the spawn world doesn't have the server player yet (gui only)
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	var world : String = load_world_server_thread.wait_to_finish()
	
	if world == "":
		#logger.verbose("World is Missing (on Server Start)!!! Check Player Save File!!!")
		
		# Cleans Up Connection on Error
		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
		emit_signal("missing_starting_world")
		
		return
	
	# Sets Starting World Name to Pass to Spawn Handler
	starting_world_name = world
	
	# Register Server's Player in Player List
	if not gamestate.server_mode:
		player_registrar.register_player(gamestate.player_info, 0)
		emit_signal("server_started", gamestate.player_info) # Sends Server Player's Info To Spawn Code
		
	network.start_encryption_server() # Start Encryption For Server
	network.start_server_finder_helper() # Start Lan Server Finder Helper

# Client World Loading Code (client side only)
puppet func load_world_client() -> void:
	# Download World, Resources, Scripts, etc... From Server
	# Should I Use HTTP or Should I Send Data by RPC?
	# If RPC, I may have to have client initiate download and then call signal to load worlds in a different function from here (below this function). I may not need to call signal, just load function.
	
	# Verify Hashes of Downloaded Data
	
	# This will be changed to load from world (chunks?) sent by server
	# The client should only handle one world at a time (given worlds are everchanging, there is no reason to cache it - except if I can streamline performance with cached worlds)
	# If Saved World Exists, Then Load it Instead
	# Creates A World From Scratch
	
	if not get_tree().get_root().has_node("Worlds"):
		var worlds : Node = Node.new()
		worlds.name = "Worlds"
		get_tree().get_root().add_child(worlds)

		if not gamestate.player_info.has("current_world"):
			logger.error("Never Got Current World From Server!!! Not Going to Bother Finishing Connection!!!")
			emit_signal("missing_current_world_reference")
			emit_signal("cleanup_worlds")
			return
		
		#logger.verbose("World (Load Client): %s" % gamestate.player_info.current_world)
		
		# Sets Starting World Name to Pass to Spawn Handler
		var spawn = preload(world_template).instance()
		spawn.name = gamestate.player_info.current_world
		
		worlds.add_child(spawn)
	
	# Unload Network Menu (cannot use get_current_scene() from rpc call)
	if get_tree().get_root().has_node("NetworkMenu"): # Sometimes this node is removed before we get to this line of code (only if the player keeps clicking join when a server is not online)
		get_tree().get_root().get_node("NetworkMenu").queue_free()
	
	# Now that the current world has been set, ask server to spawn player
	spawn_handler.rpc_unreliable_id(1, "spawn_player_server", gamestate.player_info) # Notify Server To Spawn Client
	emit_signal("world_loaded_client")
	
# Load Template to Instance World Into
func load_template(location: String) -> Node:
	# NOTE: I forgot groups existed (could of added all worlds to group). Try to use groups when handling projectiles and mobs.
	if file_check.file_exists(location):
		var world_file : Resource = load(location) # Load World From File Location
		var worlds : Node = get_tree().get_root().get_node("Worlds") # Get Worlds node
		
		var world : Node = world_file.instance() # Instance Loaded World
		
		# If Client, Unload Previous World
		# TODO: Keep Client only worlds loaded when inviting players to client worlds is implemnted.
		# I mau put client worlds in a separate node so they cannot conflict with server world names.
		# Actually, that could help a lot with separate RPC calls (as server will not be allowed to force someone into client's worlds)
		if not get_tree().has_network_peer() or not get_tree().is_network_server():
			for loaded_world in worlds.get_children():
				loaded_world.queue_free()
				
		return world # Return World Name to Help Track Client Location
		
	emit_signal("failed_loading_world")
	return null # World failed to load

func load_world_server_threaded(thread_data: Array) -> String:
	if thread_data.size() != 2:
		return ""
	
	var net_id: int = int(thread_data[0])
	var location: String = thread_data[1]
	
	return load_world_server(net_id, location)

# Load World to Send Player To (server-side only)
func load_world_server(net_id: int, location: String) -> String:
	# Apparently setting a default value either requires the default to be on the end of the arguments list or for all arguments to have a default value.
	# When this is fixed, set net_id to default to -1.
	
	# Named world_meta because this will eventually just list things like seed and name (not tiles)
	# Tiles will be split into files that match the corresponding chunk
	var worlds : Node = get_tree().get_root().get_node("Worlds") # Get Worlds node
	var world_meta = location.plus_file("world.json")
	var world_file : File = File.new()
	
	# If world's metadata does not exist, do not even attempt to load the world
	if not file_check.file_exists(world_meta):
		logger.error("Failed To Find world.json When Loading World!!!")
		return ""
	
	# Checks to Make sure World isn't already loaded
	if loaded_worlds.has(world_meta):
		var world : Node = get_tree().get_root().get_node("Worlds").get_node(loaded_worlds[world_meta]) # World was already loaded (as tracked in loaded_worlds Array)
		var world_grid : Node = spawn_handler.get_world_grid(loaded_worlds[world_meta])
		
		if world_grid == null:
			logger.error("Cannot Load World Grid for World '%s'" % world_meta)
			return ""
			
		if not world_grid.has_node("Players"):
			var players_node : Node = Node.new()
			players_node.name = "Players"
			world_grid.add_child(players_node)
			
		var player : bool = world_grid.get_node("Players").has_node(str(gamestate.net_id)) # If already in same world, keep visible
		
		if (net_id == gamestate.net_id) or (player) or (net_id == -1):
			# Make sure previous world was made invisible
			if net_id != -1:
				worlds.get_node(spawn_handler.get_world(net_id)).visible = false
				
			world.visible = true
		else:
			world.visible = false
			
		return world.name
	
	world_file.open(world_meta, File.READ)
	var json : JSONParseResult = JSON.parse(world_file.get_as_text())
	
	# Checks to Make Sure JSON was Parsed
	if json.error != OK:
		# Failed to Parse JSON
		logger.error("Failed To Parse JSON When Loading World!!!")
		return ""
		
	if typeof(json.result) == TYPE_DICTIONARY:
		var results = json.result
		if not results.has("seed") or not results.has("name"):
			# Check if world save file has seed and name (name is because having a missing name makes saving data occur in the wrong folder)
			# If the world seed is missing, there is no way for the generator to accurately generate the world
			# So don't even bother loading the world.
			logger.error("Failed To Find Seed or World Name When Loading World!!!")
			return ""
			
		if not results.has("chunks_foreground") or not results.has("chunks_background"):
			# Chunk data is missing, don't want to accidentally overwrite player world.
			logger.error("Failed To Find Chunks Foreground or Chunks Background When Loading World!!!")
			return ""
		
		var template = load_template(world_template)
		if template == null:
			# If world fails to load, then notify world changer (or commands if server).
			logger.error("Failed To Load Template When Loading World!!!")
			return ""
			
		# Set World's Metadata
		var generator = template.get_node("Viewport/WorldGrid/WorldGen")
		generator.world_seed = results.seed # Set World's Seed
		
		if results.has("spawn"):
			# Retrieve Saved World Spawn
			generator.spawn_set = true # Set World Spawn to True
			generator.spawn_coor = str2var("Vector2" + results.spawn) # Loads Spawn Coordinates From File As Vector2
		else:
			# Generate A World Spawn Based on World's Seed
			generator.spawn_set = true # Set World Spawn to True
			generator.spawn_coor = generator.find_world_spawn()
		
		# Load Generated Chunk Location into Memory (this should be replaced by a chunk loading system later)
		generator.load_chunks_foreground(results["chunks_foreground"])
		generator.load_chunks_background(results["chunks_background"])
		
		template.name = results.name # Set World's Name
		worlds.add_child(template) # Add Loaded World to Worlds node
		
		# Add Loaded World to Dictionary of Loaded Worlds
		loaded_worlds[world_meta] = template.name
		
		# This will be replaced by a chunk loading system later.
		if results.has("tiles_foreground"):
			generator.load_foreground(results["tiles_foreground"])
			
		# This will be replaced by a chunk loading system later.
		if results.has("tiles_background"):
			generator.load_background(results["tiles_background"])
		
		if get_tree().is_network_server():
			# Makes sure the viewport (world) is only visible (to the server player) if the server player is changing worlds
			if (net_id == gamestate.net_id) or (net_id == -1):
				# Make sure previous world was made invisible
				if net_id != -1:
					worlds.get_node(spawn_handler.get_world(net_id)).visible = false
					
				template.visible = true
			else:
				template.visible = false
		
		emit_signal("world_loaded_server")
		return template.name
	else:
		# Unknown JSON Format
		logger.error("Failed To Parse JSON (Unknown Format) When Loading World!!!")
		return ""

func save_world(world: Node):
	world_data_dict.clear() # Clears Dictionary From Previous Uses
	
	var world_generator = world.get_node("Viewport/WorldGrid/WorldGen")
	var world_generator_background = world_generator.get_node("Background")
	
	var world_folder_path = "user://worlds/%s" % world.name
	var save_path = world_folder_path.plus_file("world.json")
	var save_path_backup = save_path + ".backup"
	
	var file_op : Directory = Directory.new() # Allows Performing Operations on Files (like moving or deleting a file)
	var world_data : File = File.new()
	
	# Make World Folder Directory (if it does not exist)
	if not file_op.dir_exists(world_folder_path):
		file_op.make_dir_recursive(world_folder_path)
		
	# We are overwriting the world save regardless of what was previously in it. First we want to backup world incase of power failure.
	
	# Remove previous backup (if any)
	if file_op.file_exists(save_path_backup):
		file_op.remove(save_path_backup)
	
	# Move old save to backup (if any) - Faster than copy (unless backup somehow ends up on another partition/drive)
	if file_op.file_exists(save_path):
		file_op.rename(save_path, save_path_backup)
	
	# Open World Data File to Save to
	world_data.open(save_path, File.WRITE) # Open Save File For Reading/Writing
	
	# Store Seed
	world_data_dict["seed"] = str(world_generator.world_seed)
	world_data_dict["name"] = str(world.name)
	
	# Store World Spawn (if set)
	if world_generator.spawn_set:
		world_data_dict["spawn"] = str(world_generator.spawn_coor)
	
	if not is_instance_valid(world_generator):
		logger.fatal("World Generator is Not Inside Tree!!!")
		return null
	
	# Store Used Cells (Everything but Air - Air uses the same tile id as a non-existant tile, so there is no reason to save it. Tile chunks will be recorded in a separate array.)
	world_data_dict["tiles_foreground"] = get_tiles(world_generator)
	world_data_dict["tiles_background"] = get_tiles(world_generator_background)
	
	# This is saved incase the player manually cleans out a chunk (if I tried to guess which chunk was previously generated and it was completely emptied out, the guess would consider it to not be generated).
	world_data_dict["chunks_foreground"] = world_generator.generated_chunks_foreground
	world_data_dict["chunks_background"] = world_generator.generated_chunks_background
	
	# Save World to Drive
	world_data.store_string(to_json(world_data_dict))
	
func create_world_server_threaded(thread_data: Array) -> String:
	if thread_data.size() < 1 or thread_data.size() > 3:
		return ""
	
	var net_id: int = int(thread_data[0])
	var world_seed: String = thread_data[1]
	
	if thread_data.size() == 1:
		return create_world(net_id)
	elif thread_data.size() == 2:
		return create_world(net_id, world_seed)
		
	var world_size : Vector2 = thread_data[2]
	return create_world(net_id, world_seed, world_size)
	
func create_world(net_id: int = -1, world_seed: String = "", world_size: Vector2 = Vector2(0, 0)):
	# Creates A World From Scratch
	var worlds : Node # Worlds Node
	var world_name : String = uuid.v4()
	var location = "user://worlds/".plus_file(world_name)
	var world_meta = location.plus_file("world.json")
	# warning-ignore:unused_variable
	var world_file : File = File.new()
	
	if get_tree().get_root().has_node("Worlds"):
		worlds = get_tree().get_root().get_node("Worlds") # Get Worlds node
	else:
		# Creates Worlds Node if It Does Not Exist
		worlds = Node.new()
		worlds.name = "Worlds"
		get_tree().get_root().add_child(worlds)
	
	var template = load_template(world_template)
	if template == null:
		# If world fails to load, then notify world changer (or commands if server).
		logger.error("Failed To Load Template When Creating World!!!")
		return ""
		
	# Set World's Metadata
	var generator = template.get_node("Viewport/WorldGrid/WorldGen")
	
	if world_seed != "":
		generator.world_seed = world_seed # Set World's Seed
	
	template.name = world_name # Set World's Name
	worlds.add_child(template) # Add Loaded World to Worlds node
	
	if world_size == Vector2(0, 0):
		# Sets world size to be default size
		generator.generate_new_world() # Called World Generation Code
	else:
		# Sets Custom World Size
		generator.generate_new_world(world_size) # Called World Generation Code
	
	generator.spawn_set = true # Set World Spawn to True
	generator.spawn_coor = generator.find_world_spawn() # Find Spawn Point For World Based on World's Seed
	
	# Add Loaded World to Dictionary of Loaded Worlds
	loaded_worlds[world_meta] = template.name
	
	if get_tree().has_network_peer() and get_tree().is_network_server():
		# Makes sure the viewport (world) is only visible (to the server player) if the server player is changing worlds
		if (net_id == gamestate.net_id) or (net_id == -1):
			if net_id != -1:
				worlds.get_node(spawn_handler.get_world(net_id)).visible = false
			
			template.visible = true
		else:
			template.visible = false
	
	emit_signal("world_created")
	return template.name # Returns World's Name
	
func get_world(worldname: String) -> Node:
	var worlds : Node
	
	if not get_tree().get_root().has_node("Worlds"):
		return null
	
	worlds = get_tree().get_root().get_node("Worlds") # Get Worlds node
	
	if worlds.has_node(worldname):
		return worlds.get_node(worldname)
	
	return null
	
# Get Tiles From TileMap
func get_tiles(tilemap: TileMap) -> Dictionary:
	# Fixes A Rare Crash With Loading Missing World First Then Trying To Load Valid World
	# I am not sure why this fixes it, I was going to have this go back to main menu on failure, but it loads properly now.
	if tilemap.get_used_cells().size() == 0:
		return {}
	
	var cells = tilemap.get_used_cells()
	
	if cells.size() == 0 or cells == null:
		return {}
	
	var tiles = {}
	
	for cell in cells:
		#logger.verbose("Cell: %s" % cell)
		tiles[str(cell)] = tilemap.get_cellv(cell)
		
	return tiles
	
# Cleanup World Handler
func cleanup() -> void:
	loaded_worlds.clear()

func get_class() -> String:
	return "WorldHandler"
