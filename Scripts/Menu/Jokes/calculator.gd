extends WindowDialog

# This is a joke program meant to be an easter egg in the game.

# Declare member variables here. Examples:
onready var screen = $Screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders
	
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
	
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_0:
				if event.shift:
					# Doesn't have its own scancode on a standard keyboard
					write_to_screen(")")
					return
				
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
				if event.shift:
					# Doesn't have its own scancode on a standard keyboard
					write_to_screen("%")
					return
				
				write_to_screen("5")
				return
			KEY_6:
				write_to_screen("6")
				return
			KEY_7:
				write_to_screen("7")
				return
			KEY_8:
				if event.shift:
					# Doesn't have its own scancode on a standard keyboard
					write_to_screen("*")
					return
				
				write_to_screen("8")	
				return
			KEY_9:
				if event.shift:
					# Doesn't have its own scancode on a standard keyboard
					write_to_screen("(")
					return
				
				write_to_screen("9")
				return
			KEY_ENTER:
				calculate_results()
				return
			KEY_C:
				clear_screen()
				return
			# Handle Non-Numeric Keys
			KEY_BACKSPACE:
				erase_character()
				return
			KEY_ESCAPE:
				close_calculator()
				return
			KEY_ASTERISK:
				# Untested
				write_to_screen("*")
				return
			KEY_SLASH:
				write_to_screen("/")
				return
			KEY_PLUS:
				# Untested
				write_to_screen("+")
				return
			KEY_MINUS:
				write_to_screen("-")
				return
			KEY_PERCENT:
				# Untested
				write_to_screen("%")
				return
			KEY_PARENLEFT:
				# Untested
				write_to_screen("(")
				return
			KEY_PARENRIGHT:
				# Untested
				write_to_screen(")")
				return
			KEY_EQUAL:
				if event.shift:
					write_to_screen("+")
					return
				
				calculate_results()
				return
			_: # Default Result - Put at Bottom of Match Results
				#write_to_screen(OS.get_scancode_string(event.scancode))
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
	#print("Formula: ", screen.text)
	
	# https://godotengine.org/qa/339/does-gdscript-have-method-to-execute-string-code-exec-python?show=362#a362
	# Not exactly safe, but we are only taking in input from user.
	var math_eval = GDScript.new()
	math_eval.set_source_code("func calc():\n\treturn " + screen.text)
	math_eval.reload()
	
	var math = Reference.new()
	math.set_script(math_eval)
	
	#print(math.calc())
	
	screen.bbcode_text = "[right]" + str(math.calc())
	pass # Replace with function body.

# Close Calculator
func close_calculator() -> void:
	#print("Focus Owner: ", get_focus_owner())
	#print("Is Child: ", self.is_a_parent_of(get_focus_owner()))
	if get_focus_owner() != null: # Prevents p_node is null error when not on any node.
		# Checks If Window or Children of Window Has Focus
		if has_focus() or is_a_parent_of(get_focus_owner()):
			cleanup()

# Do Something Immediately Before Calc Shows
func _about_to_show() -> void:
	pass # Replace with function body.

# Show Calculator Window
func popup_calc() -> void:
	self.call_deferred("show")

func set_theme(theme: Theme) -> void:
	# https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	.set_theme(theme) # This is Godot's version of a super

# Cleanup Calculator and Free Itself From Memory
func cleanup():
	#print("Close Calculator...")
	self.hide() # Hides Calculator Window
	get_parent().queue_free() # Frees Calculator From Memory
