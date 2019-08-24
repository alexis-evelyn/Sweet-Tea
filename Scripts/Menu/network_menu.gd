extends Control

var lan_client : String = "res://Scripts/lan/client.gd"

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	functions.set_title("Connect To A Server")
	
	set_theme(gamestate.game_theme)
	find_servers()
	
func find_servers() -> void:
	# Setup Broadcast Listener Script
	var server_finder = Node.new()
	server_finder.set_script(load(lan_client)) # Attach A Script to Node
	server_finder.set_name("ServerFinder") # Give Node A Unique ID
	add_child(server_finder)

func set_theme(theme: Theme) -> void:
	"""
		Set's Network Menu Theme
		
		Supply Theme Resource
	"""
	
	.set_theme(theme) # Godot's Version of a super - https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	
	# Different Panels In Network Menu - Will Be Changed After Character Creation is Implemented
	#$panelHost.set_theme(theme)
	$panelJoin.set_theme(theme)
	#$panelPlayer.set_theme(theme)

# warning-ignore:unused_argument
func _on_btColor_color_changed(color: Color) -> void:
	"""
		(Deprecated) - Change Player's Color Live
		
		Not Meant To Be Called Directly
	"""
	
	$panelPlayer/playerIcon.modulate = $panelPlayer/btColor.color

func _on_btnJoin_pressed() -> void:
	"""
		Join's Server
		
		Will Call Player Selection Screen Before Attempting To Join Server
		
		Not Meant To Be Called Directly
	"""
	
	# TODO: Make Sure To Validate Data From User
	var port : int = int($panelJoin/txtJoinPort.text)
	var ip : String = $panelJoin/txtJoinIP.text
	network.join_server(ip, port)
