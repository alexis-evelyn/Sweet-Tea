extends Node

signal server_started(gamestate_player_info) # Server Started Up and World is Loaded - Spawns Server Player

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created", self, "_load_world_server")
	network.connect("join_success", self, "_load_world_client")

# Server World Loading Function
func _load_world_server():
	# Load World From Drive
	# For Simplicity, We Are Starting Off Non Infinite So The Whole World Will Be Loaded At Once
	# QUESTION: Do I want to Use Scenes For World Data Or Just To Populate A Scene From A Save File?
	
	# Enable Physics - Growing Plants, Moving Mobs, etc... (May Be Done In Respective Scenes Instead)
	
	# TODO: If Headless Make Sure Loaded, but Not Displayed
	get_tree().change_scene("res://Worlds/World.tscn")
	emit_signal("server_started", gamestate.player_info) # Sends Server Player's Info To Spawn Code

# Client World Loading Code
func _load_world_client():
	# Download World, Resources, Scripts, etc... From Server
	
	# Verify Hashes of Downloaded Data
	
	# This will be changed to load from world (chunks?) sent by server
	get_tree().change_scene("res://Worlds/World.tscn")