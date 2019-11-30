extends Node
class_name Functions

# Allows For Configuration Over When to Request Attention
enum attention_reason {
	unspecified = -1,
	private_message = 0,
	character_attacked = 1,
	character_died = 2
}

# To make it easier to check the host system type
enum host_system {
	unknown = -1,
	android = 0,
	haiku = 1,
	iOS = 2,
	html5 = 3,
	OSX = 4,
	Server = 5,
	Windows = 6,
	UWP = 7,
	X11 = 8
}

# To Select World Shader Rectangle to Use
enum shader_rectangle_id {
	primary = 0, # Main Shaders Use This
	secondary = 1 # Added So Mirror Mode Can Exist Without Stopping Other Shaders From Being Used
}

enum moon_phase {
	# The 4 Main Phases Are New, Third Quarter, Full, and First Quarter
	# https://sciencetrends.com/the-8-moon-phases-in-order-with-bonus-moon-phase-calendar/
	invalid_phase = -1, # Not A Valid Phase
	new = 0, # New Moon
	waxing_crescent = 1, # Waxing Crescent
	first_quarter = 2, # First Quarter
	waxing_gibbous = 3, # Waxing Gibbous
	full = 4, # Full Moon
	waning_gibbous = 5, # Waning Gibbous
	third_quarter = 6, # Third Quarter
	waning_crescent = 7, # Waning Crescent
}

var shaders_class = preload("res://Scripts/functions/shader_registry.gd").new()
var shaders : Dictionary = shaders_class.shaders

# Set by using set_script(lua_class)
var lua_class : NativeScript = preload("res://Modules/lua/LuaScript.gdns")

# These Are Used to Save Memory
const empty_string = ""
const space_string = " "
const not_set_string = "Not Set"

# get_class() - https://godotengine.org/qa/46057/how-to-get-the-class-name-of-a-custom-node?show=46059#a46059

# Declare member variables here. Examples:
var current_title : String = empty_string
var screenshot : Image # Variable To Hold Screenshot

# I may replace the default window title bar with my own. - https://www.youtube.com/watch?v=alKdkRJy-iY&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r&index=4&t=0s
func set_title(title: String):
	current_title = title
	OS.set_window_title(title) # Sets Window's Title

# Gets Title of Window
func get_title() -> String:
	# There is no builtin way to get the window title, so I have to store it in a variable. - https://github.com/godotengine/godot/issues/27536
	return current_title

sync func request_attention(reason: int = attention_reason.unspecified) -> void:
	# Use the reason combined with notification settings to determine if attention should be requested
	if reason == attention_reason.private_message:
		logger.debug("Received Private Message!!!")
		OS.request_attention()
	elif reason == attention_reason.character_attacked:
		logger.warning("Character Has Been Attacked!!!")
		OS.request_attention()
	elif reason == attention_reason.character_died:
		logger.error("Character Has Died!!!")
		OS.request_attention()
	elif reason == attention_reason.unspecified:
		logger.debug("Reason For Request Was Unspecified!!!")
	else:
		logger.debug("Unknown Reason For Requesting Attention!!!")

# While this is no longer used as Github user merumelu helped me out with reading the .translation files, but I am keeping it here incase it becomes useful later.
# For example, I don't know if the Godot engine can generate translation files after the game is built, so I may build in an interface to let users produce their own translation in game and then just save it in csv format.
func get_translation_csv(translations_file: String, key: String, locale: String) -> String:
	#var translations_file : String = ProjectSettings.get_setting("locale/csv")

	var file = File.new()
	var open_csv_status = file.open(translations_file, file.READ)

	# Make sure there is at least one line available to read, otherwise just return
	if open_csv_status != OK:
		logger.error("Failed to find locale '%s' for key '%s' because the csv file '%s' couldn't be opened!!!" % [locale, key, translations_file])
		file.close()
		return functions.empty_string

	if file.eof_reached():
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is empty!!!" % [locale, key, translations_file])
		file.close()
		return functions.empty_string

	var index : int = -1 # Column that Locale Is On
	var line : Array = Array(file.get_csv_line()) # Get first line of csv file

	# If it does not have the locale requested, then just return
	if not line.has(locale):
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is does not have the locale!!!" % [locale, key, translations_file])
		file.close()
		return functions.empty_string

	index = line.find(locale) # Get column the locale is on

	while !file.eof_reached():
		line = Array(file.get_csv_line())

		if line[0] == key:
			#logger.verbose("Translation: %s" % line[index])
			file.close()
			return line[index]

	logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' does not have the key!!!" % [locale, key, translations_file])
	file.close()
	return functions.empty_string # If it does not have the key, then just return

