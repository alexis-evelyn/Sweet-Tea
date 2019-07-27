extends Node

signal server_started(gamestate_player_info) # Server Started Up and World is Loaded - Spawns Server Player

# Chunk Loading (like in Minecraft) is perfectly possible with Godot - https://www.reddit.com/r/godot/comments/8shad4/how_do_large_open_worlds_work_in_godot/
# I ultimately plan on having multiple worlds which the players can join on the server. As for singleplayer, it is going to be a server that refuses connections unless the player opens it up to other players.
# I also want to have a "home" that players spawn at before they join the starting_world (like how Starbound has a spaceship. but I want my home to be an actual world that will be the player's home world. The player can then use portals to join the server world.
var starting_world = load("res://Worlds/World.tscn") # Basically Server Spawn
var starting_world_name = "Not Set"

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created", self, "_load_world_server")
	network.connect("connection_success", self, "_load_world_client")

# Server World Loading Function
func _load_world_server():
	print("Server Loading World")
	# Load World From Drive
	# For Simplicity, We Are Starting Off Non Infinite So The Whole World Will Be Loaded At Once
	# QUESTION: Do I want to Use Scenes For World Data Or Just To Populate A Scene From A Save File?
	
	# Enable Physics - Growing Plants, Moving Mobs, etc... (May Be Done In Respective Scenes Instead)
	
	# TODO: If Headless Make Sure Loaded, but Not Displayed
	# The server needs to keep all worlds (chunks surrounding players when infinite) loaded that has players inside. Eventually after game release options to keep specific worlds loaded regardless will be available to server owners that can support it.
	var worlds = Node.new()
	worlds.name = "Worlds"
	
	var spawn = starting_world.instance()
	starting_world_name = spawn.name # TODO: Make sure to add a way to send world name to client
	worlds.add_child(spawn)
	get_tree().get_root().add_child(worlds)
	
	get_tree().get_current_scene().queue_free()
	
	if(OS.has_feature("Server") == false):
		emit_signal("server_started", gamestate.player_info) # Sends Server Player's Info To Spawn Code

# Client World Loading Code
func _load_world_client():
	# Download World, Resources, Scripts, etc... From Server
	# Should I Use HTTP or Should I Send Data by RPC?
	# If RPC, I may have to have client initiate download and then call signal to load worlds in a different function from here (below this function). I may not need to call signal, just load function.
	
	# Verify Hashes of Downloaded Data
	
	# This will be changed to load from world (chunks?) sent by server
	# The client should only handle one world at a time (given worlds are everchanging, there is no reason to cache it - except if I can streamline performance with cached worlds)
	var worlds = Node.new()
	worlds.name = "Worlds"
	
	var spawn = starting_world.instance()
	worlds.add_child(spawn)
	get_tree().get_root().add_child(worlds)
	
	get_tree().get_current_scene().queue_free()