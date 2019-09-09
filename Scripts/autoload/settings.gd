extends Node
class_name SettingsLoader

# Used to load settings from options menu

# Declare member variables here. Examples:
var game_settings : String = "user://game-settings.json"
var game_settings_backup : String = "user://game-settings-backups.json"

# Settings To Keep Track Of
var window_borderless : bool = false
var window_resizable : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	seed(OS.get_system_time_msecs()) # Set Seed to Current Time in Milliseconds (Helps Randomize Generator Per Session)
	
	logger.create_log() # Start Logging to File
	check_settings() # Check OS Settings For Optimizing Game Performance
	load_server_info() # Load's Server Info From File
	load_locale() # Load Locale Settings
#	load_game_settings() # Load Player's Game Settings From File
	OS.set_window_size(Vector2(1024, 700))
	
	var center_screen : Vector2 = (OS.get_screen_size(OS.get_current_screen()) / Vector2(2, 2)) - (OS.get_window_size() / Vector2(2, 2))
	
	OS.set_window_position(center_screen)

#	get_tree().debug_collisions_hint = true
#	get_tree().debug_navigation_hint = true
#	get_tree().set_refuse_new_network_connections(true)
#	get_tree().set_quit_on_go_back(false)

#	functions.list_game_translations()

# Load Locale Settings From File
func load_locale() -> void:
	TranslationServer.set_locale("en")
	
	logger.debug("Locale: %s" % TranslationServer.get_locale())
	logger.debug("Name: %s" % TranslationServer.get_locale_name(TranslationServer.get_locale()))
	
	gamestate.player_info.locale = TranslationServer.get_locale() # Saves Current Language to Player Info (Player Info is Used By Game and Servers)

# NOT IMPLEMENTED YET!!!
# Load Server's Info From File
func save_server_info() -> void:
	# Save Game Version Here
	
	pass

# Load Server's Info From File
func load_server_info() -> int:
	var save_path : String = game_settings # Save File Path
	
	var save_data : File = File.new()
	
	if not save_data.file_exists(save_path): # Check If Save File Exists
		logger.verbose("Save File Does Not Exist!!! Using Default Server Info?")
		return -1 # Returns -1 to signal that loading save file failed (for reasons of non-existence)
	
	# warning-ignore:return_value_discarded
	save_data.open(save_path, File.READ)
	var json : JSONParseResult = JSON.parse(save_data.get_as_text())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		#logger.verbose("Save File Read!!!")
		
		if typeof(json.result) == TYPE_DICTIONARY and json.result.has("server_info"):
			#logger.verbose("Save File Imported As Dictionary!!!")
			
			if json.result.has("game_version"):
				logger.verbose("Game Version That Saved File Was: %s" % json.result["game_version"])
				
				# TODO: Check If Saved Game Version Is Compatible With Current Game Version
			else:
				logger.warning("Unknown What Game Version Saved File!!!")

			# TODO: Validate that a valid image is stored where the save file says it is stored
			if json.result.server_info.has("game_icon"):
				network.server_icon = json.result.server_info.game_icon # Server Icon (for Clients to See)

			if json.result.server_info.has("name"):
				network.server_info.name = json.result.server_info.name # Name of Server
				
			if json.result.server_info.has("motd"):
				network.server_info.motd = json.result.server_info.motd # Display A Message To Clients Before Player Joins Server
				
			# TODO: Validate website url to ensure valid (so user can click it ingame and be sent to website)
			if json.result.server_info.has("website"):
				network.server_info.website = json.result.server_info.website # Server Owner's Website (to display rules, purchases, etc...)
				
			# TODO: Validate max players is a legitimate player count
			if json.result.server_info.has("max_players"):
				network.server_info.max_players = int(json.result.server_info.max_players) # Maximum Number of Players (including server player)
				
			# TODO: Validate ip address is valid and is within the list of available ip addresses (if not asterisk)
			if json.result.server_info.has("bind_address"):
				# IP.get_local_addresses()
				network.server_info.bind_address = json.result.server_info.bind_address  # IP Address to Bind To (Use). Asterisk (*) means all available IPs to the Computer.
				
			# Max Chunks Are Not Implemented Yet
			if json.result.server_info.has("max_chunks"):
				network.server_info.max_chunks = int(json.result.server_info.max_chunks) # Max chunks to send to client (client does not request, server sends based on position of client - this helps mitigate DOS abuse)
				
			# Set Elsewhere In Game Code - Just Needs To Be Added to Server Info
			network.server_info.game_version = gamestate.game_version # Add Server's Game Version So Client Can Know if Server Is Compatible
			network.server_info.mods = ["Not Implemented Yet"] # Add List of Mods Used By Server (so client can know if it is compatible with server)
			
			# This one's special as the used_port is currently randomly picked, but it should be overwritten by what the save file says
