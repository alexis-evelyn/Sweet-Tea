extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().set_auto_accept_quit(false) # Disables Default Quit Action - Allows Override to Handle Other Code (e.g. saving or in a meta horror game, play a creepy voice)
	get_tree().connect("files_dropped", self, "_drop_files")
	#get_tree().connect("tree_changed", self, "_tree_changed")

# Called When MainLoop Event Happens
func _notification(what: int) -> void:
	# This isn't an override of the normal behavior, it just allows listening for the events and doing something based on the event happening.
	
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			# This will run no matter if autoquit is on. Disabling autoquit just means that I can quit when needed (so I don't get interrupted, say if I am saving data).
			quit()
		MainLoop.NOTIFICATION_CRASH:
			# When I Was Rewriting the Save Player function, I crashed the game.
			# This print statement was added to stdout, so I know it works.
			# What I can do is save debug info to the hard drive and next time the user loads the game, I can request them to send the info to me.
			logger.trace("Game Is About to Crash!!!")
			quit(397) # Sets Exit Code to 397 to indicate to script game has crashed. I may add more codes and an enum to identify what type of crash it is (if it is something unavoidable, like the system is broken, etc...)
		MainLoop.NOTIFICATION_WM_ABOUT:
			logger.verbose("Specific to Mac!!! Pull up about Game info (button will be on MainMenu too)")
		_: # Default Result - Put at Bottom of Match Results
			pass

# This is supposed to be called last right before the game quits, but that doesn't work (maybe it can only do it in a custom MainLoop?).
# https://docs.godotengine.org/en/3.1/classes/class_mainloop.html#class-mainloop-method-finalize
func _finalize():
	logger.info("Goodbye!!!")

# Detect When Files Dropped onto Game (Requires Signal) - Can Work in Any Node
func _drop_files(files: PoolStringArray, from_screen: int):
	# In the right node, this can be used to add mods or add files to a virtual computer (like with Minecraft's ComputerCraft Mod)
	logger.debug("Files Dragged From Screen Number %s: %s" % [from_screen, files])

# Useful when trying to figure out where game froze at. Too bad it doesn't list what part of the tree changed.
func _tree_changed():
	logger.verbose("SceneTree Changed")

# Performs Cleanup When Quitting Game
func quit(error: int = 0):
	OS.set_exit_code(error) # Sets the Exit Code The Game Will Quit With (can be checked with "echo $?" after executing game from shell)
	
	logger.verbose("Quit Game!!!")
	get_tree().quit()
