extends Node
class_name GameState

var save_directory : String = "user://" # Set's Storage Directory
var save_file : String = "characters.json" # Save File Name

var backups_dir : String = "save_backups" # Backup Directory Name
var backups_save_file : String = "characters_%date%.json" # Backup Save File Name Template

var game_version : String = ProjectSettings.get_setting("application/config/Version")

# warning-ignore:unused_class_variable
var game_theme : Theme = preload("res://Assets/Themes/default_theme.tres")
# warning-ignore:unused_class_variable
var server_mode : bool = false

# Player Info Dictionary
var player_info : Dictionary = {
	name = "Player", # Player's Name
	char_color = Color.white.to_html(false), # Unmodified Player Color - May Combine With Custom Sprites (and JSON)
	os_unique_id = OS.get_unique_id(), # Stores OS Unique ID - Can be used to link players together, Not Designed to Be Secure (as in player is allowed to tamper with it)
	char_unique_id = "Not Set", # Unique Character ID (meant for servers so they can attach features to specific characters - very useful for server plugins
	starting_world = "Not Set", # Spawn World - Saved to File so The World Loader Can Load The Spawn World Up (Say Permanent Chunk Loading - Will Be Loaded on Client when Client is Connected to Server. Similar idea to Starbound's Spaceship on Servers') - Not Meant to Spawn Players in (Meant for Server Player Only - E.g. Single Player).
	saved_world = "", # Functionally the same thing as current_world, but meant for Single Player Only (the one exception is, the single player world is loaded on client when connected to server. Similar idea to Starbound's Spaceship on Servers) - Loads Player In Last Saved World
	locale = TranslationServer.get_locale() # Helps Servers Know What Language To Use (for multilingual supporting servers)
}

# warning-ignore:unused_class_variable
var net_id : int = 1 # Player's ID
# warning-ignore:unused_class_variable
var debug : bool = false

# A Note On Saving
# I am able to load and save nodes natively using Godot.
# Because of that, I am going to have Godot save player worlds and entities directly.
# This includes mob positions/actions, dropped entities, time of day (falls under world data), and world data.

# What will be stored manually is player stats (health, levels, etc...) and inventory.
# Player's Home may be stored as a node (separate from the other native save) and player location will not be saved (player will always start at home).
# The choice to not save player location and have some manual saving comes from singleplayer and multiplayer sharing the same data.
# The game will be an adventure/building game which features a storymode that can be played in multiplayer too.

# NOTE: If I can figure out how to get to handle the save data and keep it multiplayer compatible, then I won't do manual saving.

# Servers should be able to create their own storymode along with custom mobs/mods/etc... (unrelated to saving, but storymode is a manual save too).

# Note: "user://" is guaranteed by default to be writeable (so I should be able to assume read/write permissions).
# It will only change if the user changes it manually. I could check if I wanted to (and maybe I will add that feature later)

# Used To Cleanup Player Info
func reset_player_info() -> void:
	gamestate.player_info.name = "Player" # Player's Name
	gamestate.player_info.char_color = Color.white.to_html(false) # Unmodified Player Color - May Combine With Custom Sprites (and JSON)
	gamestate.player_info.os_unique_id = OS.get_unique_id() # Stores OS Unique ID - Can be used to link players together, Not Designed to Be Secure (as in player is allowed to tamper with it)
	gamestate.player_info.char_unique_id = "Not Set" # Unique Character ID (meant for servers so they can attach features to specific characters - very useful for server plugins
	gamestate.player_info.starting_world = "Not Set" # Spawn World - Saved to File so The World Loader Can Load The Spawn World Up (Say Permanent Chunk Loading - Will Be Loaded on Client when Client is Connected to Server. Similar idea to Starbound's Spaceship on Servers') - Not Meant to Spawn Players in (Meant for Server Player Only - E.g. Single Player).
	gamestate.player_info.saved_world = "" # Functionally the same thing as current_world, but meant for Single Player Only (the one exception is, the single player world is loaded on client when connected to server. Similar idea to Starbound's Spaceship on Servers) - Loads Player In Last Saved World
