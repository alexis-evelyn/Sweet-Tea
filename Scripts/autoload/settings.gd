extends Node

# Used to load settings from options menu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	logger.create_log()
	
	#TranslationServer.set_locale("pr")
	logger.debug("Locale: %s" % TranslationServer.get_locale())
	logger.debug("Name: %s" % TranslationServer.get_locale_name(TranslationServer.get_locale()))
	
	gamestate.player_info.language = TranslationServer.get_locale() # Saves Current Language to Player Info (Player Info is Used By Game and Servers)
	
	#OS.window_fullscreen = true # Allows Enabling Full Screen
	#OS.set_window_size(Vector2(640, 480)) # Sets Window's Size
	logger.verbose("Window Size: %s" % OS.get_window_size()) # Get's Window Size Including Titlebar
	#logger.verbose("Real Window Size: %s" % OS.get_real_window_size()) # Gets Window's Size Minus Titlebar
	#logger.verbose("Screen Size: %s" % OS.get_screen_size()) # Gets Screen Size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func check_settings():
	#logger.verbose("MainLoop: %s" % Engine.get_main_loop().get_class()) # Prints Current MainLoop Type
	
	# Supposed to Request Window Attention - Probably Only Works if Window is Out of Focus
	#OS.request_attention()
	
	# If not careful, the game can easily make a laptop hot. For computers that can handle processing as quickly as possible, this can be disabled.
	# TODO: Provide option in settings to turn this off.
	#OS.low_processor_usage_mode = true # Default Off - Meant for programs (as not in games - Causes performance issues in game)
	OS.vsync_enabled = true # Already enabled by default, but can be changed by code.
	
	Engine.set_iterations_per_second(30) # Physics FPS - Default 60
	Engine.set_target_fps(30) # Rendering FPS - Default Unlimited
	
	logger.verbose("Number of Cores: %s" % OS.get_processor_count())
	logger.verbose("Multithread Support: %s" % OS.can_use_threads())
	
	if OS.can_use_threads():
		# Figure out how to change Rendering Thread Model in GDScript
		pass
	
	# It appears my compiled version of Godot's Server cannot use network. It doesn't even show up in Wireshark (and I checked the firewall)
	if(OS.has_feature("Server") == true):
		# If using a servermode engine, set game to servermode
		# I may just listen for command line arguments and not use OS.has_feature(...)
		gamestate.server_mode = true
	
	# https://godotengine.org/qa/11251/how-to-export-the-project-for-server?show=11253#a11253
	# Checks if Running on Headless Server (Currently Linux Only? There is a commit where someone added support for OSX, but no official builds)
	# I compiled Godot's Server Executable and it cannot run the server without the original source code. This could cause problems for execution speed when the binaries are not precompiled.
	# Also, OS.get_unique_id(), does not work in my Server Executable.
	# I am going to try to make the game headless compatible without using a separate Godot binary.
	logger.verbose("Server Binary: %s" % OS.has_feature("Server")) # This Determines If Using Godot Server Binary
	logger.verbose("Set Server Mode: %s" % gamestate.server_mode) # This Determines If Server Mode Was Set (Will Be Able To Be Set In Regular Binary)
		
	if gamestate.server_mode:
		# This simulates a windowless server. I do not know if it will work in a true windowless environment (e.g. a dedicated linux server)
		# In that, Godot has official builds for a linux server mode engine which handles the windowless mode automatically.
		
		# when this is true, splash is disabled and background is transparent (also, the window is in borderless mode).
		# The transparent background is still clickable, so change window size to 0 and minimize the window.
		# Also, figure out how to hide the root viewport (or dynamically the children viewports)
		OS.set_window_size(Vector2(0, 0)) # Sets Window Size to 0 (so that it does not intercept clicks to another application)
		OS.set_window_minimized(true) # Minimizes the Window - Shouldn't be necessary since window is already (0, 0), but provides not grabbing control from an invisible window
		
		# This is overkill
		#OS.window_per_pixel_transparency_enabled = true # Turns on Pixel Transparency
		#get_tree().get_root().set_transparent_background(true) # Makes Root Viewport Have a Transparent Background
		#get_tree().get_root().get_node("MainMenu").visible = false # Hides MainMenu
