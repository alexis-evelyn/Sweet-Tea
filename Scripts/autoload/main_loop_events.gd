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
			
			var crash_directory : String = OS.get_user_data_dir().plus_file("crash-reports")
			var crash_dir_handler : Directory = Directory.new()
			var crash_system_stats : File = File.new()
			var time : String = str(OS.get_unix_time())
			
			# Create's Crash Directory If It Does Not Exist
			if not crash_dir_handler.dir_exists(crash_directory): # Check If Crash Logs Folder Exists
				logger.verbose("Creating Crash Logs Folder!!!")
				crash_dir_handler.make_dir(crash_directory)
			
			OS.dump_memory_to_file(crash_directory.plus_file("crash-%s.mem" % time))
			OS.dump_resources_to_file(crash_directory.plus_file("crash-%s.list" % time))
			
			crash_system_stats.open(crash_directory.plus_file("crash-system-stats-%s.log" % time), File.WRITE)
			
			crash_system_stats.store_string("This Log File Is Related (Please Send it Too): %s\n" % logger.log_file_path)
			crash_system_stats.store_string("Command Line Arguments: %s\n" % OS.get_cmdline_args())
			crash_system_stats.store_string("OS Model Name: %s\n" % OS.get_model_name())
			crash_system_stats.store_string("Game Memory Usage: %s/%s\n" % [OS.get_static_memory_usage(), OS.get_static_memory_peak_usage()])
			crash_system_stats.store_string("OS Unique ID: %s\n" % OS.get_unique_id()) # Helps Identify Related Crashes To The Same System - Especially Since Another Program or Driver Could Be The Culprit
			
			crash_system_stats.store_string("Debug Build: %s\n" % OS.is_debug_build())
			crash_system_stats.store_string("Debug Mode: %s\n" % gamestate.debug)
			
			crash_system_stats.store_string("Stack Trace (Currently Not Available For Release Builds): %s\n" % get_stack())
			crash_system_stats.store_string("SceneTree: %s\n" % print_tree_pretty()) # It appears print_tree...() only prints to stdout, so I may not be able to capture it for logging
			
			crash_system_stats.close()
			
			#yield(...) - Alert User of Crash With Dialog and Tell Them To Copy Related Files
			
			quit(397) # Sets Exit Code to 397 to indicate to script game has crashed. I may add more codes and an enum to identify what type of crash it is (if it is something unavoidable, like the system is broken, etc...)
		MainLoop.NOTIFICATION_WM_ABOUT:
			about_game()
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
	
	logger.info("Quit Game!!!")
	get_tree().quit()

# Display Information About Game
func about_game():
	OS.alert("Made by Alex Evelyn", "About Sweet Tea")
