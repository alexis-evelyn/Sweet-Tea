extends Node
class_name ClientCommands

var shaders_class = preload("res://Scripts/functions/shader_registry.gd").new()
var shaders : Dictionary = shaders_class.shaders

# warning-ignore:unused_class_variable
#var dictionary = preload("res://Scripts/functions/dictionary_registry.gd").new()

# Used by Help Command to Provide List of Commands
var supported_commands : Dictionary = {
	"help_client": {"description": "help_help_client_desc", "cheat": false},
	"calc": {"description": "help_calc_desc", "cheat": false},
	"serverip": {"description": "help_serverip_desc", "cheat": false},
	"cam": {"description": "help_cam_desc", "cheat": true},
	"shaderinfo": {"description": "help_shaderinfo_desc", "cheat": true},

	"shader": {"description": "help_shader_desc", "cheat": true},
	"shaderparam": {"description": "help_shaderparam_desc", "cheat": true},
	"debug": {"description": "help_debug_desc", "cheat": true},
#	"debugdraw": {"description": "help_debugdraw_desc", "cheat": true},

	"screenshot": {"description": "help_screenshot_desc", "cheat": false},
	"dict": {"description": "help_dict_desc", "cheat": true},

	"debugcollisions": {"description": "help_debugcollisions_desc", "cheat": true},
	"testvibration": {"description": "help_testvibration_desc", "cheat": false},
	"controllers": {"description": "help_controllers_desc", "cheat": false},
	"randomshader": {"description": "help_randomshader_desc", "cheat": true},
	"mirror": {"description": "help_mirror_desc", "cheat": false},
	"timescale": {"description": "help_timescale_desc", "cheat": true},
	"saves": {"description": "help_saves_desc", "cheat": false} # Technically can be used for cheating, but really, who cares. I don't. The person playing the game is only going to ruin it for themselves if they cheat (before beating the game legitimately).
}

func process_commands(message: PoolStringArray) -> String:
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)

	match command:
		"help_client":
			return help_command(message)
		"calc":
			return open_calculator(message)
		"server_ip":
			return server_ip(message)
		"serverip":
			return server_ip(message)
		"cam":
			return teleport_camera(message)
		"shaderinfo":
			return shader_info(message)
		"shader":
			return set_shader(message)
		"shaderparam":
			return set_shader_param(message)
		"debug":
			return toggle_debug_mode(message)
		"debugdraw":
			return set_debug_draw(message)
		"screenshot":
			return take_screenshot(message)
		"dict":
			return read_dictionary(message)
		"debugcollisions":
			return set_debug_collisions(message)
		"testvibration":
			return test_joy_vibration(message)
		"controllers":
			return list_controllers(message)
		"randomshader":
			return pick_random_shader(message)
		"mirror":
			return farest_mirror(message)
		"timescale":
			return set_timescale(message)
		"saves":
			return open_saves_folder(message)
		_:
			return functions.empty_string

# warning-ignore:unused_argument
func help_command(message: PoolStringArray) -> String:
	# I'm not sure how to receive data from server within this function if it is even possible.
#	rpc_unreliable_id(gamestate.standard_netids.server, "chat_message_server", message, true)

	return "Help Command"

# warning-ignore:unused_argument
func open_calculator(message: PoolStringArray) -> String:
	if not get_tree().get_root().has_node("Calculator"):
		var calc : Control = preload("res://Menus/Jokes/Calculator.tscn").instance()
		calc.name = "Calculator"

		get_tree().get_root().get_node("PlayerUI").add_child(calc)
#		get_tree().get_root().add_child_below_node(get_node_or_null("/root/Worlds"), calc)
#		get_tree().get_root().move_child(calc, 0)

	return tr("open_calculator")

# warning-ignore:unused_argument
func server_ip(message: PoolStringArray) -> String:
	var net : NetworkedMultiplayerENet = get_tree().get_network_peer()

	if gamestate.net_id == gamestate.standard_netids.server:
		return tr("server_ip_command_self")

	return tr("server_ip_command") % net.get_peer_address(1)

func teleport_camera(message: PoolStringArray) -> String:
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

		return tr("teleport_camera_command_not_enough_arguments")
	elif command_arguments.size() == 3:
		# Teleport Camera Player to Other Location (if alphabetical characters are first)
		# Disable Safety Check (if alphabetical characters are third)

		# Not Implemented

		return tr("teleport_camera_command_too_many_arguments")
	elif command_arguments.size() == 0:
		return tr("teleport_camera_command_not_enough_arguments")
	else:
		return tr("teleport_camera_command_too_many_arguments")

	#var command_permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level

	var world_name : String = spawn_handler.get_world_name(gamestate.net_id) # Pick world player is currently in

	if not spawn_handler.get_world_node(world_name).has_node("Viewport/DebugCamera"):
		return tr("teleport_camera_command_missing_debug_camera")

	var camera : Camera2D = spawn_handler.get_world_node(world_name).get_node("Viewport/DebugCamera")

	camera.update_camera_pos(coordinates)
	camera.update_camera_pos_label()

	return tr("teleport_camera_command_success") % [coordinates.x, coordinates.y]

