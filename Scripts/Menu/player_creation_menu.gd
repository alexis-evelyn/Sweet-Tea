extends Control
class_name PlayerCreationMenu

signal character_created # Signal to Let Other Popup Know When Character Has Been Created

# Declare member variables here. Examples:
onready var playerCreationWindow = $PlayerCreationWindow
onready var createCharacterButton = $PlayerCreationWindow/background/Interface/CreateCharacter
onready var characterName = $PlayerCreationWindow/background/Interface/CharacterName
onready var characterColor = $PlayerCreationWindow/background/Interface/CharacterColor
#onready var debugMode = $PlayerCreationWindow/background/Interface/DebugMode
onready var worldSeed = $PlayerCreationWindow/background/Interface/WorldSeed

var old_title : String = functions.empty_string # Title From Before Window Was Shown
var slot : int # Save Slot to Use For Character
var is_client : bool = false # Determine If Is Server or Client
var world_seed : String = functions.empty_string # Seed to use to generate world

#var loading_screen : LoadingScreen
#const loading_screen_name : String = "res://Menus/LoadingScreen.tscn" # Loading Screen

#var create_world_server_thread : Thread = Thread.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	"""
		Setup Player Creation Menu Before It Is Displayed
	"""

	playerCreationWindow.window_title = tr("create_character_title") # Can be used for translation code
	playerCreationWindow.get_close_button().disabled = true # Disable X Button (use theme or gdscript to remove disabled x texture)
	playerCreationWindow.get_close_button().set_disabled_texture(ImageTexture.new()) # Create Empty Texture For Disabled Close Button - This cannot be specifically chosen by the theme alone

	set_text()

func set_text() -> void:
	"""
		Set Translation Friendly Text For Menu UI
	"""

	createCharacterButton.text = tr("create_character_button")
#	debugMode.text = tr("debug_mode_checkbox")

	worldSeed.placeholder_text = tr("world_seed_placeholder")
	characterName.placeholder_text = tr("character_name_placeholder")

	#characterColor.text = tr("character_color")

func create_character() -> void:
	"""
		Create and Save Character
	"""

	logger.info("Slot: %s" % slot)

	# Cool Color - #ff00ab
	# Unless modded, the color output should always be a valid color
	gamestate.player_info.char_color = get_picker_color()

	# Generate A Random Character ID
	gamestate.player_info.char_unique_id = gamestate.generate_character_unique_id()

	# Unless modded, the checkbox should always be a valid boolean value
	# Now that debug mode can be set by command, I am removing it from the character creation menu.
#	gamestate.debug = debugMode.is_pressed()

	# Currently Loaded Save
	gamestate.loaded_save = slot

	# I am not officially supporting Mobile Devices Until After Release, But I Am Testing The Game on Android
	if (functions.get_system() == functions.host_system.android) or (functions.get_system() == functions.host_system.iOS):
		gamestate.debug = true

	# Set Character's Name
	gamestate.player_info.name = get_character_name()

	# Set World's Seed
	if get_seed() == functions.empty_string:
		if worldSeed.text == functions.empty_string:
			set_seed("Randomly Generated Seed")
		else:
			set_seed(worldSeed.text)

	# This is setup so worldgen does not happen if the new character was created for the purpose of joining a server.
	# This will help save processing time as worldgen can be delayed until later
	if is_client:
		gamestate.player_info.world_created = false
		gamestate.player_info.world_seed = world_seed
		gamestate.player_info.starting_world = functions.not_set_string # Fixes A Bug Where World Path Can Appear to Be Set, but Isn't
		gamestate.save_player(slot)
	else:
		create_world()
		gamestate.save_player(slot)
		network.start_server()

	$PlayerCreationWindow.hide() # Hides Own Popup Menu
	emit_signal("character_created") # Alerts Player Selection Menu That It Can Continue Processing The Scene To Load (If Any)

# This is a function as I need to call this in player selection without resetting the character's variables
func create_world() -> void:
	"""
		Create and Save World Once Character is Created

		Used Exclusively For Character Creation
	"""

	# Should I Thread This?


	# Setup loading screen on separate thread here and listen or signals from world loader.
#	if not get_tree().get_root().has_node("LoadingScreen"):
#		loading_screen = load(loading_screen_name).instance()
#		loading_screen.name = "LoadingScreen"
#		get_tree().get_root().add_child(loading_screen) # Call Deferred Will Make This Too Late

	# Attempting to thread this causes issues, but since world creation doesn't take that long (right now), I am not going to add the loading screen.
#	create_world_server_thread.start(world_handler, "create_world_server_threaded", [gamestate.standard_netids.invalid_id, world_seed, Vector2(0, 0)]) # The Vector (0, 0) is here until I decide if I want to generate a custom world size. This will just default to what the generator has preset.
#	yield(get_tree().create_timer(0.5), "timeout")
#	var world_name : String = create_world_server_thread.wait_to_finish()
	var world_name : String = world_handler.create_world_server_threaded([gamestate.standard_netids.invalid_id, world_seed, Vector2(0, 0)])

	gamestate.player_info.starting_world = world_handler.get_world_folder(world_name)

#	gamestate.save_player(slot)

	logger.verbose("Player Creation Menu - Starting Server (Singleplayer)")
	# Should I Thread This?
	world_handler.save_world(spawn_handler.get_world_node(world_name))

func get_picker_color() -> String:
	"""
		Retrieves Character's Color

		Can Be Modified In The Future To Alter Color to Become Friendlier (Easier To See) for Game Background
	"""

	# This is a function for if I eventually modify the color to make it play nicer with the background.
	return characterColor.color.to_html(false)

func get_character_name() -> String:
	"""
		Get Character's Name (Or If Missing, Retrieve Default Character's Name)
	"""

	if characterName.text == functions.empty_string:
		return gamestate.DEFAULT_PLAYER_NAME
	else:
		return characterName.text

# I probably won't do random names.
func get_random_name() -> String:
	"""
		Pick Random Name To Use

		Not Being Implemented Unless I Change My Mind In The Future
	"""

	# Pick A Random Name For Character
	return "Default Character Name"

func set_seed(set_seed: String) -> void:
	"""
		Set World's Seed
	"""


	world_seed = set_seed

func get_seed() -> String:
	"""
		Retrieve World's Seed
	"""

	return world_seed

func set_slot(character_slot: int) -> void:
	"""
		Set Character's Save Slot Number
	"""

	slot = character_slot
	logger.verbose("Selecting Slot %s for Creating Character" % character_slot)

func set_client(client: bool = true) -> void:
	"""
		Used to Determine if Creating Character For Singleplayer or Multiplayer

		If For Multiplayer, World Creation Will Be Delayed For Performance Reasons
	"""

	is_client = client

func _about_to_show() -> void:
	"""
		Set's Translation Friendly Title For Character Creation Menu

		Stores Old Title For Setting Back Later

		Not Meant to Be Called Directly
	"""

	old_title = functions.get_title()
	functions.set_title(tr("create_character_title"))

func _about_to_hide() -> void:
	"""
		Reset Title to Before

		Not Meant to Be Called Directly
	"""

	functions.set_title(old_title)

func _notification(what: int) -> void:
	"""
		Listen to System Notifications

		Not Implemented

		Not Meant to Be Called Directly
	"""

	match what:
		WindowDialog.NOTIFICATION_POST_POPUP:
			# Logical First Button on WindowDialog
			# TODO: Get Rid of Control Node - Useful For Detecting Post Popup Notifications
#			playerSlots.get_child(0).focus_mode = Control.FOCUS_ALL
#			playerSlots.get_child(0).grab_focus()
			pass

func get_class() -> String:
	return "PlayerCreationMenu"
