extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false) # Disables Default Quit Action - Allows Override to Handle Other Code (e.g. saving or in a meta horror game, play a creepy voice)

# Called When MainLoop Event Happens
func _notification(what):
	# This isn't an override of the normal behavior, it just allows listening for the events and doing something based on the event happening.
	
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			# This will run no matter if autoquit is on. Disabling autoquit just means that I can quit when needed (so I don't get interrupted, say if I am saving data).
			print("Quit Game!!!")
			get_tree().quit()
		MainLoop.NOTIFICATION_CRASH:
			print("Game Is About to Crash!!!")
		MainLoop.NOTIFICATION_WM_ABOUT:
			print("Specific to Mac!!! Pull up about Game info (button will be on MainMenu too)")
		_: # Default Result - Put at Bottom of Match Results
			pass