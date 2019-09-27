extends WindowDialog
class_name Mazawalza_Dictionary

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.window_title = tr("dictionary_title")

#	# Sadly I have to iterate through each and every node (I cannot just iterate through the parents).
#	# Allows Attaching Calculator Button Presses to Function
#	for columns in buttons.get_children():
#		for rows in columns.get_children():
#			for button in rows.get_children():
#				button.enabled_focus_mode = Control.FOCUS_NONE # Disables Keyboard and Mouse Focus
#				button.connect("pressed", self, "_button_pressed", [button]) # Connects Button to Function

	# Listens for cleanup_ui signal. Allows cleaning up on server shutdown.
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

	# Sets the Dictionary's Theme
	set_theme(gamestate.game_theme)

	# Show Dictionary
	popup_dictionary()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Show Dictionary Window
func popup_dictionary() -> void:
	#get_tree().set_input_as_handled()

	var dict_x : float = (get_tree().get_root().size.x/2) - (self.get_rect().size.x/2)
	var dict_y : float = (get_tree().get_root().size.y/2) - (self.get_rect().size.x/2)

	self.set_position(Vector2(dict_x, dict_y))
	self.call_deferred("show")

# Sets Dictionary's Theme
func set_theme(theme: Theme) -> void:
	# https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	.set_theme(theme) # This is Godot's version of a super

# Cleanup Dictionary and Free Itself From Memory
func cleanup():
	#logger.verbose("Close Dictionary...")
	self.hide() # Hides Dictionary Window
	get_parent().queue_free() # Frees Dictionary From Memory

func get_class() -> String:
	return "Mazawalza_Dictionary"
