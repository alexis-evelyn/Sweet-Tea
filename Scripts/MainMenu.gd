extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var buttons = $Menu/Buttons
	buttons.get_node("Singleplayer").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	buttons.get_node("Multiplayer").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	buttons.get_node("Options").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)
	buttons.get_node("Quit").add_font_override("font", load("res://Fonts/dynamicfont/firacode-regular.tres")) # TODO: Fonts will be able to be chosen by player (including custom fonts added by player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Singleplayer Was Pressed
func _on_Singleplayer_pressed():
	get_tree().change_scene("res://Menus/SinglePlayerMenu.tscn")

# Multiplayer Was Pressed
func _on_Multiplayer_pressed():
	get_tree().change_scene("res://Menus/NetworkMenu.tscn")

# Options Was Pressed
func _on_Options_pressed():
	get_tree().change_scene("res://Menus/OptionsMenu.tscn")

# Quit Was Pressed
func _on_Quit_pressed():
	get_tree().quit() # Quits Game
