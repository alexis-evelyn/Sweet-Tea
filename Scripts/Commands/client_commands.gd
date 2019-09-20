extends Node
class_name ClientCommands

var shaders_class = preload("res://Scripts/functions/shader_registry.gd").new()
var shaders : Dictionary = shaders_class.shaders

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
		"debugdraw":
			return set_debug_draw(message)
		"screenshot":
			return take_screenshot(message)
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

	#var command_permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level

	var world_name : String = spawn_handler.get_world_name(gamestate.net_id) # Pick world player is currently in

	if not spawn_handler.get_world_node(world_name).has_node("Viewport/DebugCamera"):
		return tr("tp_camera_command_missing_debug_camera")

	var camera : Node = spawn_handler.get_world_node(world_name).get_node("Viewport/DebugCamera")

	camera.update_camera_pos(coordinates)
	camera.update_camera_pos_label()

	return tr("tp_camera_command_success") % [coordinates.x, coordinates.y]

func set_shader(message) -> String:
	# /shader <shader_name> [world or game]
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	var shader_name : String
	var shader_readable_name : String

	if command_arguments.size() == 1:
		# Assume world if world or game not specified
		shader_name = command_arguments[0].to_lower()

		if shader_name.to_lower() == tr("shader_remove_argument"):
			# Remove Both Shaders
			functions.remove_global_shader()
			functions.remove_world_shader()
			return tr("removed_both_shaders")

		if not shaders.has(shader_name):
			return tr("shader_not_found") % shader_name

		if not shaders.get(shader_name).has("path"):
			return tr("shader_registry_corrupted_path") % shader_name

		if not shaders.get(shader_name).has("name"):
			shader_readable_name = shader_name
		else:
			shader_readable_name = shaders.get(shader_name).get("name")

		functions.set_world_shader(load(shaders.get(shader_name).path))
		load_default_params(shader_name, tr("shader_world_argument"))
		return tr("shader_command_success") % [shader_readable_name, tr("shader_world_argument")]

	elif command_arguments.size() == 2:
		shader_name = command_arguments[0].to_lower()
		var shader_rect : String = command_arguments[1]

		if shader_rect.to_lower() == tr("shader_world_argument").to_lower():
			if shader_name.to_lower() == tr("shader_remove_argument"):
				# Remove World Shader
				functions.remove_world_shader()
				return tr("removed_world_shader")

			if not shaders.has(shader_name):
				return tr("shader_not_found") % shader_name

			if not shaders.get(shader_name).has("path"):
				return tr("shader_registry_corrupted_path") % shader_name

			if not shaders.get(shader_name).has("name"):
				shader_readable_name = shader_name
			else:
				shader_readable_name = shaders.get(shader_name).get("name")

			functions.set_world_shader(load(shaders.get(shader_name).path))
			load_default_params(shader_name, tr("shader_world_argument"))
			return tr("shader_command_success") % [shader_readable_name, tr("shader_world_argument")]
		elif shader_rect.to_lower() == tr("shader_game_argument").to_lower():
			if shader_name.to_lower() == tr("shader_remove_argument"):
				# Remove Global Shader
				functions.remove_global_shader()
				return tr("removed_game_shader")

			if not shaders.has(shader_name):
				return tr("shader_not_found") % shader_name

			if not shaders.get(shader_name).has("path"):
				return tr("shader_registry_corrupted_path") % shader_name

			if not shaders.get(shader_name).has("name"):
				shader_readable_name = shader_name
			else:
				shader_readable_name = shaders.get(shader_name).get("name")

			functions.set_global_shader(load(shaders.get(shader_name).path))
			load_default_params(shader_name, tr("shader_game_argument"))
			return tr("shader_command_success") % [shader_readable_name, tr("shader_game_argument")]
		elif shader_rect.to_lower() == tr("shader_all_argument").to_lower():
			if shader_name.to_lower() == tr("shader_remove_argument"):
				# Remove Both Shaders
				functions.remove_global_shader()
				functions.remove_world_shader()
				return tr("removed_both_shaders")

			if not shaders.has(shader_name):
				return tr("shader_not_found") % shader_name

			if not shaders.get(shader_name).has("path"):
				return tr("shader_registry_corrupted_path") % shader_name

			if not shaders.get(shader_name).has("name"):
				shader_readable_name = shader_name
			else:
				shader_readable_name = shaders.get(shader_name).get("name")

			functions.set_world_shader(load(shaders.get(shader_name).path))
			functions.set_global_shader(load(shaders.get(shader_name).path))
			load_default_params(shader_name, tr("shader_world_argument"))
			load_default_params(shader_name, tr("shader_game_argument"))
			return tr("shader_command_success") % [shader_readable_name, tr("shader_all_argument_reply")]

	return tr("shader_command_invalid_arguments")

func load_default_params(shader_name: String, shader_rect: String) -> void:
	if not shaders.has(shader_name):
		return

	var shader_info : Dictionary = shaders.get(shader_name)

	if not shader_info.has("default_params"):
		return

	var default_params : Dictionary = shader_info.default_params

	if shader_rect.to_lower() == tr("shader_world_argument").to_lower():
		for param in default_params:
			functions.set_world_shader_param(param, default_params[param])
	elif shader_rect.to_lower() == tr("shader_game_argument").to_lower():
		for param in default_params:
			functions.set_global_shader_param(param, default_params[param])