# Get Translation For Specified Locale
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_translation(key: String, locale: String) -> String:
	# Thank merumelu for their help on my reading translation files issue: https://github.com/godotengine/godot/issues/31749

	# Also make sure to add support for po files later.
	var translations : PoolStringArray = ProjectSettings.get_setting("locale/translations")
	# warning-ignore:unassigned_variable
	var selected_translations : PoolStringArray

	for translation in translations:
		#res://Assets/Languages/default.pr.translation
		var translation_locale : String = translation.rsplit(".", false, 2)[1]
#		logger.debug("Translation File: %s" % translation_locale)
#		print("Translation File: '%s' - Translation: %s" % [translation_locale, translation])

		if translation_locale == locale:
			selected_translations.append(translation)

	# If No Translation File Found, Then Just Return. This will crash on debug builds, but not release builds.
	if selected_translations.size() == 0:
		logger.error("No Translation File Found For Locale '%s'" % locale)
		return tr("missing_translation_file") % locale

	var translator : Translation
	var message : String
	for selected_translation in selected_translations:
		translator = load(selected_translation)

		# Only Set Message if Translation File Has Value (Last File's Value is Used)
		if not translator.get_message(key).empty():
			message = translator.get_message(key)#.c_unescape()
#			print("Translation Message: %s - Selected Translation: %s" % [message, selected_translation])
			break # Stop Searching Once First Instance of Key-Value is Found (Helps Speed Up Return of Value)

	# Should I check if the translation came back successful or will translator handle it for me?

	#logger.superverbose("Message: %s" % message)

	return message

# Useful for Translation Selection Menu
func list_game_translations() -> Dictionary:
	# Also make sure to add support for po files later.
	var translations : PoolStringArray = ProjectSettings.get_setting("locale/translations")
	var game_translation_name : String = ProjectSettings.get_setting("locale/game_translation_file_name")
	var translation_names : Dictionary = {}
	translation_names.locales = []

	for translation in translations:
		#res://Assets/Languages/default.pr.translation
		var translation_name : String = translation.rsplit(".", false, 2)[0].rsplit("/", false, 1)[1]

		if game_translation_name == translation_name:
			var translation_locale : String = translation.rsplit(".", false, 2)[1]
			translation_names.locales.append({"locale": translation_locale, "name": TranslationServer.get_locale_name(translation_locale), "native_name": get_translation("language_name", translation_locale), "font_regular": get_translation("language_font_regular", translation_locale)})

#			logger.superverbose("Native Language Name: %s" % get_translation("language_name", translation_locale))
#			logger.superverbose("Translation: %s/%s" % [translation_locale, TranslationServer.get_locale_name(translation_locale)])

#	print("Translation Dictionary: %s" % translation_names)
	return translation_names

func get_world_camera(rectangle_id : int = shader_rectangle_id.primary) -> ColorRect:
	var shader_screen : ColorRect
	var player : Node2D = spawn_handler.get_player_body_node(gamestate.net_id)

	if player == null:
		return null

	if player.has_node("PlayerCamera"):
		if rectangle_id == shader_rectangle_id.primary:
			shader_screen = player.get_node("PlayerCamera").get_node("PrimaryShaderRectangle")
		elif rectangle_id == shader_rectangle_id.secondary:
			shader_screen = player.get_node("PlayerCamera").get_node("secondaryBackBuffer/SecondaryShaderRectangle")
	else:
		if not gamestate.player_info.has("current_world"):
			logger.error("Set World Shader - Missing Current World Info")
			return null

		var world : ViewportContainer = spawn_handler.get_world_node(gamestate.player_info.current_world)

		if not world.get_node("Viewport").has_node("DebugCamera"):
			logger.error("Set World Shader - Missing Debug Camera")
			return null

		if rectangle_id == shader_rectangle_id.primary:
			shader_screen = world.get_node("Viewport").get_node("DebugCamera").get_node("PrimaryShaderRectangle")
		elif rectangle_id == shader_rectangle_id.secondary:
			shader_screen = world.get_node("Viewport").get_node("DebugCamera").get_node("secondaryBackBuffer/SecondaryShaderRectangle")

	return shader_screen

