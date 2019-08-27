extends Control

# This scene is for the modloader.
# The idea is to dynamically load mods at runtime before the MainMenu is even loaded

# https://gamedev.stackexchange.com/a/174312/97290

# Declare member variables here. Examples:
var scene_to_change_to = "res://Menus/MainMenu.tscn"
var mods_folder : String = "user://mods/"
var mods_installed : bool = false

var mods_folder_check : Directory = Directory.new() # Check For Mods Directory

var installed_mods : PoolStringArray # Array of Mods to Load

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	check_system() # Checks for System Status to Determine How To Optimize The Game
	
	installed_mods = PoolStringArray()
	mods_installed = check_for_mods()
	
	if not mods_installed:
		get_tree().change_scene(scene_to_change_to)
		return # Prevents MainMenu from being loaded twice (as a result of load_mods())
	else:
		self.visible = true
		functions.set_title(tr("mods_title")) # Sets Window's Title
		
	logger.debug("---------------------------------------------------")
	load_mods()
	logger.debug("---------------------------------------------------")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

func check_for_mods() -> bool:
	# Make Mods Directory (if it does not exist)
	if not mods_folder_check.dir_exists(mods_folder): # Check If Mods Folder Exists
		#logger.verbose("Mods Folder Does Not Exist!!! Creating!!!")
		mods_folder_check.make_dir(mods_folder)
		return false
	else:
		mods_folder_check.open(mods_folder)
		mods_folder_check.list_dir_begin(true, true) # Opens Stream for Listing Directories - https://docs.godotengine.org/en/3.1/classes/class_directory.html#class-directory-method-list-dir-begin
		
		logger.verbose(" ")
		logger.verbose("Reading Mods Folder!!!")
		
		var file = null
		while file != "":
			file = mods_folder_check.get_next()
			
			if file != "":
				logger.verbose("File: %s" % file)
				installed_mods.append(file)
		
		mods_folder_check.list_dir_end() # Closes Stream for Listing Directories (Not Necessary if get_next() reaches end of directory list) - https://docs.godotengine.org/en/3.1/classes/class_directory.html#class-directory-method-list-dir-end
		
		logger.verbose(" ")
		
		if installed_mods.size() > 0:
			return true
			
		return false
	
func load_mods() -> void:
	var resource : Resource
	var scene : Node
	
	for mod in installed_mods:
		logger.debug("Mod File Name: %s" % mod)
		resource = ResourceLoader.load(mods_folder.plus_file(mod), "PackedScene", false) # Only Loads PackedScenes (Apparently can only load PackedScenes even when trying to load a png or wav? Look at ResourceImporter.)
		logger.superverbose("Resource Type: %s" % typeof(resource))
		
		if resource != null:
			scene = resource.instance() # Instance the Scene
			get_tree().get_root().call_deferred("add_child", scene) # Add Scene to Root
			logger.debug("Loaded Mod: %s" % scene.name)
		
	get_tree().change_scene(scene_to_change_to)

func check_system():
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
