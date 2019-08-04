extends Node

var save_directory : String = "user://" # Set's Storage Directory
var save_file : String = "characters.json" # Save File Name

var backups_dir : String = "save_backups" # Backup Directory Name
var backups_save_file : String = "characters_%date%.json" # Backup Save File Name Template

var game_version : String = ProjectSettings.get_setting("application/config/Version")

var game_theme : Theme = load("res://Themes/default_theme.tres")
var server_mode : bool = false

# Player Info Dictionary
var player_info : Dictionary = {
	name = "Player", # Player's Name
	actor_path = "res://Objects/Players/Player.tscn", # The Player's Scene (Comparable to Class)
	char_color = "ffffff", # Unmodified Player Color - May Combine With Custom Sprites (and JSON)
	os_unique_id = OS.get_unique_id(), # Stores OS Unique ID - Can be used to link players together, Not Designed to Be Secure (as in player is allowed to tamper with it)
	char_unique_id = "Not Set"
}

var net_id : int = 1 # Player's ID

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

# Save Game Data
func save_player(slot: int) -> void:
	var save_path : String = save_directory.plus_file(save_file) # Save File Path
	var save_path_backup : String = save_directory.plus_file(backups_dir.plus_file(backups_save_file.replace("%date%", str(OS.get_unix_time())))) # Save File Backup Path - OS.get_unix_time() is Unix Time Stamp
	var backup_path : String = save_directory.plus_file(backups_dir) # Backup Directory Path

	#print("Game Version: " + game_version)
	var players_data # Data To Save
	
	var file_op : Directory = Directory.new() # Allows Performing Operations on Files (like moving or deleting a file)
	
	# Make Save File Backup Directory (if it does not exist)
	if not file_op.dir_exists(backup_path):
		file_op.make_dir(backup_path)
	
	var save_data : File = File.new()
	
	# Checks to See If Save File Exists
	if save_data.file_exists(save_path):
		#print("Save File Exists!!!")
		
		save_data.open(save_path, File.READ_WRITE) # Open Save File For Reading/Writing
		players_data = JSON.parse(save_data.get_as_text()) # Load existing Save File as JSON
	
		# Backup The Save File (I Want It To Back Up Regardless of if It Is Corrupted)
		file_op.copy(save_path, save_path_backup) # Copy Save File to Backup	
	
		# Checks to Make Sure JSON was Parsed
		if players_data.error == OK and typeof(players_data.result) == TYPE_DICTIONARY:
			#print("Save File Read and Imported As Dictionary!!!")
			players_data = players_data.result # Grabs Result From JSON (this is done now so I can grab the error code from earlier)
			
			# Should I merge this and the code from new save into a single function?
			players_data["game_version"] = game_version
			
			# Note: Key has to be a string, otherwise Godot bugs out and adds duplicate keys to Dictionary
			players_data[str(slot)] = player_info # Replaces Key In Dictionary With Updated Player_Info
			
			#print(to_json(players_data)) # Print Save Data to stdout (Debug)
			save_data.store_string(to_json(players_data))
	else:
		#print("Save File Does Not Exist!!! Creating!!!")
		save_data.open(save_path, File.WRITE) # Open Save File For Writing
		
		# Should I merge this and the code from existing save into a single function?
		players_data["game_version"] = game_version
		
		# Note: Key has to be a string, otherwise Godot bugs out and adds duplicate keys to Dictionary
		players_data[str(slot)] = player_info
		
		#print(to_json(players_data)) # Print Save Data to stdout (Debug)
		save_data.store_string(to_json(players_data))
		
	save_data.close()

# Load Game Data
func load_player(slot: int) -> int: # TODO: Rename to load_player?
	#print("Game Version: " + game_version)
	#print("Save Data Location: " + OS.get_user_data_dir())
	#OS.shell_open(str("file://", OS.get_user_data_dir())) # Use this to open up user save data location (say to backup saves or downloaded resources/mods)
	
	var save_data : File = File.new()
	
	if not save_data.file_exists(save_directory.plus_file(save_file)): # Check If Save File Exists
		#print("Save File Does Not Exist!!! New Player?")
		return -1 # Returns -1 to signal that loading save file failed (for reasons of non-existence)
	
	save_data.open(save_directory.plus_file(save_file), File.READ)
	var json : JSONParseResult = JSON.parse(save_data.get_as_text())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		#print("Save File Read!!!")
		
		if typeof(json.result) == TYPE_DICTIONARY:
			#print("Save File Imported As Dictionary!!!")
			
			if json.result.has("game_version"):
				print("Game Version That Saved File Was: " + json.result["game_version"])
			else:
				print("Unknown What Game Version Saved File!!!")
			
			if json.result.has(str(slot)):
				player_info = json.result[str(slot)]
			else:
				printerr("Player Slot Does Not Exist: " + str(slot))
				return -2 # Returns -2 to signal that player slot does not exist
		else:
			printerr("Save Format Is Not A Dictionary!!! It Probably is An Array!!")
			return -3 # Returns -3 to signal that JSON cannot be interpreted as a Dictionary
	else:
		printerr("Cannot Interpret Save!!! Invalid JSON!!!")
		
	save_data.close()
	return 0
	
# Delete Player From Save
func delete_player(slot: int):
	pass
	
# Checks If Slot Exists
func check_if_slot_exists(slot: int) -> bool:
	var save_data : File = File.new()
	
	if not save_data.file_exists(save_directory.plus_file(save_file)): # Check If Save File Exists
		#print("Save File Does Not Exist!!! So, Slot Does Not Exist!!!")
		return false
	
	save_data.open(save_directory.plus_file(save_file), File.READ)
	var json : JSONParseResult = JSON.parse(save_data.get_as_text())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		if typeof(json.result) == TYPE_DICTIONARY:
			if json.result.has(str(slot)):
				#print("Slot Exists: " + str(slot))
				return true
			else:
				#print("Slot Does Not Exist: " + str(slot))
				return false
				
	return false