func shader_info(message: PoolStringArray) -> String:
	# /shaderinfo [shader_name]
	# warning-ignore:unused_variable
#	TranslationServer.set_locale("mz")

	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	# warning-ignore:unassigned_variable
	var response : PoolStringArray

	for shader in shaders:
		response.append(tr("shader_info_command_id") % shader)
		response.append(tr("shader_info_command_name") % tr(shaders[shader].name))
		response.append(tr("shader_info_command_description") % tr(shaders[shader].description))
		response.append(tr("shader_info_command_seizure_warning") % shaders[shader].seizure_warning)
		response.append(functions.empty_string)

	response.remove(response.size()-1)

	return response.join("\n")

func set_shader(message: PoolStringArray) -> String:
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
			shader_readable_name = tr(shaders.get(shader_name).name)

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

func set_shader_param(message: PoolStringArray) -> String:
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
func set_debug_draw(message: PoolStringArray) -> String:
	# /debugdraw <mode>
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	return tr("debug_draw_command_2d_world")

	# Why is this marked as unreachable code?
	# warning-ignore:unreachable_code
	if command_arguments.size() != 1:
		return tr("debug_draw_command_invalid_number_of_arguments")

	var mode : String = command_arguments[0]

	var world_name : String = spawn_handler.get_world_name(gamestate.net_id) # Pick world player is currently in

	if not spawn_handler.has_world_node(world_name):
		return tr("debug_draw_command_missing_world_node")

	if not spawn_handler.get_world_node(world_name).has_node("Viewport"):
		return tr("debug_draw_command_missing_viewport_node")

	var viewport : Viewport = spawn_handler.get_world_node(world_name).get_node("Viewport")

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

func take_screenshot(message: PoolStringArray) -> String:
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
#	var game_screenshot_folder : String = functions.get_translation(ProjectSettings.get_setting("application/config/name"), "en") # For Some Reason, This Just Quit Working. Maybe it Has To Do With The Space in The Name Plus The New Addition Of Reading Multiple Translation Files?
	var game_screenshot_folder : String = ProjectSettings.get_setting("application/config/name")
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

func read_dictionary(message: PoolStringArray) -> String:
	# /dict <word>
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	# If No Arguments Specified, Open GUI Dictionary
	# Else Continue Onto Text Dictionary Search
	if command_arguments.size() == 0 and not get_tree().get_root().has_node("Mazawalza_Dictionary"):
		var dictionary : Control = preload("res://Menus/Dictionary.tscn").instance()
		dictionary.name = "Mazawalza_Dictionary"

		get_tree().get_root().get_node("PlayerUI").add_child(dictionary)
		return tr("open_dictionary")

	# warning-ignore:unassigned_variable
	var output

#	var client_translation : String = tr("entry_language_name")
#	var mazawalza_translation : String = functions.parse_for_unicode(functions.get_translation("entry_language_name", "mz"))
#	var output : String = "entry_language_name: %s - [font=%s]'%s'[/font]" % [client_translation, gamestate.mazawalza_regular.resource_path, mazawalza_translation]

	return output

func set_debug_collisions(message: PoolStringArray) -> String:
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

#		get_tree().debug_collisions_hint = true
#		get_tree().debug_navigation_hint = true

	if command_arguments.size() != 1:
		return tr("debug_collisions_invalid_number_of_arguments") % [tr("bool_true"), tr("bool_false")]

	if command_arguments[0].to_lower() == tr("bool_true").to_lower():
		get_tree().set_debug_collisions_hint(true)
#		get_tree().reload_current_scene()
		return tr("debug_collisions_set_bool") % command_arguments[0]
	elif command_arguments[0].to_lower() == tr("bool_false").to_lower():
		get_tree().set_debug_collisions_hint(false)
#		get_tree().reload_current_scene()
		return tr("debug_collisions_set_bool") % command_arguments[0]

	return tr("debug_collisions_unknown_argument") % command_arguments[0]

# warning-ignore:unused_argument
func start_recording(message: PoolStringArray) -> String:
	# Start Recording - May Do 30 Second Thing Where The Recording is Always Running.
	return functions.empty_string

# warning-ignore:unused_argument
func test_joy_vibration(message: PoolStringArray) -> String:
	for controller in Input.get_connected_joypads():
		# Test Vibration of Controller
		Input.start_joy_vibration(controller, 100, 100, 10)

		logger.debug(str(controller))

	return "Testing... Not Fully Implemented. Don't Have Vibration Working For DS4 Controller Yet."

