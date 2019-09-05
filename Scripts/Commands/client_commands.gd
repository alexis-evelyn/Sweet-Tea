extends Node
class_name ClientCommands

func process_commands(message: PoolStringArray) -> String:
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)

	match command:
		"calc":
			return open_calculator(message)
		"server_ip":
			return server_ip(message)
		"cam":
			return teleport_camera(message)
		_:
			return ""
			
# warning-ignore:unused_argument
func open_calculator(message: PoolStringArray) -> String:
	if not get_tree().get_root().has_node("Calculator"):
		var calc : Node = preload("res://Menus/Jokes/Calculator.tscn").instance()
		calc.name = "Calculator"
		
		get_tree().get_root().add_child(calc)
	
	return tr("open_calculator")

# warning-ignore:unused_argument
func server_ip(message) -> String:
	var net : NetworkedMultiplayerENet = get_tree().get_network_peer()
	
	if gamestate.net_id == 1:
		return tr("server_ip_command_self")
	
	return tr("server_ip_command") % net.get_peer_address(1)

func teleport_camera(message) -> String:
	"""
		Teleport Camera To Coordinates Command
		
		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)
	
	var coordinates : Vector2
	if command_arguments.size() == 2:
		var x_coor : int = convert(command_arguments[0], TYPE_INT)
		var y_coor : int = convert(command_arguments[1], TYPE_INT)
		
		coordinates = Vector2(x_coor, y_coor)
	elif command_arguments.size() == 1:
		# Teleport Camera to Player (Not Implemented)
		var player_id : int = convert(command_arguments[0], TYPE_INT)
		
		if player_registrar.players.has(player_id):
			pass
		else:
			pass
			
		return tr("tp_camera_command_not_enough_arguments")
	elif command_arguments.size() == 3:
		# Teleport Camera Player to Other Location (if alphabetical characters are first)
		# Disable Safety Check (if alphabetical characters are third)
		
		# Not Implemented
		
		return tr("tp_camera_command_too_many_arguments")
	elif command_arguments.size() == 0:
		return tr("tp_camera_command_not_enough_arguments")
	else:
		return tr("tp_camera_command_too_many_arguments")
	
	#var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	var world_name : String = spawn_handler.get_world_name(gamestate.net_id) # Pick world player is currently in
	
	if not spawn_handler.get_world_node(world_name).has_node("Viewport/DebugCamera"):
		return tr("tp_camera_command_missing_debug_camera")
		
	var camera : Node = spawn_handler.get_world_node(world_name).get_node("Viewport/DebugCamera")
	
	camera.update_camera_pos(coordinates)
	camera.update_camera_pos_label()
		
	return tr("tp_camera_command_success") % [coordinates.x, coordinates.y]


func get_class() -> String:
	return "ClientCommands"