func set_shader_param(message) -> String:
	# /shaderparam <key> <value> [world or game]
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	var key : String
	var value : String

	if command_arguments.size() == 2:
		key = command_arguments[0]
		value = command_arguments[1]

		var formatted_value = functions.check_data_type(value) # Used to return data in the correct format
		functions.set_world_shader_param(key, formatted_value)

		return tr("shaderparam_command_success") % [key, value, tr("shader_world_argument")]
	elif command_arguments.size() == 3:
		key = command_arguments[0]
		value = command_arguments[1]

		var shader_rect : String = command_arguments[2]

		if shader_rect.to_lower() == tr("shader_world_argument").to_lower():
			var formatted_value = functions.check_data_type(value) # Used to return data in the correct format
			functions.set_world_shader_param(key, formatted_value)

			return tr("shaderparam_command_success") % [key, value, tr("shader_world_argument")]
		elif shader_rect.to_lower() == tr("shader_game_argument").to_lower():
			var formatted_value = functions.check_data_type(value) # Used to return data in the correct format
			functions.set_global_shader_param(key, formatted_value)

			return tr("shaderparam_command_success") % [key, value, tr("shader_game_argument")]
		elif shader_rect.to_lower() == tr("shader_all_argument").to_lower():
			var formatted_value = functions.check_data_type(value) # Used to return data in the correct format
			functions.set_world_shader_param(key, formatted_value)
			functions.set_global_shader_param(key, formatted_value)

			return tr("shaderparam_command_success") % [key, value, tr("shader_all_argument")]

	return tr("shaderparam_command_invalid_arguments")

# Only Useful in 3D
func set_debug_draw(message) -> String:
	# /debugdraw <mode>
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	return tr("debug_draw_command_2d_world")

	if command_arguments.size() != 1:
		return tr("debug_draw_command_invalid_number_of_arguments")

	var mode : String = command_arguments[0]

	var world_name : String = spawn_handler.get_world_name(gamestate.net_id) # Pick world player is currently in

	if not spawn_handler.has_world_node(world_name):
		return tr("debug_draw_command_missing_world_node")

	if not spawn_handler.get_world_node(world_name).has_node("Viewport"):
		return tr("debug_draw_command_missing_viewport_node")

	var viewport : Node = spawn_handler.get_world_node(world_name).get_node("Viewport")

	if mode == "disabled":
		viewport.set_debug_draw(Viewport.DEBUG_DRAW_DISABLED)
		return tr("debug_draw_command_disabled")
	elif mode == "wireframe":
		VisualServer.set_debug_generate_wireframes(true)
		viewport.set_debug_draw(Viewport.DEBUG_DRAW_WIREFRAME)
		return tr("debug_draw_command_wireframe")
	elif mode == "overdraw":
		viewport.set_debug_draw(Viewport.DEBUG_DRAW_OVERDRAW)
		return tr("debug_draw_command_overdraw")
	elif mode == "unshaded":
		viewport.set_debug_draw(Viewport.DEBUG_DRAW_UNSHADED)
		return tr("debug_draw_command_unshaded")

	return tr("debug_draw_command_unknown_mode")

func take_screenshot(message) -> String:
	# /screenshot <game or world>
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	# This works with Shaders

	# Determine Viewport to Screenshot
	var chosen_viewport : String
	if command_arguments.size() > 1:
		return tr("screenshot_command_too_many_arguments")
	elif command_arguments.size() == 1:
		chosen_viewport = command_arguments[0] # <game or world>
	else:
		chosen_viewport = tr("screenshot_game_argument")

	# Turns out Godot has ternary if statements
	# 0 is either <game or world>
	#chosen_viewport = command_arguments[0] if command_arguments.size() == 1 else tr("screenshot_game_argument")

	var viewport : Viewport

	# Find Viewport to Screenshot
	if chosen_viewport.to_lower() == tr("screenshot_world_argument").to_lower():
		var world_name : String = spawn_handler.get_world_name(gamestate.net_id) # Pick world player is currently in

		if not spawn_handler.get_world_node(world_name).has_node("Viewport"):
			return tr("screenshot_command_missing_viewport")

		viewport = spawn_handler.get_world_node(world_name).get_node("Viewport") # Just World
	elif chosen_viewport.to_lower() == tr("screenshot_game_argument").to_lower():
		viewport = get_viewport() # Whole Screen

	# Get Formatted DateTime
	var date_time = OS.get_datetime()
	var time_milliseconds = OS.get_system_time_msecs() - (OS.get_system_time_secs() * 1000)
	var formatted_time = tr("datetime_formatting_filename") % [int(date_time["hour"]), int(date_time["minute"]), int(date_time["second"]), time_milliseconds, OS.get_time_zone_info().name]

	# Pick Save Location
	var game_screenshot_folder : String = functions.get_translation(ProjectSettings.get_setting("application/config/name"), "en")
	var screenshot_folder : String = "%s".plus_file(game_screenshot_folder) % [OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)]
	var screenshot_filename : String = "%s_%s.png" % [formatted_time, chosen_viewport.to_lower()]
	var screenshot_filepath : String = (screenshot_folder.plus_file(screenshot_filename))

	# Create Screenshot Folder if Missing
	var screenshot_folder_reference : Directory = Directory.new()
	if not screenshot_folder_reference.dir_exists(screenshot_folder):
		var make_folder = screenshot_folder_reference.make_dir_recursive(screenshot_folder)

		if make_folder != 0:
			return tr("screenshot_command_failed_to_make_save_directory") % [screenshot_folder, make_folder]

	# Take and Save Screenshot
	var screenshot : Image = functions.take_screenshot(viewport)
	var save_success = screenshot.save_png(screenshot_filepath)

	# Return Status to Player
	if save_success == 0:
		return tr("screenshot_command_successful") % [chosen_viewport.to_lower(), screenshot_filepath]
	else:
		return tr("screenshot_command_failed_to_save") % [chosen_viewport.to_lower(), screenshot_filepath, save_success]

func start_recording(message) -> String:
	# Start Recording - May Do 30 Second Thing Where The Recording is Always Running.
	return ""

func get_class() -> String:
	return "ClientCommands"
