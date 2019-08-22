extends Control

# Main Function - Registers Event Handling (Handled By Both Client And Server)
func _ready() -> void:
	set_theme(gamestate.game_theme)	

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
