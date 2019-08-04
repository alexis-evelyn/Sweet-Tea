extends Control

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	set_theme(gamestate.game_theme)	
	set_game_data()

# Sets NetworkMenuTheme
func set_theme(theme: Theme) -> void:
	# Different Panels In Network Menu - Will Be Changed After Character Creation is Implemented
	$panelHost.set_theme(theme)
	$panelJoin.set_theme(theme)
	$panelPlayer.set_theme(theme)

# TODO: As I create an actual player creation screen, I will get rid of this section of the NetworkMenu
# Set's Player Sprite Color in Menu Live
func _on_btColor_color_changed(color: Color) -> void:
	$panelPlayer/playerIcon.modulate = $panelPlayer/btColor.color

# Record Player's Info (Require's GUI)
func set_player_info() -> void:
	# TODO: Validate User Input
	
	# Set Player's Name
	if (!$panelPlayer/txtPlayerName.text.empty()):
		gamestate.player_info.name = $panelPlayer/txtPlayerName.text
	
	# Set Character's Color
	gamestate.player_info.char_color = $panelPlayer/btColor.color.to_html(true)

# Create Server Button (GUI Only - Not Headless)
func _on_btnCreate_pressed() -> void:
	# Gather values from the GUI and fill the network.server_info dictionary
	
	# Record Player's Info - GUI Only
	set_player_info()
	
	# TODO: Make sure fields aren't empty before populating data
	# Also, this is the perfect place to validate the data for the dictionary in network.gd
	if (!$panelHost/txtServerName.text.empty()):
		network.server_info.name = $panelHost/txtServerName.text
	
	network.server_info.max_players = int($panelHost/txtMaxPlayers.text)
	network.server_info.used_port = int($panelHost/txtServerPort.text)
	
	# Create the Server (Through network.gd)
	network.create_server()

# TODO: Move This Function Outside of A Menu (and Put into Command Line Handling Code)
# Headless Only Creation of Server
func _create_server_headless() -> void:
	network.server_info.name = "Server Name - Headless"
	
	network.server_info.max_players = int("5") # Maximum Number of Players
	network.server_info.used_port = int("4242") # Server Port
	
	# Create the Server (Through network.gd)
	network.create_server()

# Join Server Button
func _on_btnJoin_pressed() -> void:
	# Record Player's Info - GUI Only
	set_player_info()
	
	# TODO: Make Sure To Validate Data From User
	var port : int = int($panelJoin/txtJoinPort.text)
	var ip : String = $panelJoin/txtJoinIP.text
	network.join_server(ip, port)

# Load Data - This Exists Just To Test Saving - I Am Not Setting Player Data From The Network Menu In The Real Game
func set_game_data() -> void:
	# Set Character's Name
	var loaded : int = gamestate.load_player(0)
	
	if gamestate.player_info.has("name"):
		$panelPlayer/txtPlayerName.text = gamestate.player_info.name
	else:
		$panelPlayer/txtPlayerName.text = ""
	
	if gamestate.player_info.has("char_color"):
		# Set Character's Color
		$panelPlayer/btColor.color = gamestate.player_info.char_color
		
		_on_btColor_color_changed(gamestate.player_info.char_color)

# Save Data - This Exists Just To Test Saving - I Am Not Setting Player Data From The Network Menu In The Real Game
func _on_btColor_popup_closed() -> void:
	set_player_info()
	
	#print("Character Color: " + str(gamestate.player_info.char_color))
	
	gamestate.save_player(0)