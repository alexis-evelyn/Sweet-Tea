extends Control
class_name MainMenu

signal script_setup # Used to let mods know MainMenu has finished loading

# Super Efficiency
# How To Improve Efficiency - https://www.reddit.com/r/godot/comments/cyvbzh/how_to_make_my_godot_game_use_less_cpu/eyufv78/
# C++ vs C# - https://stackoverflow.com/a/2203124/6828099
# GDScript or C++ - https://godotengine.org/qa/8800/can-i-write-a-full-game-with-just-c-or-is-gdscript-necessary?show=8806#c8806

# README (IMPORTANT):
# I plan on rewriting the cpu intensive scripts with c++ to greatly improve efficiency.
# I am also getting close to the point where I want to start asking for donations (e.g. Kickstarter),
# so I am going to need to make a Gantt chart and setup a unabridged list of planned features.
# I am also going to figure out how to multithread world loading so I can have a loading screen.

# Interesting Links
# https://docs.godotengine.org/en/3.1/getting_started/step_by_step/scripting_continued.html#overrideable-functions
# https://docs.godotengine.org/en/latest/classes/class_projectsettings.html
# Youtube Channel to help with development and marketing (Ask Gamedev) - https://www.youtube.com/channel/UCd_lJ4zSp9wZDNyeKCWUstg

# Performance Improving Links
# https://docs.godotengine.org/en/3.1/classes/class_engine.html#class-engine-property-iterations-per-second
# https://godotengine.org/article/why-does-godot-use-servers-and-rids - About Multi-Cores and Threading
# https://docs.godotengine.org/en/3.1/tutorials/threads/using_multiple_threads.html - Multithreading

# Quick Read
# Multithreading Efficiency - https://github.com/godotengine/godot/issues/7832

# Interesting Console Output Ideas
# OSX - syslog -s -l error "message to send"
# Linux (May Need Root) - echo MESSAGE > /dev/kmsg
# BSD - logger -p kern.crit MESSAGE
# Windows - https://stackoverflow.com/a/27640623/6828099
# Android - https://stackoverflow.com/a/2364842/6828099
# IOS - https://stackoverflow.com/a/9097503/6828099

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	functions.set_title(tr("main_menu_title"))

	set_language_text() # Make Main Menu Text Multi-Language Friendly
	# TODO: Save loaded theme to file that is not accessible to server
	set_theme(gamestate.game_theme) # Sets The MainMenu's Theme

	# The reason I keep these settings here is because it prevents the splash screen from loading
	OS.set_borderless_window(settings.window_borderless)
	OS.set_window_resizable(settings.window_resizable)

	emit_signal("script_setup") # Let mods know MainMenu is finished loading

	load_screen_shader()

func load_screen_shader() -> void:
	if get_tree().get_root().get_node("PlayerUI").has_node("Screen Shader"):
		return

#	var shader : Shader = load("res://Scripts/Shaders/grayscale.shader")
	var shader : Shader = load("res://Scripts/Shaders/fabric_of_time.shader")

	var shader_screen : ColorRect = ColorRect.new()
	shader_screen.rect_position = Vector2(0, 0)
	shader_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	shader_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shader_screen.name = "Screen Shader"

	var shader_material : ShaderMaterial = ShaderMaterial.new()
	shader_material.set_shader(shader)

	shader_screen.set_material(shader_material)
	get_tree().get_root().get_node("PlayerUI").add_child(shader_screen)

func set_theme(theme: Theme) -> void:
	"""
		Sets Up Main Menu's Theme

		Supply Theme Resource
	"""

	.set_theme(theme) # Godot's Version of a super - https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance

	# The set_theme(...) function can only set themes to nodes that are actively loaded (NetworkMenu is not loaded at this point)

	#get_tree().get_root().get_node("MainMenu/Menu/Buttons").set_theme(load("res://Assets/Themes/default_theme.tres")) # Testing Setting Theme Live - It Works, but I need Control Nodes or Other GUI nodes to set it (e.g. I cannot set it for root)
	#get_tree().get_root().get_node("MainMenu/Menu").set_theme(load(theme)) # This will set the theme for every child of "Menu", that includes the PlayerSelection popup, but not NetworkMenu.
#	$Menu.set_theme(theme)

	# I May Add The Font To The Theme Instead (then again I may add an override for people to use custom fonts with the same theme)
#	var buttons : Node = $Menu/Buttons
	# TODO: The font does not need to be loaded more than once.
#	buttons.get_node("Singleplayer").add_font_override("font", load("res://Assets/Fonts/dynamicfont/treasure-map-deadhand-regular.tres"))
#	buttons.get_node("Multiplayer").add_font_override("font", load("res://Assets/Fonts/dynamicfont/firacode-regular.tres"))
#	buttons.get_node("Options").add_font_override("font", load("res://Assets/Fonts/dynamicfont/firacode-regular.tres"))
#	buttons.get_node("Quit").add_font_override("font", load("res://Assets/Fonts/dynamicfont/firacode-regular.tres"))

func set_language_text() -> void:
	var buttons : Node = $Menu/Buttons

	buttons.get_node("Singleplayer").text = tr("singleplayer_button")
	buttons.get_node("Multiplayer").text = tr("multiplayer_button")
	buttons.get_node("Options").text = tr("options_button")
	buttons.get_node("Quit").text = tr("quit_button")

func _on_Singleplayer_pressed() -> void:
	"""
		Pull Up Player Selection Menu

		Not Meant to Be Called Directly
	"""

	var player_selection_menu : Node = $Menu/PlayerSelectionMenu
	var player_selection_window : Node = player_selection_menu.get_node("PlayerSelectionWindow")
	player_selection_menu.set_menu("") # Set's menu to load after selecting player
	player_selection_window.popup_centered()

func _on_Multiplayer_pressed() -> void:
	"""
		Pull Up Networking Menu

		Not Meant to Be Called Directly
	"""

	var player_selection_menu : Node = $Menu/PlayerSelectionMenu
	var player_selection_window : Node = player_selection_menu.get_node("PlayerSelectionWindow")
	player_selection_menu.set_menu("res://Menus/NetworkMenu.tscn") # Set's menu to load after selecting player
	player_selection_window.popup_centered()

func _on_Options_pressed() -> void:
	"""
		Pull Up Options Menu

		Not Meant to Be Called Directly
	"""

	get_tree().change_scene("res://Menus/OptionsMenu.tscn")
	pass

func _on_Quit_pressed() -> void:
	"""
		Quit Game from Main Menu

		Not Meant to Be Called Directly
	"""

	main_loop_events.quit() # Quits Game

func get_class() -> String:
	return "MainMenu"
