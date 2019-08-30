extends Node

func process_commands(message: PoolStringArray) -> String:
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)

	match command:
		"calc":
			return open_calculator(message)
		"server_ip":
			return server_ip(message)
		_:
			return ""
			
# warning-ignore:unused_argument
func open_calculator(message: PoolStringArray) -> String:
	if not get_tree().get_root().has_node("Calculator"):
		var calc : Node = load("res://Menus/Jokes/Calculator.tscn").instance()
		calc.name = "Calculator"
		
		get_tree().get_root().add_child(calc)
	
	return tr("open_calculator")

func server_ip(message) -> String:
	var net : NetworkedMultiplayerENet = get_tree().get_network_peer()
	
	if gamestate.net_id == 1:
		return tr("server_ip_command_text_self")
	
	return tr("server_ip_command_text") % net.get_peer_address(1)
