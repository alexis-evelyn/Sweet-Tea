extends Node
class_name Functions

enum attention_reason {
	private_message = 0
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

# get_class() - https://godotengine.org/qa/46057/how-to-get-the-class-name-of-a-custom-node?show=46059#a46059

# Declare member variables here. Examples:
var current_title : String = ""
var screenshot : Image # Variable To Hold Screenshot

# I may replace the default window title bar with my own. - https://www.youtube.com/watch?v=alKdkRJy-iY&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r&index=4&t=0s
func set_title(title: String):
	current_title = title
	OS.set_window_title(title) # Sets Window's Title

# Gets Title of Window
func get_title() -> String:
	# There is no builtin way to get the window title, so I have to store it in a variable. - https://github.com/godotengine/godot/issues/27536
	return current_title

sync func request_attention(reason: int) -> void:
	# Use the reason combined with notification settings to determine if attention should be requested
	OS.request_attention()
	logger.superverbose("Requesting User Attention - Reason: %s" % reason)

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
		return ""

	if file.eof_reached():
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is empty!!!" % [locale, key, translations_file])
		file.close()
		return ""

	var index : int = -1 # Column that Locale Is On
	var line : Array = Array(file.get_csv_line()) # Get first line of csv file

	# If it does not have the locale requested, then just return
	if not line.has(locale):
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is does not have the locale!!!" % [locale, key, translations_file])
		file.close()
		return ""

	index = line.find(locale) # Get column the locale is on

	while !file.eof_reached():
		line = Array(file.get_csv_line())

		if line[0] == key:
			#logger.verbose("Translation: %s" % line[index])
			file.close()
			return line[index]

	logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' does not have the key!!!" % [locale, key, translations_file])
	file.close()
	return "" # If it does not have the key, then just return

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
		return "No Translation File Found For Locale '%s'" % locale

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


func get_world_camera() -> ColorRect:
	var shader_screen : ColorRect
	var player : Node2D = spawn_handler.get_player_body_node(gamestate.net_id)

	if player == null:
		return null

	if player.has_node("PlayerCamera"):
		shader_screen = player.get_node("PlayerCamera").get_node("ShaderRectangle")
	else:
		if not gamestate.player_info.has("current_world"):
			logger.error("Set World Shader - Missing Current World Info")
			return null

		var world : ViewportContainer = spawn_handler.get_world_node(gamestate.player_info.current_world)

		if not world.get_node("Viewport").has_node("DebugCamera"):
			logger.error("Set World Shader - Missing Debug Camera")
			return null

		shader_screen = world.get_node("Viewport").get_node("DebugCamera").get_node("ShaderRectangle")

	return shader_screen

func set_world_shader(shader: Shader) -> bool:
	var shader_screen : ColorRect = get_world_camera()

	if shader_screen == null:
		logger.error("Set World Shader - Failed to Get Shader Rectangle for Shader: %s" % shader.resource_path)
		return false

	var shader_material : ShaderMaterial = ShaderMaterial.new()
	shader_material.set_shader(shader)

	shader_screen.set_material(shader_material)
	shader_screen.visible = true

	return true

func set_world_shader_param(param: String, value) -> bool:
	var shader_screen : ColorRect = get_world_camera()

	if shader_screen == null:
		logger.error("Set World Shader Param - Failed to Get Shader Rectangle for Shader")
		return false

	var shader_material : ShaderMaterial = shader_screen.get_material()

	if shader_material == null:
		logger.error("Set World Shader Param - Failed to Get Shader Material for Shader")
		return false

	shader_material.set_shader_param(param, value)

	return true

func remove_world_shader() -> bool:
	var shader_screen : ColorRect = get_world_camera()

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
	if not get_tree().get_root().get_node("PlayerUI").has_node("Screen Shader"):
		logger.error("Set World Shader Param - Failed to Get Shader Rectangle for Shader: %s" % shader.resource_path)
		return false

	var shader_screen : ColorRect = get_tree().get_root().get_node("PlayerUI").get_node("Screen Shader")

	var shader_material : ShaderMaterial = ShaderMaterial.new()
	shader_material.set_shader(shader)

	shader_screen.set_material(shader_material)
	shader_screen.visible = true

	return true

func set_global_shader_param(param: String, value) -> bool:
	if not get_tree().get_root().get_node("PlayerUI").has_node("Screen Shader"):
		logger.error("Set Global Shader Param - Failed to Get Shader Rectangle for Shader")
		return false

	var shader_screen : ColorRect = get_tree().get_root().get_node("PlayerUI").get_node("Screen Shader")

	var shader_material : ShaderMaterial = shader_screen.get_material()

	if shader_material == null:
		logger.error("Set Global Shader Param - Failed to Get Shader Material for Shader")
		return false

	shader_material.set_shader_param(param, value)

	return true

func remove_global_shader() -> bool:
#	if not get_tree().get_root().get_node("PlayerUI").has_node("Screen Shader"):
#		return true

	var shader_screen : ColorRect = get_tree().get_root().get_node("PlayerUI").get_node("Screen Shader")

	if shader_screen.get_material() == null:
		return true

	var shader_material : ShaderMaterial = shader_screen.get_material()
	shader_material.set_shader(null)

	shader_screen.set_material(null)
	shader_screen.visible = false

	return true

# Example Shader Rectangle Creation Code
#func create_global_shader_rect() -> void:
#	if get_tree().get_root().get_node("PlayerUI").has_node("Screen Shader"):
#		return
#
#	var shader_screen : ColorRect = ColorRect.new()
#	shader_screen.rect_position = Vector2(0, 0)
#	shader_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
#	shader_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	shader_screen.name = "Screen Shader"
#
#	get_tree().get_root().get_node("PlayerUI").add_child(shader_screen)

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
	var joined_chars : String = ""
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
		panelChat.autosend_command("/shader animated_rainbow")
	elif command_id == "1":
		# For Testing is Assigned R3
		panelChat.autosend_command("/shader remove")

# Meant to Be Assigned to Joypad Axes
func run_axes_command(panelChat: ChatPanel, command_id: String = "0") -> void:
	pass

func get_class() -> String:
	return "Functions"

# I don't have a use for this yet, so I am just leaving this here.
func _to_string() -> String:
	return "Hello"
