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
	$panelNetwork.set_theme(theme)
	#$panelPlayer.set_theme(theme)

func _on_btnJoin_pressed() -> void:
	"""
		Join's Server
		
		Will Call Player Selection Screen Before Attempting To Join Server
		
		Not Meant To Be Called Directly
	"""
	
	# TODO: Make Sure To Validate Data From User
	var address : String = $panelNetwork/manualJoin/txtServerAddress.text
	var ip : String = address.split(":", false, 1)[0]
	var port : int = int(address.split(":", false, 1)[1])
	
	network.join_server(ip, port)