func set_world_shader(shader: Shader, rectangle_id : int = shader_rectangle_id.primary) -> bool:
	var shader_screen : ColorRect = get_world_camera(rectangle_id)

	if shader_screen == null:
		logger.error("Set World Shader - Failed to Get Shader Rectangle for Shader: %s" % shader.resource_path)
		return false

	var shader_material : ShaderMaterial = ShaderMaterial.new()
	shader_material.set_shader(shader)

	shader_screen.set_material(shader_material)
	shader_screen.visible = true

	return true

func set_world_shader_param(param: String, value, rectangle_id : int = shader_rectangle_id.primary) -> bool:
	var shader_screen : ColorRect = get_world_camera(rectangle_id)

	if shader_screen == null:
		logger.error("Set World Shader Param - Failed to Get Shader Rectangle for Shader")
		return false

	var shader_material : ShaderMaterial = shader_screen.get_material()

	if shader_material == null:
		logger.error("Set World Shader Param - Failed to Get Shader Material for Shader")
		return false

	shader_material.set_shader_param(param, value)

	return true

func remove_world_shader(rectangle_id : int = shader_rectangle_id.primary) -> bool:
	var shader_screen : ColorRect = get_world_camera(rectangle_id)

	if shader_screen == null:
#		logger.error("Remove World Shader - Failed to Get Shader Rectangle for Shader")
		return true

	if shader_screen.get_material() == null:
		return true

	var shader_material : ShaderMaterial = shader_screen.get_material()
	shader_material.set_shader(null)

	shader_screen.set_material(null)
	shader_screen.visible = false

	return true

func set_global_shader(shader: Shader) -> bool:
	if not get_tree().get_root().get_node("Player_UI").has_node("Screen Shader"):
		logger.error("Set World Shader Param - Failed to Get Shader Rectangle for Shader: %s" % shader.resource_path)
		return false

	var shader_screen : ColorRect = get_tree().get_root().get_node("Player_UI").get_node("Screen Shader")

	var shader_material : ShaderMaterial = ShaderMaterial.new()
	shader_material.set_shader(shader)

	shader_screen.set_material(shader_material)
	shader_screen.visible = true

	return true

func set_global_shader_param(param: String, value) -> bool:
	if not get_tree().get_root().get_node("Player_UI").has_node("Screen Shader"):
		logger.error("Set Global Shader Param - Failed to Get Shader Rectangle for Shader")
		return false

	var shader_screen : ColorRect = get_tree().get_root().get_node("Player_UI").get_node("Screen Shader")

	var shader_material : ShaderMaterial = shader_screen.get_material()

	if shader_material == null:
		logger.error("Set Global Shader Param - Failed to Get Shader Material for Shader")
		return false

	shader_material.set_shader_param(param, value)

	return true

func remove_global_shader() -> bool:
#	if not get_tree().get_root().get_node("Player_UI").has_node("Screen Shader"):
#		return true

	var shader_screen : ColorRect = get_tree().get_root().get_node("Player_UI").get_node("Screen Shader")

	if shader_screen.get_material() == null:
		return true

	var shader_material : ShaderMaterial = shader_screen.get_material()
	shader_material.set_shader(null)

	shader_screen.set_material(null)
	shader_screen.visible = false

	return true

