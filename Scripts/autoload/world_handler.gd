extends Node

signal server_started(gamestate_player_info) # Server Started Up and World is Loaded - Spawns Server Player
signal cleanup_worlds

# Chunk Loading (like in Minecraft) is perfectly possible with Godot - https://www.reddit.com/r/godot/comments/8shad4/how_do_large_open_worlds_work_in_godot/
# I ultimately plan on having multiple worlds which the players can join on the server. As for singleplayer, it is going to be a server that refuses connections unless the player opens it up to other players.
# I also want to have a "home" that players spawn at before they join the starting_world (like how Starbound has a spaceship. but I want my home to be an actual world that will be the player's home world. The player can then use portals to join the server world.
var starting_world : String = "Not Set" # Basically Server Spawn
var starting_world_name : String = "Not Set" # Spawn World's Name

# Server Gets Currently Loaded Worlds
var loaded_worlds : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	network.connect("server_created", self, "_load_world_server")
	network.connect("connection_success", self, "_load_world_client")
	network.connect("cleanup_worlds", self, "cleanup")

# Server World Loading Function
func _load_world_server() -> void:
	#print("Server Loading World")
	# Load World From Drive
	# For Simplicity, We Are Starting Off Non Infinite So The Whole World Will Be Loaded At Once
	# QUESTION: Do I want to Use Scenes For World Data Or Just To Populate A Scene From A Save File?
	
	# Enable Physics - Growing Plants, Moving Mobs, etc... (May Be Done In Respective Scenes Instead)
	
	# https://godotengine.org/qa/27962/running-multiple-viewports-and-switching-which-one-active?show=28262#a28262
	# NOTE (IMPORTANT): Apparently, I can use ViewPorts to separate displayed scenes.
	# This is important, because if the server is not running headless,
	# then having multiple worlds loaded can causes problems for the server player.
	
	# TODO: If Headless Make Sure Loaded, but Not Displayed
	# The server needs to keep all worlds (chunks surrounding players when infinite) loaded that has players inside. Eventually after game release options to keep specific worlds loaded regardless will be available to server owners that can support it.
	var worlds : Node = Node.new()
	worlds.name = "Worlds"
	
	if gamestate.player_info.has("starting_world"):
		starting_world = gamestate.player_info.starting_world
	else:
		print("This should never be reached (once character creation exists). This is because Host Server will not be in network menu anymore.")
		
		# Cleans Up Connection on Error
		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
		
		return
	
	var spawn_resource : Resource = load(starting_world)
	
	if spawn_resource == null:
		print("World is Missing!!!")
		
		# Cleans Up Connection on Error
		player_registrar.cleanup()
		gamestate.net_id = 1 # Reset Network ID To 1 (default value)
		get_tree().set_network_peer(null) # Disable Network Peer
		
		return
		
	var spawn : Node = spawn_resource.instance()
	
	# Add Spawn World to Loaded World's Dictionary
	starting_world_name = spawn.name
	loaded_worlds[starting_world] = starting_world_name
	
	# Transparent Window Background (if I wanted to use it for some reason) -  https://github.com/godotengine/godot/pull/14622#issue-158077062
	# Still has to be allowed in project settings first
	#spawn.get_node("Viewport").set_transparent_background(true)
	#OS.window_per_pixel_transparency_enabled = true
	#get_tree().get_root().set_transparent_background(true)
	
	worlds.add_child(spawn)
	get_tree().get_root().add_child(worlds)
	
	# Unload Current Scene (either Network Menu or Single Player Menu)
	get_tree().get_current_scene().queue_free()
	
	# Register Server's Player in Player List
	if not gamestate.server_mode:
		player_registrar.register_player(gamestate.player_info, 0)
		emit_signal("server_started", gamestate.player_info) # Sends Server Player's Info To Spawn Code

# Client World Loading Code
func _load_world_client() -> void:
	# Download World, Resources, Scripts, etc... From Server
	# Should I Use HTTP or Should I Send Data by RPC?
	# If RPC, I may have to have client initiate download and then call signal to load worlds in a different function from here (below this function). I may not need to call signal, just load function.
	
	# Verify Hashes of Downloaded Data
	
	# This will be changed to load from world (chunks?) sent by server
	# The client should only handle one world at a time (given worlds are everchanging, there is no reason to cache it - except if I can streamline performance with cached worlds)
	var worlds : Node = Node.new()
	worlds.name = "Worlds"
	
	var spawn : Node = load(starting_world).instance()
	worlds.add_child(spawn)
	get_tree().get_root().add_child(worlds)
	
	get_tree().get_current_scene().queue_free()
	
# Load World to Send Player To
func load_world(net_id: int, location: String) -> String:
	#print("Change World Loading")
	
	# Checks to Make sure World isn't already loaded
	if loaded_worlds.has(location):
		var world : Node = get_tree().get_root().get_node("Worlds").get_node(loaded_worlds[location])
		var player : bool = world.get_node("Viewport/WorldGrid/Players").has_node(str(gamestate.net_id))
		
		if (net_id == gamestate.net_id) or (player):
			world.visible = true
		else:
			world.visible = false
			
		return world.name
	
	# NOTE: I forgot groups existed (could of added all worlds to group). Try to use groups when handling projectiles and mobs.
	var world_file : Resource = load(location) # Load World From File Location
	var worlds : Node = get_tree().get_root().get_node("Worlds") # Get Worlds node
	
	var world : Node = world_file.instance() # Instance Loaded World
	
	# If Client, Unload Previous World
	if not get_tree().is_network_server():
		for loaded_world in worlds.get_children():
			loaded_world.queue_free()
	else:
		# Makes sure the viewport (world) is only visible (to the server player) if the server player is changing worlds
		if net_id == gamestate.net_id:
			world.visible = true
		else:
			world.visible = false
	
	worlds.add_child(world) # Add Loaded World to Worlds node
	
	# Add Loaded World to Dictionary of Loaded Worlds
	loaded_worlds[location] = world.name
	
	return world.name # Return World Name to Help Track Client Location
	
func save_world(world: Node):
	var save_path = "user://".plus_file(world.name + ".tscn")
	#var save_path = "user://worlds/".plus_file(world.name).plus_file("/world.tscn")
	
	var scene = PackedScene.new()
	var result = scene.pack(world)
	
	if result == OK:
		print("Saving: ", save_path)
		
		#var saved = ResourceSaver.save(save_path), scene)
		var saved = ResourceSaver.save(save_path, scene)
		
		if saved == OK:
			print("Hooray!!!")
		else:
			print("Something Went Wrong!!!")
	
# Cleanup World Handler
func cleanup() -> void:
	loaded_worlds.clear()