# warning-ignore:unused_argument
func list_controllers(message: PoolStringArray) -> String:
	# warning-ignore:unassigned_variable
	var response : PoolStringArray

	for controller in Input.get_connected_joypads():
		response.append(tr("list_controllers_command_line") % [controller, Input.get_joy_name(controller), Input.get_joy_guid(controller)])

	if response.size() != 0:
		return response.join("\n")

	return tr("list_controllers_no_controllers")

# warning-ignore:unused_argument
func toggle_debug_mode(message: PoolStringArray) -> String:
	gamestate.debug = !gamestate.debug # Flip Gamestate Debug Boolean

	var player : Player = spawn_handler.get_player_body_node(gamestate.net_id) # Get Player's Node

	if player == null:
		return tr("toggle_debug_mode_command_missing_player_node") # Failed to Get Player's KinematicBody2D

	player.remove_camera() # Removes Old Camera

	if gamestate.debug:
		player.debug_camera(true) # Activates Debug Camera

		var worlds : Node = get_tree().get_root().get_node_or_null("Worlds")
		var world_generator : TileMap

		if worlds == null:
			return tr("toggle_debug_mode_command_missing_worlds_node")

		for world in worlds.get_children():
			world_generator = spawn_handler.get_world_generator_node(world.name)

			if world_generator != null:
				world_generator.tile_set = world_generator.debug_tileset
				world_generator.background_tilemap.tile_set = world_generator.debug_tileset_background
				world_generator.set_shader_background_tiles()

#		gamestate.save_player(gamestate.loaded_save) # Save Player Debug Mode Switch
		gamestate.overwrite_save_value(gamestate.loaded_save, "debug", true)

		return tr("toggle_debug_mode_command_on")
	else:
		player.player_camera(true) # Activates Regular Camera

		var worlds : Node = get_tree().get_root().get_node_or_null("Worlds")
		var world_generator : TileMap

		if worlds == null:
			return tr("toggle_debug_mode_command_missing_worlds_node")

		for world in worlds.get_children():
			world_generator = spawn_handler.get_world_generator_node(world.name)

			if world_generator != null:
				world_generator.tile_set = world_generator.default_tileset
				world_generator.background_tilemap.tile_set = world_generator.default_tileset_background
				world_generator.set_shader_background_tiles()

#		gamestate.save_player(gamestate.loaded_save) # Save Player Debug Mode Switch
		gamestate.overwrite_save_value(gamestate.loaded_save, "debug", false)

		return tr("toggle_debug_mode_command_off")

func pick_random_shader(message: PoolStringArray) -> String:
	# /randomshader [world or game]
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	var shader_name : String = shaders.keys()[randi() % shaders.size()]

	functions.set_world_shader(load(shaders.get(shader_name).path))
	load_default_params(shader_name, tr("shader_world_argument"))

	return tr("random_shader_command_success") % tr(shaders.get(shader_name).name)

func farest_mirror(message: PoolStringArray) -> String:
	"""
		Used to Give Game A Mirror Mode

		Note For Modders, Only The Client Cares About Input. The server doesn't know what buttons are being pressed.

		Not Meant to Be Called Directly
	"""

	# /mirror
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	# Mirror Mode Turned On
	if functions.mirror_world():
		return tr("mirror_command_on")

	# Mirror Mode Turned Off
	return tr("mirror_command_off")

func set_timescale(message: PoolStringArray) -> String:
	# /timescale [value or increment]
	# /timescale 1.0
	# /timescale +3.0
	# /timescale -3.0

	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	if command_arguments.size() != 1:
		if command_arguments.size() == 0:
			return tr("timescale_command_display_timescale") % Engine.time_scale

		return tr("timescale_command_invalid_number_of_arguments")

	var old_timescale : float = Engine.time_scale # Used to check if timescale set successfully
	var timescale : String = command_arguments[0]

	if "+" in timescale:
		Engine.time_scale += float(timescale)

		if Engine.time_scale == old_timescale:
			return tr("timescale_command_plus_timescale_not_changed") % Engine.time_scale

		return tr("timescale_command_timescale_added") % [float(timescale), Engine.time_scale]
	elif "-" in timescale:
		Engine.time_scale += float(timescale)

		if Engine.time_scale == old_timescale:
			return tr("timescale_command_minus_timescale_not_changed") % Engine.time_scale

		return tr("timescale_command_timescale_subtracted") % [float(timescale) * -1.0, Engine.time_scale]

	Engine.time_scale = float(timescale)

	if Engine.time_scale == old_timescale:
		return tr("timescale_command_timescale_not_changed") % Engine.time_scale

	return tr("timescale_command_timescale_set") % Engine.time_scale

func open_saves_folder(message: PoolStringArray) -> String:
	# /saves

	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_arguments : PoolStringArray = message
	command_arguments.remove(0)

	var error_code : int = OS.shell_open("file://".plus_file(OS.get_user_data_dir()))

	if error_code == OK:
		return tr("saves_command_success")

	return tr("saves_command_failed") % error_code




func get_class() -> String:
	return "ClientCommands"
