extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	network.connect("player_list_changed", self, "_on_player_list_changed") # Register Event for If Player List Changed

	print("Player List")

	# Do Not Run Below Code if Headless
	var localPlayer = $lblLocalPlayer
	localPlayer.text = gamestate.player_info.name # Display Local Client's Text on Screen
	localPlayer.align = Label.ALIGN_CENTER # Aligns the Text To Center
	localPlayer.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Update Player List in GUI
func _on_player_list_changed():
	# Remove Nodes From Boxlist
	for node in $boxList.get_children():
		node.queue_free()
	
	# Populate Boxlist With Player Names
	for player in network.players:
		if (player != gamestate.net_id):
			var connectedPlayerLabel = Label.new()
			connectedPlayerLabel.align = Label.ALIGN_CENTER # Aligns the Text To Center
			connectedPlayerLabel.text = network.players[int(player)].name
			connectedPlayerLabel.add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
			$boxList.add_child(connectedPlayerLabel)