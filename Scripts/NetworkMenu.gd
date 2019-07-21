extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created", self, "_load_game_server")
	network.connect("join_success", self, "_load_game_client")
	network.connect("join_fail", self, "_on_join_fail")

# Server Starting Code
func _load_game_server():
	# Load World From Drive
	# For Simplicity, We Are Starting Off Non Infinite So The Whole World Will Be Loaded At Once
	# QUESTION: Do I want to Use Scenes For World Data Or Just To Populate A Scene From A Save File?
	
	# Enable Physics - Growing Plants, Moving Mobs, etc... (May Be Done In Respective Scenes Instead)
	
	# TODO: If Headless Make Sure Loaded, but Not Displayed
	get_tree().change_scene("res://Worlds/World.tscn")

# Client Starting Code
func _load_game_client():
	# Download World, Resources, Scripts, etc... From Server
	
	# Verify Hashes of Downloaded Data
	
	# This will be changed to load from world (chunks?) sent by server
	get_tree().change_scene("res://Worlds/World.tscn")

# TODO: Show GUI Error Message on Failed Join of Server
func _on_join_fail():
	print("Failed to join server")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Create Server Button (GUI Only - Not Headless)
func _on_btnCreate_pressed():
	# Gather values from the GUI and fill the network.server_info dictionary
	
	# TODO: Make sure fields aren't empty before populating data
	# Also, this is the perfect place to validate the data for the dictionary in network.gd
	if (!$panelHost/txtServerName.text.empty()):
		network.server_info.name = $panelHost/txtServerName.text
	
	network.server_info.max_players = int($panelHost/txtMaxPlayers.text)
	network.server_info.used_port = int($panelHost/txtServerPort.text)
	
	# Create the Server (Through network.gd)
	network.create_server()

# TODO: Move This Function Outside of A Menu (and Put into Command Line Handling Code)
# Headless Only
func _create_server():
	network.server_info.name = "Server Name - Headless"
	
	network.server_info.max_players = int("5") # Maximum Number of Players
	network.server_info.used_port = int("4242") # Server Port
	
	# Create the Server (Through network.gd)
	network.create_server()

# Join Server Button
func _on_btnJoin_pressed():
	var port = int($panelJoin/txtJoinPort.text)
	var ip = $panelJoin/txtJoinIP.text
	network.join_server(ip, port)