#	gamestate.player_info.locale = TranslationServer.get_locale() # Helps Servers Know What Language To Use (for multilingual supporting servers)

# Save Game Data
func save_player(slot: int) -> void:
	var save_path : String = save_directory.plus_file(save_file) # Save File Path
	var save_path_backup : String = save_directory.plus_file(backups_dir.plus_file(backups_save_file.replace("%date%", str(OS.get_unix_time())))) # Save File Backup Path - OS.get_unix_time() is Unix Time Stamp
	var backup_path : String = save_directory.plus_file(backups_dir) # Backup Directory Path
	var locale : String # Store a Copy of Player's Locale

	#logger.verbose("Game Version: %s" % game_version)
	var players_data : JSONParseResult # Data To Save
	var players_data_result : Dictionary # players_data's Result
	
	var file_op : Directory = Directory.new() # Allows Performing Operations on Files (like moving or deleting a file)
	
	# Make Save File Backup Directory (if it does not exist)
	if not file_op.dir_exists(backup_path):
		# warning-ignore:return_value_discarded
		file_op.make_dir(backup_path)
	
	var save_data : File = File.new()
	
	# Checks to See If Save File Exists
	if save_data.file_exists(save_path):
		#logger.verbose("Save File Exists!!!")
		
		# warning-ignore:return_value_discarded
		save_data.open(save_path, File.READ_WRITE) # Open Save File For Reading/Writing
		players_data = JSON.parse(save_data.get_as_text()) # Load existing Save File as JSON
	
		# Backup The Save File (I Want It To Back Up Regardless of if It Is Corrupted)
		# warning-ignore:return_value_discarded
		file_op.copy(save_path, save_path_backup) # Copy Save File to Backup	
	
		# Checks to Make Sure JSON was Parsed
		# warning-ignore:unsafe_property_access
		# warning-ignore:unsafe_property_access
		if players_data.error == OK and typeof(players_data.result) == TYPE_DICTIONARY:
			#logger.verbose("Save File Read and Imported As Dictionary!!!")
			# warning-ignore:unsafe_property_access
			players_data_result = players_data.result # Grabs Result From JSON (this is done now so I can grab the error code from earlier)
			
			# Should I merge this and the code from new save into a single function?
			players_data_result["game_version"] = game_version
			
			# Temporarily Remove Locale From Player Info
			if player_info.has("locale"):
				locale = player_info.locale
				player_info.erase("locale")
			
			# Note: Key has to be a string, otherwise Godot bugs out and adds duplicate keys to Dictionary
			players_data_result[str(slot)] = player_info # Replaces Key In Dictionary With Updated Player_Info
			
			#logger.verbose(to_json(players_data)) # Print Save Data to stdout (Debug)
			save_data.store_string(to_json(players_data_result))
	else:
		#logger.verbose("Save File Does Not Exist!!! Creating!!!")
		# warning-ignore:return_value_discarded
		save_data.open(save_path, File.WRITE) # Open Save File For Writing
		
		# Should I merge this and the code from existing save into a single function?
		players_data_result["game_version"] = game_version
		
		player_info["char_unique_id"] = generate_character_unique_id()
		
		# Temporarily Remove Locale From Player Info
		if player_info.has("locale"):
			locale = player_info.locale
			player_info.erase("locale")
		
		# Note: Key has to be a string, otherwise Godot bugs out and adds duplicate keys to Dictionary
		players_data_result[str(slot)] = player_info
		
		#logger.verbose(to_json(players_data)) # Print Save Data to stdout (Debug)
		save_data.store_string(to_json(players_data_result))
		
	player_info.locale = locale # Set Locale Back For Gamestate
	save_data.close()

