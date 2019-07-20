extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("server_created", self, "_load_game_server")
	network.connect("join_success", self, "_load_game_client")
	network.connect("join_fail", self, "_on_join_fail")

func _load_game_server():
	get_tree().change_scene("res://Worlds/World.tscn")

func _load_game_client():
	get_tree().change_scene("res://Worlds/World.tscn")

func _on_join_fail():
	print("Failed to join server")
	pass # I am leaving pass here to notify me that this function needs more work

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Create Server Button
func _on_btnCreate_pressed():
	# Gather values from the GUI and fill the network.server_info dictionary
	
	# TODO: Make sure fields aren't empty before populating data
	# Also, this is the perfect place to validate the data for the dictionary in network.gd
	if (!$panelHost/txtServerName.text.empty()):
		network.server_info.name = $panelHost/txtServerName.text
	
	network.server_info.max_players = int($panelHost/txtMaxPlayers.text)
	network.server_info.used_port = int($panelHost/txtServerPort.text)
	
	# And create the server, using the function previously added into the code
	network.create_server()

# Join Server Button
func _on_btnJoin_pressed():
	var port = int($panelJoin/txtJoinPort.text)
	var ip = $panelJoin/txtJoinIP.text
	network.join_server(ip, port)
