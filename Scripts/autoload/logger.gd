extends Node

# This logger exists so that I can log to file (with varying log verbosities) and if I figure out how to implement system logging,
# then I will be logging to the system log too. This is very useful for the crash handler (especially when the game is in alpha stage).

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func debug(statement: String = ""):
	print(statement)

func info(statement: String = ""):
	print(statement)
	
func verbose(statement: String = ""):
	print(statement)
	
func warn(statement: String = ""):
	printerr("Warning: %s" % statement)
	
func error(statement: String = ""):
	printerr("Error: %s" % statement)
	
func fatal(statement: String = ""):
	printerr("Fatal: %s" % statement)
	
func trace(statement: String = ""):
	printerr("If trace does not show up, it means Godot still doesn't support stacktraces in exported games. Try breaking the game in the Godot editor (you will need the source code at https://github.com/alex-evelyn/Sweet-Tea)")
	printerr("Error: '%s' Trace: '%s'" % [statement, get_stack()])