# Example Shader Rectangle Creation Code
#func create_global_shader_rect() -> void:
#	if get_tree().get_root().get_node("Player_UI").has_node("Screen Shader"):
#		return
#
#	var shader_screen : ColorRect = ColorRect.new()
#	shader_screen.rect_position = Vector2(0, 0)
#	shader_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
#	shader_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	shader_screen.name = "Screen Shader"
#
#	get_tree().get_root().get_node("Player_UI").add_child(shader_screen)

func check_data_type(data: String):
	# Check if hex code
	if data.is_valid_html_color():
		logger.superverbose("Data Type is Color!!!")
		# It's a html color, so convert it to a color type
		return Color(data)

	# Return data back in string format if no matches (or converts to proper type not explicitly checked for; e.g. Vector3)
	return str2var(data)

func take_screenshot(viewport: Viewport) -> Image:
	screenshot = viewport.get_texture().get_data()
	screenshot.flip_y() # For some reason, the screenshot is flipped, so we have to flip it ourself

#	yield(get_tree(), "idle_frame")
	# Thread this?

	return screenshot

# Parses For Unicode Strings (It doesn't actually parse Unicode, it just converts Unicode representations of characters to Unicode)
func parse_for_unicode(string: String) -> String:
	# I am Releasing This Function to Public Domain
	# http://kunststube.net/encoding/

	# Pull Hex From Unicode String Representation
	var unicode_chars : PoolStringArray = string.split("\\u", false)
	# warning-ignore:unassigned_variable
	var unicode_ints : PoolIntArray

	logger.superverbose("Pre-Parsed String: %s" % string)
	logger.superverbose("Unicode Chars Size: %s" % unicode_chars.size())

	# Convert Hex to Integers
	for x in range(0, unicode_chars.size()):
		logger.superverbose("Hex Character: 0x%s" % unicode_chars[x].strip_edges())
		unicode_chars.set(x, "0x%s" % unicode_chars[x].strip_edges())
		unicode_ints.append(unicode_chars[x].hex_to_int())

	# Convert Integers to Characters
	var joined_chars : String = functions.empty_string
	for unicode_int in unicode_ints:
		joined_chars += char(unicode_int)

	return joined_chars

# Used for Tracking What Host System We Are Running On
func get_system() -> int:
	match OS.get_name():
		"Android":
			return host_system.android
		"Haiku":
			return host_system.haiku
		"iOS":
			return host_system.iOS
		"HTML5":
			return host_system.html5
		"OSX":
			return host_system.OSX
		"Server":
			return host_system.Server
		"Windows":
			return host_system.Windows
		"UWP":
			return host_system.UWP
		"X11":
			return host_system.X11
		_:
			return host_system.unknown

# Meant to Be Assigned to Hotkeys
func run_button_command(panelChat: ChatPanel, command_id: String = "0") -> void:
	# In the Release Version, None Of The Hotkeys Will Be Pre-Assigned.
	# They Will Be Configurable In The Options Menu (and Commands Will Be Assigned Via Chat)

	if command_id == "0":
		# For Testing is Assigned L3
		panelChat.autosend_command("/randomshader")
	elif command_id == "1":
		# For Testing is Assigned R3
		panelChat.autosend_command("/shader remove")
	elif command_id == "2":
		# For Testing is Assigned Select
		panelChat.autosend_command("/mirror")

# Meant to Be Assigned to Joypad Axes
func run_axes_command(panelChat: ChatPanel, command_id: String = "0") -> void:
	pass

func teleport_despawn(net_id: int, coordinates: Vector2, world_name: String = empty_string) -> void:
	# Detect if World is Being Changed
	if world_name == empty_string:
		world_name = spawn_handler.get_world_name(net_id) # Pick world player is currently in

	# Clears Loaded Chunks From Previous World Generator's Memory
	var world_generation = spawn_handler.get_world_generator_node(spawn_handler.get_world_name(net_id))
	world_generation.clear_player_chunks(net_id)
	#logger.verbose("Previous World: %s" % spawn_handler.get_world_name(net_id))

	spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else

#	player_registrar.players[net_id].spawn_coordinates = coordinates # Set To Use World's Spawn Location
	player_registrar.players[net_id].spawn_coordinates_safety_off = coordinates # Set To Use World's Spawn Location

	if net_id == gamestate.standard_netids.server:
		#logger.verbose("Server Change World: %s" % net_id)
		spawn_handler.change_world(world_name)

	#logger.verbose("NetID Change World: %s" % net_id)
	spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name, true)