#				network.server_info.used_port = 0 # Host Port
		else:
#			logger.error("Save Format Is Not A Dictionary!!! It Probably is An Array!!")
#			logger.error("Server Info Is Missing From File: %s" % save_path)
			logger.error("Could Not Load Save File: %s" % save_path)
			return -3 # Returns -3 to signal that JSON cannot be interpreted as a Dictionary or loaded
	else:
		logger.error("Cannot Interpret Save!!! Invalid JSON!!!")
		
	save_data.close()
	return 0

# Check OS Settings For Optimizing Game Performance
func check_settings():
	#logger.verbose("MainLoop: %s" % Engine.get_main_loop().get_class()) # Prints Current MainLoop Type
	
	# https://docs.godotengine.org/en/3.1/classes/class_input.html#class-input-method-set-custom-mouse-cursor
	# See if you (me) can put the cursor images into the theme (so the cursor will be updated when the theme is changed)
#	var test_icon = preload("res://Assets/Icons/game_icon.png")
#	Input.set_custom_mouse_cursor(test_icon, Input.CURSOR_BUSY)
	
	# I keep the changing these settings in the main menu as the splash screen would not display otherwise.
	window_borderless = false
	window_resizable = true
	
	# If not careful, the game can easily make a laptop hot. For computers that can handle processing as quickly as possible, this can be disabled.
	# TODO: Provide option in settings to turn this off.
#	OS.low_processor_usage_mode = true # Default Off - Meant for programs (as not in games - Causes performance issues in game)
	OS.vsync_enabled = true # Already enabled by default, but can be changed by code.
	
	Engine.set_iterations_per_second(30) # Physics FPS - Default 60
	Engine.set_target_fps(30) # Rendering FPS - Default Unlimited
	Engine.set_physics_jitter_fix(1) # Default 0.5 - No Idea How This Value Works
	Engine.set_time_scale(1) # How fast the game clock runs compared to realtime.
	
	logger.file("Engine Version: %s" % Engine.get_version_info())
	
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3:
		logger.file("Current Video Driver: OpenGL ES 3.x Renderer")
	elif OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
		logger.file("Current Video Driver: OpenGL ES 2.x Renderer")
	else:
		logger.warn("Unknown Video Driver!!!")
	
	logger.verbose("Number of Cores: %s" % OS.get_processor_count())
	logger.verbose("Multithread Support: %s" % OS.can_use_threads())
	
	logger.verbose("Current Screen: %s/%s" % [OS.get_current_screen(), OS.get_screen_count()])
	for screen in OS.get_screen_count():
		logger.verbose("Screen DPI for Screen %s: %s" % [screen, OS.get_screen_dpi(screen)])
	
#	logger.verbose("Current Audio Driver: %s")
	logger.verbose("Number Of Audio Drivers: %s" % OS.get_audio_driver_count())
	for audio_driver in OS.get_audio_driver_count():
		logger.verbose("Audio Driver: %s" % OS.get_audio_driver_name(audio_driver))
	
	logger.verbose("Keep Screen On: %s" % OS.is_keep_screen_on())
#	logger.verbose("Can Draw: %s" % OS.can_draw()) # I have no idea what this does
	
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

# THIS IS NOT IMPLEMENTED YET (BECAUSE SETTINGS SCENE IS NOT SET UP)
# Save Player's Game Settings To File
# warning-ignore:unused_argument
func save_game_settings(setting: String) -> void:
	var save_path : String = game_settings # Save File Path
	var save_path_backup : String = game_settings_backup # Save File Backup Path - OS.get_unix_time() is Unix Time Stamp

	#logger.verbose("Game Version: %s" % game_version)
	var settings_data : JSONParseResult # Data To Save
	var settings_data_result : Dictionary # settings_data's Result
	
	var file_op : Directory = Directory.new()
	var save_data : File = File.new()
	
	# Checks to See If Save File Exists
	if save_data.file_exists(save_path):
		#logger.verbose("Save File Exists!!!")
		
		# warning-ignore:return_value_discarded
		save_data.open(save_path, File.READ_WRITE) # Open Save File For Reading/Writing
		settings_data = JSON.parse(save_data.get_as_text()) # Load existing Save File as JSON
	
		# Check If Backup Exists
		if file_op.file_exists(save_path_backup):
			file_op.remove(save_path_backup) # Remove Old Backup
	
		# Backup The Save File (I Want It To Back Up Regardless of if It Is Corrupted)
		# warning-ignore:return_value_discarded
		file_op.copy(save_path, save_path_backup) # Copy Save File to Backup	
	
		# Checks to Make Sure JSON was Parsed
		# warning-ignore:unsafe_property_access
		# warning-ignore:unsafe_property_access
		if settings_data.error == OK and typeof(settings_data.result) == TYPE_DICTIONARY:
			#logger.verbose("Save File Read and Imported As Dictionary!!!")
			# warning-ignore:unsafe_property_access
