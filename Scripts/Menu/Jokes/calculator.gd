extends WindowDialog
class_name Calculator

# This is a joke program meant to be an easter egg in the game.
# Don't use this to do your math homework. It can only hold the size of an int and will be inaccurate for large numbers.

# Declare member variables here. Examples:
onready var screen = $background/Screen
onready var buttons = $background/Buttons
onready var expression = Expression.new()

var calculated : bool = false # Determine if the last action was a calculation.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.window_title = tr("calculator_title")

	# Sadly I have to iterate through each and every node (I cannot just iterate through the parents).
	# Allows Attaching Calculator Button Presses to Function
	for columns in buttons.get_children():
		for rows in columns.get_children():
			for button in rows.get_children():
				button.enabled_focus_mode = Control.FOCUS_NONE # Disables Keyboard and Mouse Focus
				button.connect("pressed", self, "_button_pressed", [button]) # Connects Button to Function

	# Listens for cleanup_ui signal. Allows cleaning up on server shutdown.
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

	# Sets the Calculator's Theme
	set_theme(gamestate.game_theme)

	# Show Calculator
	popup_calc()

# Calculator Button Was Pressed
func _button_pressed(button: Node) -> void:
	#logger.verbose("Pressed: %s" % button.name)

	if button.name == "Equals":
		calculate_results()
	elif button.name == "Clear":
		clear_screen()
	elif button.name == "Multiply":
		write_to_screen("*")
	elif button.name == "Backspace":
		# Should I Add A Backspace Button?
		erase_character()
	else:
		write_to_screen(button.text)

# Handle Keyboard and Mouse Input
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
			KEY_PERIOD:
				# Untested
				write_to_screen(".")
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
	#logger.verbose("Calc Character: %s" % character)
	# Checks to See If Last Action Was Calculation and Clears Screen if True
	if calculated:
		clear_screen()
		calculated = false

	screen.add_text(character)

	# Remove Leading zeros if character pressed was not a zero.
	if character != "0":
		screen.bbcode_text = "[right]" + screen.text.lstrip("0")

# Clear Screen and Buffer
func clear_screen() -> void:
	#logger.verbose("Calc: <Clear Screen>")
	screen.clear()
	screen.bbcode_text = "[right]0" # This uses "corrupted" bbcode on purpose (so I don't waste processing time constantly adding [/right] to the end of a number and erasing all the old end tags.)

# Erases Character From Right Side of Screen
func erase_character() -> void:
	#logger.verbose("Calc: <Erase Character>")
	if calculated:
		calculated = false
		clear_screen()
		return

	screen.bbcode_text = "[right]" + screen.text.substr(0, screen.text.length()-1)

# Calculate Results
func calculate_results() -> void:
	#logger.verbose("Calculating...")
	#logger.verbose("Formula: %s" % screen.text)

	# How to deal with Integer Divison? Modulus only Works With Integers (otherwise a parse error).
	# Symbols to Look For (, ), %, /, *, +, -

	if calculated:
		calculated = false
		clear_screen()

	# https://docs.godotengine.org/en/3.1/classes/class_expression.html#description
	# Using expressions allows handling code without crashing the game because of errors (like syntax errors).
	var error = expression.parse(screen.text, [])

	if error != OK:
		#logger.verbose("Calc Expression Error: %s" % expression.get_error_text())
		return

	var result = expression.execute([], null, false) # Setting show_error to false keeps the parser from complaining about dividing by 0.
	if not expression.has_execute_failed():
		screen.bbcode_text = "[right]" + str(result)
		#calculated = true
	else:
		screen.bbcode_text = "[right]" + tr("calc_cannot_divide_zero")
		calculated = true

# Close Calculator
func close_calculator() -> void:
	#logger.verbose("Focus Owner: %s" % get_focus_owner())
	#logger.verbose("Is Child: %s" % self.is_a_parent_of(get_focus_owner()))
	if get_focus_owner() != null: # Prevents p_node is null error when not on any node.
		# Checks If Window or Children of Window Has Focus
		if has_focus() or is_a_parent_of(get_focus_owner()):
			cleanup()

# Do Something Immediately Before Calc Shows
func _about_to_show() -> void:
	pass # Replace with function body.

# Detect When X Button is Pressed on Calculator
func _calc_hide() -> void:
	close_calculator()

# Show Calculator Window
func popup_calc() -> void:
	#get_tree().set_input_as_handled()

	#logger.verbose("Calc Get Rect: %s" % self.get_rect().size)

#	var calc_x : float = (ProjectSettings.get_setting("display/window/size/width")/2) - (self.get_rect().size.x/2)
#	var calc_y : float = (ProjectSettings.get_setting("display/window/size/height")/2) - (self.get_rect().size.x/2)

	var calc_x : float = (get_tree().get_root().size.x/2) - (self.get_rect().size.x/2)
	var calc_y : float = (get_tree().get_root().size.y/2) - (self.get_rect().size.x/2)

	self.set_position(Vector2(calc_x, calc_y))
	self.call_deferred("show")

# Sets Calculator's Theme
func set_theme(theme: Theme) -> void:
	# https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	.set_theme(theme) # This is Godot's version of a super

# Cleanup Calculator and Free Itself From Memory
func cleanup():
	#logger.verbose("Close Calculator...")
	self.hide() # Hides Calculator Window
	get_parent().queue_free() # Frees Calculator From Memory

func get_class() -> String:
	return "Calculator"
