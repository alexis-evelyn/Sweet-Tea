extends Node

var save_file = "user://savegame.save"

var game_version = ProjectSettings.get_setting("application/config/Version")

# Player Info Dictionary
var player_info = {
	name = "Player", # Player's Name
	net_id = 1, # Player's ID
	actor_path = "res://Objects/Players/Player.tscn", # The Player's Scene (Comparable to Class)
	char_color = Color(1, 1, 1) # Unmodified Player Color - May Combine With Custom Sprites (and JSON)
}

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

# Save Game Data
func save_game(slot: int):
	print("Game Version: " + game_version)
	
	var data_to_save
	
	var save_data = File.new()
	save_data.open(save_file, File.WRITE)
	
	save_data.store_line(to_json(player_info))
	save_data.close()

# Load Game Data
func load_game(slot: int):
	print("Game Version: " + game_version)
	
	var save_data = File.new()
	
	if not save_data.file_exists(save_file):
		print("Save File Does Not Exist!!! New Player?")
		return
	
	save_data.open(save_file, File.READ)
	var json = JSON.parse(save_data.get_line())
		
	# Checks to Make Sure JSON was Parsed
	if json.error == OK:
		print("Save File Read and Imported As Dictionary!!!")
		player_info = json.result
	else:
		printerr("Cannot Interpret Save!!! Invalid JSON!!!")
		
	save_data.close()