# Load Game Data
func load_player(slot: int) -> int:
	#logger.verbose("Game Version: %s" % game_version)
	#logger.verbose("Save Data Location: %s" % OS.get_user_data_dir())
	#OS.shell_open(str("file://", OS.get_user_data_dir())) # Use this to open up user save data location (say to backup saves or downloaded resources/mods)
	
	var save_data : File = File.new()
	
	if not save_data.file_exists(save_directory.plus_file(save_file)): # Check If Save File Exists
		#logger.verbose("Save File Does Not Exist!!! New Player?")
		return -1 # Returns -1 to signal that loading save file failed (for reasons of non-existence)
	
	# warning-ignore:return_value_discarded
	save_data.open(save_directory.plus_file(save_file), File.READ)
	var json : JSONParseResult = JSON.parse(save_data.get_as_text())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		#logger.verbose("Save File Read!!!")
		
		# warning-ignore:unsafe_property_access
		# warning-ignore:unsafe_property_access
		if typeof(json.result) == TYPE_DICTIONARY:
			#logger.verbose("Save File Imported As Dictionary!!!")
			
			# warning-ignore:unsafe_property_access
			if json.result.has("game_version"):
				# warning-ignore:unsafe_property_access
				# warning-ignore:unsafe_property_access
				logger.verbose("Game Version That Saved File Was: %s" % json.result["game_version"])
			else:
				logger.warning("Unknown What Game Version Saved File!!!")
			
			# warning-ignore:unsafe_property_access
			if json.result.has(str(slot)):
				# warning-ignore:unsafe_property_access
				# I keep the locale in player_info so the server can know the client's locale
				var locale : String = player_info.locale
				player_info = json.result[str(slot)]
				player_info.locale = locale
				
				# Check if Save Data Has Debug Boolean
				if player_info.has("debug"):
					debug = bool(player_info.debug)
				
			else:
				logger.warn("Player Slot Does Not Exist: %s" % slot)
				return -2 # Returns -2 to signal that player slot does not exist
		else:
			logger.error("Save Format Is Not A Dictionary!!! It Probably is An Array!!")
			return -3 # Returns -3 to signal that JSON cannot be interpreted as a Dictionary
	else:
		logger.error("Cannot Interpret Save!!! Invalid JSON!!!")
		
	save_data.close()
	return 0
	
# Delete Player From Save
# warning-ignore:unused_argument
func delete_player(slot: int):
	pass
	
# Checks If Slot Exists
func check_if_slot_exists(slot: int) -> bool:
	var save_data : File = File.new()
	
	if not save_data.file_exists(save_directory.plus_file(save_file)): # Check If Save File Exists
		#logger.verbose("Save File Does Not Exist!!! So, Slot Does Not Exist!!!")
		return false
	
# warning-ignore:return_value_discarded
	save_data.open(save_directory.plus_file(save_file), File.READ)
	var json : JSONParseResult = JSON.parse(save_data.get_as_text())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		# warning-ignore:unsafe_property_access
		# warning-ignore:unsafe_property_access
		if typeof(json.result) == TYPE_DICTIONARY:
			# warning-ignore:unsafe_property_access
			if json.result.has(str(slot)):
				#logger.verbose("Slot Exists: %s" % str(slot))
				return true
			else:
				#logger.verbose("Slot Does Not Exist: %s" % str(slot))
				return false
				
	return false
	
# Generates Character Unique ID - Can Be Used to Correlate Server Player Save Data and Client Player Save Data
# Not Safe to Manual Modification - If you want to have safe id, there needs to be some form of authentication the user cannot modify
# Authentication can be server-side like in chat, or a login prompt before connecting to server. This can also be through Steam or some other third party service
func generate_character_unique_id() -> String:
	# Returns OS Unique ID Plus A Random Int From 1 Million to 100 Million
	return str(OS.get_unique_id() + "-" + str(randi()%100000001+100000))

func get_class() -> String:
	return "GameState"
