extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# https://godotengine.org/qa/11251/how-to-export-the-project-for-server?show=11253#a11253
	# Checks if Running on Headless Server (Currently Linux Only? There is a commit where someone added support for OSX, but no official builds)
	# I compiled Godot's Server Executable and it cannot run the server without the original source code. This could cause problems for execution speed when the binaries are not precompiled.
	# Also, OS.get_unique_id(), does not work in my Server Executable.
	# I am going to try to make the game headless compatible without using a separate Godot binary.
	print("Server Mode: ", OS.has_feature("Server"))
	
	# TODO: Save loaded theme to file that is not accessible to server
	set_theme(gamestate.game_theme) # Sets The MainMenu's Theme
	
# Sets MainMenu Theme
func set_theme(theme):
	# The set_theme(...) function can only set themes to nodes that are actively loaded (NetworkMenu is not loaded at this point)
	
	#get_tree().get_root().get_node("MainMenu/Menu/Buttons").set_theme(load("res://Themes/default_theme.tres")) # Testing Setting Theme Live - It Works, but I need Control Nodes or Other GUI nodes to set it (e.g. I cannot set it for root)
	#get_tree().get_root().get_node("MainMenu/Menu").set_theme(load(theme)) # This will set the theme for every child of "Menu", that includes the PlayerSelection popup, but not NetworkMenu.
	$Menu.set_theme(theme)
	
	# I May Add The Font To The Theme Instead (then again I may add an override for people to use custom fonts with the same theme)
	var buttons = $Menu/Buttons
	buttons.get_node("Singleplayer").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	buttons.get_node("Multiplayer").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	buttons.get_node("Options").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	buttons.get_node("Quit").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)

# Singleplayer Was Pressed
func _on_Singleplayer_pressed():
	var player_selection_menu = $Menu/PlayerSelectionMenu/PlayerSelectionWindow
	
	player_selection_menu.popup_centered()
	
# Multiplayer Was Pressed
func _on_Multiplayer_pressed():
	get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Options Was Pressed
func _on_Options_pressed():
	get_tree().change_scene("res://Menus/OptionsMenu.tscn")
	pass

# Quit Was Pressed
func _on_Quit_pressed():
	get_tree().quit() # Quits Game