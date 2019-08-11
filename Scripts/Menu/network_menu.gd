extends Control

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	set_theme(gamestate.game_theme)	
	set_game_data()

func set_theme(theme: Theme) -> void:
	"""
		Set's Network Menu Theme
		
		Supply Theme Resource
	"""
	
	# Different Panels In Network Menu - Will Be Changed After Character Creation is Implemented
	$panelHost.set_theme(theme)
	$panelJoin.set_theme(theme)
	$panelPlayer.set_theme(theme)

func _on_btColor_color_changed(color: Color) -> void:
	"""
		(Deprecated) - Change Player's Color Live
		
		Not Meant To Be Called Directly
	"""
	
	$panelPlayer/playerIcon.modulate = $panelPlayer/btColor.color

func set_player_info() -> void:
	"""
		(Deprecated) - Set's Players Info
		
		Will Be Relocated to Player Creation Screen
		
		Not Meant To Be Called Directly
	"""
	
	# Set Player's Name
	if (!$panelPlayer/txtPlayerName.text.empty()):
		gamestate.player_info.name = $panelPlayer/txtPlayerName.text
	
	# Set Character's Color
	gamestate.player_info.char_color = $panelPlayer/btColor.color.to_html(true)

func _on_btnCreate_pressed() -> void:
	"""
		(Deprecated) - Host Server
		
		Single Player is a Server. However, It Won't Accept Connections Until Enabled By Player
		
		There Will Be No Option to Host Server From Network Menu Once Player Creation and Loading is Created
		
		Not Meant To Be Called Directly
	"""
	
	# Gather values from the GUI and fill the network.server_info dictionary
	
	# Record Player's Info - GUI Only
	set_player_info()
	
	# Also, this is the perfect place to validate the data for the dictionary in network.gd
	if (!$panelHost/txtServerName.text.empty()):
		network.server_info.name = $panelHost/txtServerName.text
	
	# TODO: Make sure fields aren't empty before populating data
	network.server_info.max_players = int($panelHost/txtMaxPlayers.text)
	network.server_info.used_port = int($panelHost/txtServerPort.text)
	
	# Create the Server (Through network.gd)
	network.create_server()

func _create_server_headless() -> void:
	"""
		(Deprecated) - Host Server Without GUI (Not Implemented)
		
		Meant to Be Used By Command Line Arguments. Currently Broken.
		Will Be Moved to Network Script Later.
		
		Not Meant To Be Called Directly
	"""
	
	network.server_info.name = "Server Name - Headless"
	
	network.server_info.max_players = int("5") # Maximum Number of Players
	network.server_info.used_port = int("4242") # Server Port
	
	# Create the Server (Through network.gd)
	network.create_server()

func _on_btnJoin_pressed() -> void:
	"""
		Join's Server
		
		Will Call Player Selection Screen Before Attempting To Join Server
		
		Not Meant To Be Called Directly
	"""
	
	# Record Player's Info - GUI Only
	set_player_info()
	
	# TODO: Make Sure To Validate Data From User
	var port : int = int($panelJoin/txtJoinPort.text)
	var ip : String = $panelJoin/txtJoinIP.text
	network.join_server(ip, port)

func set_game_data() -> void:
	"""
		(Deprecated) - Loads Player's Data
		
		Will Be Moved to Character Selection Screen
		
		Not Meant To Be Called Directly
	"""
	
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

func _on_btColor_popup_closed() -> void:
	"""
		(Deprecated) - Saves Player's Data
		
		Will Be Moved to Character Creation Screen
		
		Not Meant To Be Called Directly
	"""
	
	set_player_info()
	
	#print("Character Color: " + str(gamestate.player_info.char_color))
	
	gamestate.save_player(0)
