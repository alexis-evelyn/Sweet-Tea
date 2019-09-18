extends Node
class_name Functions

enum attention_reason {
	private_message = 0
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
	var selected_translation : PoolStringArray

	for translation in translations:
		#res://Assets/Languages/default.pr.translation
		var translation_locale : String = translation.rsplit(".", false, 2)[1]
		#logger.verbose"Translation File: %s" % translation_locale)

		if translation_locale == locale:
			selected_translation.append(translation)

	# If No Translation File Found, Then Just Return. This will crash on debug builds, but not release builds.
	if selected_translation.size() == 0:
		logger.error("No Translation File Found For Locale '%s'" % locale)
		return "No Translation File Found For Locale '%s'" % locale

	var translator : Translation = load(selected_translation[0]) # I may add support for searching more than one file of the same locale later.
	var message = translator.get_message(key)

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
			translation_names.locales.append({"locale": translation_locale, "name": TranslationServer.get_locale_name(translation_locale), "native_name": get_translation("language_name", translation_locale)})

#			logger.superverbose("Native Language Name: %s" % get_translation("language_name", translation_locale))
#			logger.superverbose("Translation: %s/%s" % [translation_locale, TranslationServer.get_locale_name(translation_locale)])

#	print("Translation Dictionary: %s" % translation_names)
	return translation_names


func get_world_camera() -> ColorRect:
	var shader_screen : ColorRect
	var player : Node = spawn_handler.get_player_node(gamestate.net_id)

	if player == null:
		return null

	if player.get_node("KinematicBody2D").has_node("PlayerCamera"):
		shader_screen = player.get_node("KinematicBody2D").get_node("PlayerCamera").get_node("ShaderRectangle")
	else:
		if not gamestate.player_info.has("current_world"):
			logger.error("Set World Shader - Missing Current World Info")
			return null

		var world : Node = spawn_handler.get_world_node(gamestate.player_info.current_world)

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

#	yield(get_tree(), "idle_frame")
	# Thread this?

	return screenshot

func get_class() -> String:
	return "Functions"

# I don't have a use for this yet, so I am just leaving this here.
func _to_string() -> String:
	return "Hello"
