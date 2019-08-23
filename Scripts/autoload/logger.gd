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
	printerr(statement)
	
func error(statement: String = ""):
	printerr(statement)
	
func fatal(statement: String = ""):
	printerr(statement)
	
func trace(statement: String = ""):
	printerr(statement)
