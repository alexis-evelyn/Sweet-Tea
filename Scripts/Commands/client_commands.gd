extends Node

func process_commands(message: PoolStringArray) -> String:
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)

	match command:
		"calc":
			return open_calculator(message)
		_:
			return ""
			
# warning-ignore:unused_argument
func open_calculator(message: PoolStringArray) -> String:
	if not get_tree().get_root().has_node("Calculator"):
		var calc : Node = load("res://Menus/Jokes/Calculator.tscn").instance()
		calc.name = "Calculator"
		
		get_tree().get_root().add_child(calc)
	
	return "Opening Calculator..."