func teleport(net_id: int, coordinates: Vector2) -> int:
	var player : Player = spawn_handler.get_player_body_node(net_id)

	if player == null:
		return ERR_CANT_ACQUIRE_RESOURCE

	player.correct_coordinates(coordinates) # Update Coordinates on Server
	player.correct_coordinates_server() # Server Checking is Already Handled by Player Node

	if net_id != gamestate.standard_netids.server:
		player.rpc_unreliable_id(net_id, "correct_coordinates", coordinates) # Send New Coordinates to Client

	return OK

func mirror_world() -> bool:
	"""
		Toggles Mirror Mode
	"""

	# TODO: Color Rectangles Cannot Work Next To Each Other In Same Parent Node. Why?
	# Fix this.

	# Switch Back to Secondary After Fixs

	gamestate.mirrored = !gamestate.mirrored

	if gamestate.mirrored:
		var shader_name : String = "mirror" # Set back to mirror once mirror shader is created.

		set_world_shader(load(shaders.get(shader_name).path), shader_rectangle_id.secondary)
#		load_default_params(shader_name, tr("shader_world_argument"))
	else:
		remove_world_shader(shader_rectangle_id.secondary)

	return gamestate.mirrored

func grab_player_body_by_id(playerid: String) -> Node:
	"""
		Grab Player's Body By ID

		I may implement a user friendly id/username system on top of using net_id.
		This function will be able to process both net_id and the user friendly id.

		This function is meant to be used when the id type is unknown (e.g. commands).
		It is not meant to be used when the id is guaranteed to be a net_id.

		If playerid is guaranteed to be a net_id, use 'spawn_handler.get_player_body_node(net_id: int) -> Node'.
		This is to avoid using unnecessary memory dealing with string conversion.
	"""

	if playerid.is_valid_integer():
		return spawn_handler.get_player_body_node(int(playerid))

	# Eventually, there will be a way to retrieve a player node by a user friendly id.
	# User friendly ids just need to exist first.

	return null

func grab_player_node_by_id(playerid: String) -> Node:
	"""
		Grab Player's Node By ID

		I may implement a user friendly id/username system on top of using net_id.
		This function will be able to process both net_id and the user friendly id.

		This function is meant to be used when the id type is unknown (e.g. commands).
		It is not meant to be used when the id is guaranteed to be a net_id.

		If playerid is guaranteed to be a net_id, use 'spawn_handler.get_player_node(net_id: int) -> Node'.
		This is to avoid using unnecessary memory dealing with string conversion.
	"""

	if playerid.is_valid_integer():
		return spawn_handler.get_player_node(int(playerid))

	# Eventually, there will be a way to retrieve a player node by a user friendly id.
	# User friendly ids just need to exist first.

	return null

func execute_lua_file(lua_script : String, function: String, arguments: Array):
	"""
		Generic Lua Executing Function
	"""

	# How Can I Properly Thread This and Properly Return Value to Calling Function?

	var lua : NativeScript = Reference.new() # Doesn't Need to Be Garbage Collected - https://godotengine.org/qa/4658/is-gdscript-garbage-collected-or-reference-counted?show=4668#a4668
	lua.set_script(lua_class)

	if not lua.load(lua_script):
		return false # Failed to Load Lua Script

	# Lua will always return an Array (for some reason is backwards)
	var results : Array = lua.execute(function, arguments)

	results.invert() # Reverses Order of Array to Correct for Backwards Order

	return results

