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

#onready var buttons : VBoxContainer = $Menu/Buttons

onready var singleplayer_button : Button = $Menu/Buttons/Singleplayer
#onready var multiplayer_button : Button = $Menu/Buttons/Multiplayer
#onready var options_button : Button = $Menu/Buttons/Options
#onready var quit_button : Button = $Menu/Buttons/Quit

#var ui_select_group_name : String = "Main Menu UI Select"
#onready var ui_select_group : ButtonGroup = get_tree().get_nodes_in_group(ui_select_group_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	functions.set_title(tr("main_menu_title"))

	set_language_text() # Make Main Menu Text Multi-Language Friendly
	# TODO: Save loaded theme to file that is not accessible to server
	set_theme(gamestate.game_theme) # Sets The MainMenu's Theme

	# The reason I keep these settings here is because it prevents the splash screen from loading
	OS.set_borderless_window(settings.window_borderless)
	OS.set_window_resizable(settings.window_resizable)

	singleplayer_button.grab_focus() # Make Singleplayer Button Grab Focus

	emit_signal("script_setup") # Let mods know MainMenu is finished loading

#	functions.set_global_shader(load("res://Scripts/Shaders/third_party/Official Godot Shaders/sepia.shader"))
#	functions.set_global_shader_param("base", Color.crimson)

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

#func _input(event: InputEvent) -> void:
##	get_tree().get_nodes_in_group(ui_select_group_name) # Get Nodes of Group
##	get_tree().call_group(ui_select_group_name, "my_function") # Call Function on All Nodes of Group
#
#	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
#		print("Grab Focus Next")
#
#		if singleplayer_button.has_focus():
#			multiplayer_button.grab_focus()
#			get_tree().set_input_as_handled()
#		elif multiplayer_button.has_focus():
#			options_button.grab_focus()
#			get_tree().set_input_as_handled()
#		elif options_button.has_focus():
#			quit_button.grab_focus()
#			get_tree().set_input_as_handled()
#		elif quit_button.has_focus():
#			singleplayer_button.grab_focus()
#			get_tree().set_input_as_handled()
#		else:
#			singleplayer_button.grab_focus()
#			get_tree().set_input_as_handled()
#
#	elif event.is_action_pressed("ui_focus_prev") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
#		print("Grab Focus Previous")
#
#		if singleplayer_button.has_focus():
#			quit_button.grab_focus()
#			get_tree().set_input_as_handled()
#		elif multiplayer_button.has_focus():
#			singleplayer_button.grab_focus()
#			get_tree().set_input_as_handled()
#		elif options_button.has_focus():
#			multiplayer_button.grab_focus()
#			get_tree().set_input_as_handled()
#		elif quit_button.has_focus():
#			options_button.grab_focus()
#			get_tree().set_input_as_handled()
#		else:
#			quit_button.grab_focus()
#			get_tree().set_input_as_handled()


func get_class() -> String:
	return "MainMenu"
