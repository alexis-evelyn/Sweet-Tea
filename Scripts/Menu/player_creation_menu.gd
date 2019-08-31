extends Control

signal character_created # Signal to Let Other Popup Know When Character Has Been Created

# Declare member variables here. Examples:
onready var createCharacterButton = $PlayerCreationWindow/Interface/CreateCharacter
onready var characterName = $PlayerCreationWindow/Interface/CharacterName
onready var characterColor = $PlayerCreationWindow/Interface/CharacterColor
onready var debugMode = $PlayerCreationWindow/Interface/DebugMode
onready var worldSeed = $PlayerCreationWindow/Interface/WorldSeed

var old_title : String = "" # Title From Before Window Was Shown
var slot : int # Save Slot to Use For Character
var is_client : bool = false # Determine If Is Server or Client
var world_seed : String = "" # Seed to use to generate world

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerCreationWindow.window_title = tr("create_character_title") # Can be used for translation code

	set_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_text() -> void:
	createCharacterButton.text = tr("create_character_button")
	debugMode.text = tr("debug_mode_checkbox")
	
	worldSeed.placeholder_text = tr("world_seed_placeholder")
	characterName.placeholder_text = tr("character_name_placeholder")
	
	characterColor.text = tr("character_color")

func create_character() -> void:
	logger.info("Slot: %s" % slot)
	
	# Cool Color - #ff00ab
	# Unless modded, the color output should always be a valid color
	gamestate.player_info.char_color = get_picker_color()
	
	# Generate A Random Character ID
	gamestate.player_info.char_unique_id = gamestate.generate_character_unique_id()
	
	# Unless modded, the checkbox should always be a valid boolean value
	gamestate.debug = debugMode.is_pressed()
	
	# Set Character's Name
	gamestate.player_info.name = get_character_name()
	
	# Set World's Seed
	if get_seed() == "":
		if worldSeed.text == "":
			set_seed("Randomly Generated Seed")
		else:
			set_seed(worldSeed.text)
	
	# This is setup so worldgen does not happen if the new character was created for the purpose of joining a server.
	# This will help save processing time as worldgen can be delayed until later
	if is_client:
		gamestate.player_info.world_created = false
		gamestate.player_info.world_seed = world_seed
		gamestate.player_info.starting_world = "Not Set" # Fixes A Bug Where World Path Can Appear to Be Set, but Isn't
		gamestate.save_player(slot)
	else:
		create_world()
		gamestate.save_player(slot)
		network.start_server()
	
	$PlayerCreationWindow.hide() # Hides Own Popup Menu
	emit_signal("character_created") # Alerts Player Selection Menu That It Can Continue Processing The Scene To Load (If Any)

# This is a function as I need to call this in player selection without resetting the character's variables
func create_world() -> void:
	var world_name = world_handler.create_world(-1, world_seed, Vector2(0, 0)) # The Vector (0, 0) is here until I decide if I want to generate a custom world size. This will just default to what the generator has preset.
	
	gamestate.player_info.starting_world = "user://worlds/".plus_file(world_name)
	
	#gamestate.save_player(slot)

	logger.verbose("Player Creation Menu - Starting Server (Singleplayer)")
	world_handler.save_world(world_handler.get_world(world_name))

func get_picker_color() -> Color:
	# This is a function for if I eventually modify the color to make it play nicer with the background.
	return characterColor.color
	
func get_character_name() -> String:
	if characterName.text == "":
		return get_random_name()
	else:
		return characterName.text

func get_random_name() -> String:
	# Pick A Random Name For Character
	return "Default Character Name"

func set_seed(set_seed: String) -> void:
	world_seed = set_seed

func get_seed() -> String:
	return world_seed

func set_slot(character_slot: int) -> void:
	slot = character_slot
	logger.verbose("Selecting Slot %s for Creating Character" % character_slot)

func set_client(client: bool = true) -> void:
	is_client = client

func _about_to_show() -> void:
	old_title = functions.get_title()
	functions.set_title(tr("create_character_title"))

func _about_to_hide() -> void:
	"""
		Reset Title to Before
		
		Not Meant to Be Called Directly
	"""
	
	functions.set_title(old_title)