func calculate_julian_date(gregorian_date: Dictionary = OS.get_datetime(true)) -> float:
	# No Year 0 on Julian System

	# Dates October 5, 1582 through October 14, 1582 Don't Exist (10 Days)
	# The day after October 4, 1582 became October 15, 1582 (14-4=10)

	# We Don't Need to Worry About BCE (Because We Aren't Building A Calculator, Just Detecting Moon Phases For Easter Eggs)

	# Also, If January or February, Subtract 1 From Year and Add 12 To The Month (Otherwise Leave it Alone)

	# https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
	# https://www.subsystems.us/uploads/9/8/9/4/98948044/moonphase.pdf
	# Obviously Y M D is Year Month Day. (The Year is 4 Digits or Full Year)
	# A = floor(Y/100)
	# B = floor(A/4)
	# C = 2-A+B
	# E = floor(365.25 * (Y+4716))
	# F = floor(30.6001 * (M+1))
	# JD = C+D+E+F-1524.5

	# year, month, day, weekday, dst (daylight savings time), hour, minute, second.

	# This is only accurate after 1582, but since we aren't building a calculator, I am not concerned with 1582 and before.
	# For completionists sake, I may eventually fix it, but not right now.

	# This calculates the date itself, not the time (time will be set to noon - something astronomers something)
	var a = floor(gregorian_date.year/100)
	var b = floor(a/4)
	var c = 2-a+b
	var e = floor(365.25 * (gregorian_date.year+4716))
	var f = floor(30.6001 * (gregorian_date.month+1))
	var julian_date = c+gregorian_date.day+e+f-1524.5

	# These Both Produce The Same Value, Just Now We Have To Figure Out Which One is More Memory Efficient
#	var julian_date = 2 - floor(gregorian_date.year/100) + floor(floor(gregorian_date.year/100)/4) + gregorian_date.day + floor(365.25 * (gregorian_date.year+4716)) + floor(30.6001 * (gregorian_date.month+1)) - 1524.5

	# This will add up the time to the previously set date
	# https://sciencing.com/calculate-julian-date-6465290.html
	# Do I Really Need to Worry About Time of Day For Predicting Moon Phases? No
	# For completionists sake, I may eventually fix it, but not right now.
	pass

	return julian_date

func calculate_moon_phase(julian_date: float) -> int:
	# Last New Moon - https://www.calendar-365.com/moon/moon-phases.html
	# October 27, 2019 08:40:15 PM (MST) - 2458784.36128
	# October 27, 2019 - 2458783.50000

	# January 6, 2000 Midnight (UTC) - 2451549.5

	# I Don't Think Timezones Matter, But I Could Be Wrong, So I Am Writing It Down Anyway

	var new_moon_date : float = 2451549.5
	var days_of_cycle : float = 29.53
	#var number_of_new_moons : float = (julian_date - new_moon_date) / days_of_cycle
	#var days_into_cycle : float = (decimal_part_of_number_of_new_moons) * days_of_cycle

	var days_into_cycle : float = fmod((julian_date - new_moon_date), days_of_cycle) # To be able to do modulus on floats

	logger.superverbose("Days Into Cycle: %0.2f" % days_into_cycle)

	# Number of Days After Which Phase is Active
