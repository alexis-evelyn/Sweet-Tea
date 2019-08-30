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
	settings.check_settings() # Checks for System Status to Determine How To Optimize The Game
	
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
				# Should I restrict to .tres and .res extensions?
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
