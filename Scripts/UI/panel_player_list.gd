extends Panel
class_name PlayerList

var world: Node
var localPlayer: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_handler.connect("player_list_changed", self, "_on_player_list_changed") # Register When Player List Has Been Changed
	get_tree().get_root().get_node("Player_UI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

# Load Player List - Called When Player Joins Server
func loadPlayerList() -> void:
	#logger.verbose("Player List")

	# Do Not Run Below Code if Headless
	localPlayer = $lblLocalPlayer
	localPlayer.text = gamestate.player_info.name # Display Local Client's Text on Screen
	localPlayer.align = Label.ALIGN_CENTER # Aligns the Text To Center
	#localPlayer.add_font_override("font", load("res://Assets/Fonts/dynamicfont/firacode-regular.tres"))

# Update Player List in GUI
func _on_player_list_changed() -> void:
	# TODO: Replace the player list with a rich text label to implement clicking on player names (and add player icons (profile pics?))

	#logger.verbose("Player List Changed!!!")

	# Remove Nodes From Boxlist
	for node in $boxList.get_children():
		node.queue_free()

	world = get_players_node(get_world_name(gamestate.net_id))

	#logger.verbose("World: %s" % get_world_name(gamestate.net_id))

	if world != null:
		# Populate Boxlist With Player Names
		for player in world.get_children(): # for player in player_registrar.players: - Old code, used to get every player on server
			#logger.verbose("Player: %s" % player.name)
			if (int(player.name) != gamestate.net_id):
				var connectedPlayerLabel : Label = Label.new()
				connectedPlayerLabel.align = Label.ALIGN_CENTER # Aligns the Text To Center

				if player_registrar.players[int(player.name)].has("display_name"):
					connectedPlayerLabel.text = player_registrar.players[int(player.name)].display_name # Try to Use Display Name
				elif player_registrar.players[int(player.name)].has("name"):
					connectedPlayerLabel.text = player_registrar.players[int(player.name)].name # If not, Use Name
				else:
					connectedPlayerLabel.text = player.name # Else Use Net ID


				# Font does not need to be loaded every single time (only once)
				#connectedPlayerLabel.add_font_override("font", load("res://Assets/Fonts/dynamicfont/firacode-regular.tres"))
				$boxList.add_child(connectedPlayerLabel)

func get_players_node(world_name: String) -> Node:
	if get_tree().get_root().has_node("Worlds/" + world_name + "/Viewport/WorldGrid/Players/"):
		return get_tree().get_root().get_node("Worlds/" + world_name + "/Viewport/WorldGrid/Players/")
	else:
		return null

func get_world_name(net_id: int) -> String:
	if player_registrar.players[int(net_id)].has("current_world"):
		return str(player_registrar.players[int(net_id)].current_world)
	return functions.empty_string

func show_player_list() -> void:
	self.visible = true
	self.show()

func hide_player_list() -> void:
	self.visible = false
	self.hide()

# Cleanup PlayerList - Meant to be Called by PlayerUI
func cleanup() -> void:
	# Remove Nodes From Boxlist
	for node in $boxList.get_children():
		node.queue_free()

func get_class() -> String:
	return "PlayerList"