#	moon_phase.new # 0 and 29.53
#	moon_phase.waning_crescent # 7/2 = 3.5
#	moon_phase.first_quarter # 7
#	moon_phase.waning_gibbous # ((15 - 7) / 2) + 7 = 11
#	moon_phase.full # 15
#	moon_phase.waxing_gibbous # ((22 - 15) / 2) + 15 = 18.5
#	moon_phase.third_quarter # 22
#	moon_phase.waxing_crescent # ((29.53 - 22) / 2) + 22 = 25.765

	# Cycle Start - 0, 3.5, 7, 11, 15, 18.5, 22, 25.765, 29.53
	# Cycle Add - 0, +3.5, +3.5, +4, +4, +3.5, +3.5, +3.765, +3.765

	# The Cresent and Gibbous Phases Are Not Detected Properly - Everything Else Is Fine

	# It's Trickier To Figure Out Phase Than Just Recording Values
	# I'd Have To Literally Track Its Orbit and Know Where In The World The Player Is To BE 100% Accurate
	# I'm Not Doing That, So...
	# https://en.wikipedia.org/w/index.php?title=Lunar_phase&oldid=923713150#Phases_of_the_Moon

	var ninths : float = 29.53/9.0

	logger.superverbose("New Moon: %0.2f-%0.2f" % [0, ninths])
	logger.superverbose("Waxing Crescent: %0.2f-%0.2f" % [ninths, ninths*2])
	logger.superverbose("First Quarter: %0.2f-%0.2f" % [ninths*2, ninths*3])
	logger.superverbose("Waxing Gibbous: %0.2f-%0.2f" % [ninths*3, ninths*4])
	logger.superverbose("Full Moon: %0.2f-%0.2f" % [ninths*4, ninths*5])
	logger.superverbose("Waning Gibbous: %0.2f-%0.2f" % [ninths*5, ninths*6])
	logger.superverbose("Third Quarter: %0.2f-%0.2f" % [ninths*6, ninths*7])
	logger.superverbose("Waning Crescent: %0.2f-%0.2f" % [ninths*7, ninths*8])
	logger.superverbose("New Moon: %0.2f-%0.2f" % [ninths*8, 29.53])

	if days_into_cycle >= 0 and days_into_cycle < ninths:
		return moon_phase.new
	elif days_into_cycle >= ninths and days_into_cycle < ninths*2:
		return moon_phase.waxing_crescent
	elif days_into_cycle >= ninths*2 and days_into_cycle < ninths*3:
		return moon_phase.first_quarter
	elif days_into_cycle >= ninths*3 and days_into_cycle < ninths*4:
		return moon_phase.waxing_gibbous
	elif days_into_cycle >= ninths*4 and days_into_cycle < ninths*5:
		return moon_phase.full
	elif days_into_cycle >= ninths*5 and days_into_cycle < ninths*6:
		return moon_phase.waning_gibbous
	elif days_into_cycle >= ninths*6 and days_into_cycle < ninths*7:
		return moon_phase.third_quarter
	elif days_into_cycle >= ninths*7 and days_into_cycle < ninths*8: # Adjusting From 29.53 To Keep Accurate
		return moon_phase.waning_crescent
	elif days_into_cycle >= ninths*9 and days_into_cycle <= 29.53:
		return moon_phase.new

	# Note To Self: Please Figure Out Where Between 28.00 and 29.53 Does A Moon Actually Become A New Moon

	return moon_phase.invalid_phase

func generate_datetime(year: int = 1900, month: int = 1, day: int = 1, hour: int = 0, minute: int = 0, second: int = 0, weekday: int = 0, dst: int = -1) -> Dictionary:
	"""
		The Calendar Function That Doesn't Exist (Kinda Calendar)
	"""
	# Returns current datetime as a dictionary of keys: year, month, day, weekday, dst (daylight savings time), hour, minute, second.

	# Values Could Be Validated

	return {
		# Godot uses GMTime for UTC (all ints)
		"year": year, # Since 1900
		"month": month, # 0 - 11 (Starting From January)
		"day": day, # 1 - 31

		"hour": hour, # 0 - 23 (Starting From Midnight)
		"minute": minute, # 0 - 59
		"second": second, # 0 - 59 (Leap Second is 60)

		"weekday": weekday, # 0 - 6 (Starting From Sunday)
		"dst": dst # Positive if True, 0 if Not, Negative if Unknown
	}

