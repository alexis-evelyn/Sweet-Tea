extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
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