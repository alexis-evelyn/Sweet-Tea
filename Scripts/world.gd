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
		spawn_players(gamestate.player_info) # Spawn Players (Currently Only Server's Player)
	else:
		rpc_id(1, "spawn_players", gamestate.player_info) # Request for Server To Spawn Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass

# Spawns a new player actor, using the provided player_info structure and the given spawn index
# http://kehomsforge.com/tutorials/multi/gdMultiplayerSetup/part03/ - "Spawning A Player"
remote func spawn_players(pinfo):
	# TODO: Get Rid of Spawnpoint System (Use Code From Previous Server)
	pass

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