func get_logged_in_user(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieve Account Name For Current System (If Supported)

		Can be Used For Meta Games
	"""
	# Didn't Find Supported System, So Returning Character's Name
	var players_name : String

	match get_system():
		host_system.OSX:
			players_name = get_logged_in_user_osx(net_id, longname)
		host_system.X11:
			players_name = get_logged_in_user_x11(net_id, longname)
		host_system.Windows:
			players_name = get_logged_in_user_windows(net_id, longname)
		host_system.UWP:
			players_name = get_logged_in_user_uwp(net_id, longname)
		host_system.android:
			players_name = get_logged_in_user_android(net_id, longname)
		host_system.iOS:
			players_name = get_logged_in_user_iOS(net_id, longname)

	if players_name.strip_edges() != functions.empty_string:
		return players_name

	if player_registrar.players[net_id].has("display_name"):
		players_name = player_registrar.players[net_id].display_name # Try to Use Display Name
	elif player_registrar.players[net_id].has("name"):
		players_name = player_registrar.players[net_id].name # If not, Use Name

	logger.warn("Couldn't Find Compatible System for Getting Logged in User's Name!!!")

	return players_name

func get_logged_in_user_osx(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieve Account Name For Current System (If Supported)

		Can be Used For Meta Games
	"""

	# Shortname - /usr/bin/logname
	# Shortname - /usr/bin/whoami (deprecated)
	# Shortname - /usr/bin/id -un
	# Longname - /usr/bin/id -F <shortname>

	var output : Array

	if longname:
		OS.execute("id", ['-un'], true, output)
		OS.execute("id", ['-F', PoolStringArray(output)[0].strip_edges()], true, output)
	else:
		OS.execute("id", ['-un'], true, output)

	return PoolStringArray(output).join(" ").strip_edges()

func get_logged_in_user_x11(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieve Account Name For Current System (If Supported)

		Not Fully Tested

		Can be Used For Meta Games
	"""

	# Shortname - /usr/bin/logname
	# Shortname - /usr/bin/whoami
	# Shortname - /usr/bin/id -un
	# Longname - /usr/bin/getent passwd | /bin/grep <shortname> | /usr/bin/cut -d: -f5 | /usr/bin/cut -d, -f1
	# Longname - /bin/cat /etc/passwd <shortname> | /usr/bin/cut -d: -f5 | /usr/bin/cut -d, -f1
	# Longname - ???

	var output : Array
	var username : String

	if longname:
		OS.execute("id", ['-un'], true, output)
		OS.execute("getent", ['passwd', PoolStringArray(output)[0].strip_edges()], true, output)

		# Sample Response From GetEnt (From RPi)
		# alex:x:1001:1001:Alexis Autumn Evelyn,,,:/home/alex:/usr/bin/zsh
		#var sample : String = "alex:x:1001:1001:Alexis Autumn Evelyn,,,:/home/alex:/usr/bin/zsh"
		username = PoolStringArray(output).join(" ").strip_edges()

		# What we want is the Gecos Field
		# The Format is Typically "Full Name, Building/Room Number or Contact Person, Office Phone, Home Phone, Other Contact Info"
		# Source: https://en.wikipedia.org/wiki/Gecos_field
		if username.split(":", true, 0).size() == 7:
			username = username.split(":", true, 0)[4].split(",", true, 0)[0]
		else:
			logger.error("Failed to Retrieve User's name!!! Does getent or id not exist?")
			username = functions.empty_string
	else:
		OS.execute("id", ['-un'], true, output)
		username = PoolStringArray(output).join(" ").strip_edges()

	return username

func get_logged_in_user_windows(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieve Account Name For Current System (If Supported)

		Untested

		Can be Used For Meta Games
	"""

	# Shortname - echo %USERNAME% - (e.g. IEUser)
	# Shortname - whoami - (Outputs group/shortname - e.g. iewin7/ieuser)
	# Longname - net user %USERNAME% | find "Full Name" - (Outputs "Full Name\t\t\t<longname>" e.g. Full Name\t\t\tAlexis Autumn Evelyn)

	# net - C:\Windows\System32\net.exe
	# whoami - C:\Windows\System32\whoami.exe
	# find - C:\Windows\System32\find.exe
	# where - C:\Windows\System32\where.exe

	return functions.empty_string

func get_logged_in_user_uwp(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieving Account Name is Not Supported For UWP Yet

		May Use ??? Account Name if Possible

		I Don't Know What Exactly UWP is. So, I Am Not Sure How To Get Username!!!
	"""

	return functions.empty_string

func get_logged_in_user_android(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieving Account Name is Not Supported For Android Yet

		May Use Google Account Name if Possible
	"""

	return functions.empty_string

func get_logged_in_user_iOS(net_id: int = -1, longname : bool = false) -> String:
	"""
		Retrieving Account Name is Not Supported For iOS Yet

		May Use Apple Account Name if Possible
	"""

	return functions.empty_string

func get_class() -> String:
	return "Functions"

# I don't have a use for this yet, so I am just leaving this here.
func _to_string() -> String:
	return "Hello"
