extends Node
class_name ClientCommands

# Used by Shaders Command - May Move to Separate File
var shaders : Dictionary = {
	"animated_blur": {
		"path": "res://Scripts/Shaders/animated_blur.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"background": {
		"path": "res://Scripts/Shaders/background.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"earthquake": {
		"path": "res://Scripts/Shaders/earthquake.shader",
		"animated": true,
		"description": "",
		"seizure_warning": true # TODO: Find our what to look for to accurately predict potential seizure causing shaders
	},
	"fabric_of_time": {
		"path": "res://Scripts/Shaders/fabric_of_time.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"grayscale": {
		"path": "res://Scripts/Shaders/grayscale.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"peeling_back_reality": {
		"path": "res://Scripts/Shaders/peeling_back_reality.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"bcs": {
		"path": "res://Scripts/Shaders/third_party/bcs.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"blur": {
		"path": "res://Scripts/Shaders/third_party/blur.shader",
		"animated": false,
		"default_params": {
			"amount": 2.0 # (0-5) Not Tested
		},
		"description": "",
		"seizure_warning": false
	},
	"contrasted": {
		"path": "res://Scripts/Shaders/third_party/contrasted.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"fisheye": {
		"path": "res://Scripts/Shaders/third_party/fisheye.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"mirage": {
		"path": "res://Scripts/Shaders/third_party/mirage.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"negative": {
		"path": "res://Scripts/Shaders/third_party/negative.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"normalized": {
		"path": "res://Scripts/Shaders/third_party/normalized.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"pixelize": {
		"path": "res://Scripts/Shaders/third_party/pixelize.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"sepia": {
		"path": "res://Scripts/Shaders/third_party/sepia.shader",
		"animated": false,
		"default_params": {
			"base": Color("#8b6867").to_rgba32() # Not Tested
		},
		"description": "",
		"seizure_warning": false
	},
	"whirl": {
		"path": "res://Scripts/Shaders/third_party/whirl.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	}
}

func process_commands(message: PoolStringArray) -> String:
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)

	match command:
		"calc":
			return open_calculator(message)
		"server_ip":
			return server_ip(message)
		"cam":
			return teleport_camera(message)
		"shader":
			return set_shader(message)
		"shaderparam":
			return set_shader_param(message)
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
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	var coordinates : Vector2
	if command_arguments.size() == 2:
		# TODO: If - (minus) is specified as coordinate, use current coordinate in place instead of 0.
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

func set_shader(message) -> String:
	# /shader <shader_name> [world or game]
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	var shader_name : String

	if command_arguments.size() == 1:
		# Assume world if world or game not specified
		shader_name = command_arguments[0]

		if not shaders.has(shader_name):
			return "No Match"

		if not shaders.get(shader_name).has("path"):
			return "Corrupted Dictionary - Missing Path"

		functions.set_world_shader(load(shaders.get(shader_name).path))
		return "Set Shader!!!"

	return "Hmmmm..."

func set_shader_param(message) -> String:
	# /shaderparam <key> <value> [world or game]

	return ""

func get_class() -> String:
	return "ClientCommands"