#			settings_data_result = settings_data.result # Grabs Result From JSON (this is done now so I can grab the error code from earlier)

#			# Should I merge this and the code from new save into a single function?
#			settings_data_result["game_version"] = game_version
#
#			# Temporarily Remove Locale From Player Info
#			if player_info.has("locale"):
#				locale = player_info.locale
#				player_info.erase("locale")
			
			# Note: Key has to be a string, otherwise Godot bugs out and adds duplicate keys to Dictionary
			settings_data_result = {} # Replaces Key In Dictionary With Updated Player_Info
			
			#logger.verbose(to_json(settings_data)) # Print Save Data to stdout (Debug)
			save_data.store_string(to_json(settings_data_result))
	else:
		#logger.verbose("Save File Does Not Exist!!! Creating!!!")
		# warning-ignore:return_value_discarded
		save_data.open(save_path, File.WRITE) # Open Save File For Writing
		
#		# Should I merge this and the code from existing save into a single function?
#		settings_data_result["game_version"] = game_version
#
#		player_info["char_unique_id"] = generate_character_unique_id()
#
#		# Temporarily Remove Locale From Player Info
#		if player_info.has("locale"):
#			locale = player_info.locale
#			player_info.erase("locale")
		
		# Note: Key has to be a string, otherwise Godot bugs out and adds duplicate keys to Dictionary
		settings_data_result = {}
		
		#logger.verbose(to_json(settings_data)) # Print Save Data to stdout (Debug)
		save_data.store_string(to_json(settings_data_result))
		
#	player_info.locale = locale # Set Locale Back For Gamestate
	save_data.close()

# THIS IS NOT IMPLEMENTED YET (BECAUSE SETTINGS SCENE IS NOT SET UP)
# Load Player's Game Settings From File
func load_game_settings() -> int:
	var save_path : String = game_settings # Save File Path
	# warning-ignore:unused_variable
	var save_path_backup : String = game_settings_backup # Save File Backup Path - OS.get_unix_time() is Unix Time Stamp
	
	#OS.window_fullscreen = true # Allows Enabling Full Screen
	#OS.set_window_size(Vector2(640, 480)) # Sets Window's Size
	logger.verbose("Window Size: %s" % OS.get_window_size()) # Get's Window Size Including Titlebar
	#logger.verbose("Real Window Size: %s" % OS.get_real_window_size()) # Gets Window's Size Minus Titlebar
	#logger.verbose("Screen Size: %s" % OS.get_screen_size()) # Gets Screen Size
	
	var save_data : File = File.new()
	
	if not save_data.file_exists(save_path): # Check If Save File Exists
		#logger.verbose("Save File Does Not Exist!!! New Player?")
		return -1 # Returns -1 to signal that loading save file failed (for reasons of non-existence)
	
	# warning-ignore:return_value_discarded
	save_data.open(save_path, File.READ)
	var json : JSONParseResult = JSON.parse(save_data.get_as_text())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		#logger.verbose("Save File Read!!!")
		
		# warning-ignore:unsafe_property_access
		# warning-ignore:unsafe_property_access
		if typeof(json.result) == TYPE_DICTIONARY:
			pass
			#logger.verbose("Save File Imported As Dictionary!!!")
			
#			# warning-ignore:unsafe_property_access
#			if json.result.has("game_version"):
#				# warning-ignore:unsafe_property_access
#				# warning-ignore:unsafe_property_access
#				logger.verbose("Game Version That Saved File Was: " + json.result["game_version"])
#			else:
#				logger.warning("Unknown What Game Version Saved File!!!")
#
#			# warning-ignore:unsafe_property_access
#			if json.result.has(str(slot)):
#				# warning-ignore:unsafe_property_access
#				# I keep the locale in player_info so the server can know the client's locale
#				var locale : String = player_info.locale
#				player_info = json.result[str(slot)]
#				player_info.locale = locale
#
#				# Check if Save Data Has Debug Boolean
#				if player_info.has("debug"):
#					debug = bool(player_info.debug)
#
#			else:
#				logger.warn("Player Slot Does Not Exist: %s" % slot)
#				return -2 # Returns -2 to signal that player slot does not exist
		else:
			logger.error("Save Format Is Not A Dictionary!!! It Probably is An Array!!")
			return -3 # Returns -3 to signal that JSON cannot be interpreted as a Dictionary
	else:
		logger.error("Cannot Interpret Save!!! Invalid JSON!!!")
		
	save_data.close()
	return 0
	
func get_class() -> String:
	return "SettingsLoader"
