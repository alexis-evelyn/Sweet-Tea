extends WindowDialog

# Declare member variables here. Examples:
onready var screen = $Screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets the Calculator's Theme
	set_theme(gamestate.game_theme)
	
	popup_calc()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta) -> void:
#	pass
			
func _input(event) -> void:
	if event is InputEventMouseButton:
		set_focus_mode(Control.FOCUS_ALL)
	
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_0:
					write_to_screen("0")
					return
				KEY_1:
					write_to_screen("1")
					return
				KEY_2:
					write_to_screen("2")
					return
				KEY_3:
					write_to_screen("3")
					return
				KEY_4:
					write_to_screen("4")
					return
				KEY_5:
					write_to_screen("5")
					return
				KEY_6:
					write_to_screen("6")
					return
				KEY_7:
					write_to_screen("7")
					return
				KEY_8:
					write_to_screen("8")
					return
				KEY_9:
					write_to_screen("9")
					return
				KEY_ASTERISK:
					write_to_screen("*")
					return
				KEY_DIVISION:
					write_to_screen("/")
					return
				KEY_PLUS:
					write_to_screen("+")
					return
				KEY_MINUS:
					write_to_screen("-")
					return
				KEY_PERCENT:
					write_to_screen("%")
					return
				KEY_ENTER:
					calculate_results()
					return
				KEY_C:
					clear_screen()
					return
				KEY_BACKSPACE:
					erase_character()
					return
				KEY_ESCAPE:
					close_calculator()
					return
				_: # Default Result - Put at Bottom of Match Results
					pass

# Write to Calculator Screen
func write_to_screen(character: String) -> void:
	#print(character)
	screen.add_text(character)
	
	# Remove Leading zeros if character pressed was not a zero.
	if character != "0":
		screen.bbcode_text = "[right]" + screen.text.lstrip("0")

# Clear Screen and Buffer
func clear_screen() -> void:
	#print("<Clear Screen>")
	screen.clear()
	screen.bbcode_text = "[right]0" # This uses "corrupted" bbcode on purpose (so I don't waste processing time constantly adding [/right] to the end of a number and erasing all the old end tags.)

# Erases Character From Right Side of Screen
func erase_character() -> void:
	#print("<Erase Character>")
	screen.bbcode_text = "[right]" + screen.text.substr(0, screen.text.length()-1)

# Calculate Results
func calculate_results() -> void:
	print("Calculating...")
	pass # Replace with function body.

# Close Calculator
func close_calculator() -> void:
	#print("Focus Owner: ", get_focus_owner())
	#print("Is Child: ", self.is_a_parent_of(get_focus_owner()))
	if get_focus_owner() != null: # Prevents p_node is null error when not on any node.
		# Checks If Window or Children of Window Has Focus
		if has_focus() or is_a_parent_of(get_focus_owner()):
			#print("Close Calculator...")
			self.hide() # Hides Calculator Window
			self.queue_free() # Frees Calculator From Memory

# Do Something Immediately Before Calc Shows
func _about_to_show() -> void:
	pass # Replace with function body.

# Show Calculator Window
func popup_calc() -> void:
	self.call_deferred("show")

func set_theme(theme: Theme) -> void:
	# https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	.set_theme(theme) # This is Godot's version of a super
