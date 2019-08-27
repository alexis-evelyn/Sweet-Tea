extends Control

# Declare member variables here. Examples:
var scene : String = "" # Menu to load if set
var old_title : String = "" # Title From Before Window Was Shown
var yielding : bool = false # Prevents data.blocked > 0 crash by preventing yielding more than once

var player_creation_menu : String = "res://Menus/PlayerCreationMenu.tscn" # Player Creation Menu
var creation_menu : Node # Player Creation Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$PlayerSelectionWindow.window_title = "Hello" # Can be used for translation code
	
	for slot in $PlayerSelectionWindow/PlayerSlots.get_children():
		slot.connect("pressed", self, "_character_slot_pressed", [slot])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float):
#	pass

# Used to set a menu to load after loading character.
func set_menu(set_scene: String) -> void:
	scene = set_scene

func check_existing_slots() -> void:
	"""
		Check Save Data for Existing Slots
		
		Updates Player Selection Buttons
	"""
	
	#logger.verbose("Checking For Existing Slots")
	
	# This was intentionally setup so a modder can just add more slots.
	# Once I create a modding API (currently I am just going to load PackedScenes, but I will add an actual API later), then I will set this up so adding slots is trivial.
	for slot in $PlayerSelectionWindow/PlayerSlots.get_child_count():
		#logger.verbose("Checking Slot: %s" % str(slot))
		
		var slot_exists : bool = gamestate.check_if_slot_exists(int(slot))
		
		if slot_exists:
			$PlayerSelectionWindow/PlayerSlots.get_child(slot).set_text("Load Character") # Change Button Text If Slot Exists in Save
		else:
			$PlayerSelectionWindow/PlayerSlots.get_child(slot).set_text("New Character") # Change Button Text If Slot Does Not Exist in Save

func _character_slot_pressed(button: Node) -> void:
	"""
		Detect Which Player Selection Button Was Pressed
		
		Pulls Up Load or Create Character Screen Depending on Save Data
		
		Not Meant to Be Called Directly
	"""
	
	# If I figure out how to add metadata to a button, I may replace the index method so a modder can display the character load button in more than one place at the same time.
	var slot : int = button.get_index()
	var slot_exists : bool = gamestate.check_if_slot_exists(int(slot))
	
	#logger.verbose("Character Slot Pressed: %s" % slot)
	
	if not has_node("PlayerCreationMenu"):
		creation_menu = load(player_creation_menu).instance() # Instance Creation Menu
		creation_menu.set_name("PlayerCreationMenu") # Set's a Name (Basically an ID) to make sure I don't create this twice unless it was freed from memory.
	
		add_child(creation_menu) # Add Player Creation Menu As Child of Player Selection Menu
	
	if creation_menu == null:
		logger.error("Player Creation Menu Cannot Be Found!!!")
		return
	elif not creation_menu.has_node("PlayerCreationWindow"):
		logger.error("Player Creation Window Cannot Be Found!!!")
		return
	
	if slot_exists:
		#logger.verbose("Loading Character and World!!!")
		gamestate.load_player(slot) # Load Character To Memory
		#logger.verbose("Character Pressed: %s" % gamestate.player_info.name)
		
		if scene == "":
			if gamestate.player_info.has("world_seed") and gamestate.player_info.has("world_created"):
				if gamestate.player_info.world_created == false: # I am leaving the dictionary entries alone if the value was set to something other than false.
					creation_menu.set_slot(slot) # Passes Slot Number to Character Creation Window
					creation_menu.set_seed(gamestate.player_info.world_seed) # Tell Character Creation About World Seed To Use (Seed was stored in player data as the character was created on a multiplayer menu)
					creation_menu.create_world() # Creates world for character
					
					# Erase old values that are no longer necessary
					gamestate.player_info.erase("world_created")
					gamestate.player_info.erase("world_seed")
					gamestate.save_player(slot)
			
			# Only load world if a scene to load is not selected.
			network.start_server()
	else:
		#logger.verbose("Creating Character and World!!!")
		creation_menu.set_slot(slot) # Passes Slot Number to Character Creation Window
		creation_menu.set_seed("World Creation Seed")
		
		$PlayerSelectionWindow.hide() # Hide own Popup Window
		creation_menu.get_node("PlayerCreationWindow").popup_centered()
		
		if yielding:
			return
		
		if scene == "res://Menus/NetworkMenu.tscn": # Client Mode
			logger.superverbose("Setting Multiplayer Scene to %s for Player Creation!!!" % scene)
			creation_menu.set_client()
		
		yielding = true
		yield(creation_menu, "character_created") # Open PlayerCreationWindow)
		yielding = false
	
	# Yielding causes a catchable crash if this node is moved (including using change_scene). The yielding variable prevents yielding after the first yield, but only prevents it on the first instance of the character slot chosen.
	# Don't Handle Player Data Here!!! Because yielding only happens on the first instance, the data in this script may be invalid if the user loads selection twice after hitting create character (say if a player chooses another slot).
	# Thankfully, only the last instance's data will be in player_creation_menu (which gets updated every instance), so the data is valid and up to date there. Handle player data manipulation in player_creation_menu.
	# I know this may not make since (or maybe it does), but basically, the player_creation_menu is always going to have the right save slot. When handling player creation data, just handle it in the player_creation_menu.
	
	# For those that are observant, you may notice that if the player creation menu was loaded and then the user switched to loading a player, a problem may occur.
	# You would be right. A reference to the thread object (caused by yield) would be lost. That is a non-issue though as any data that was in that thread should be wiped anyway if the player exited the creation screen outside of creating the character.
	# This lost thread will not cause any issues though (in this specific circumstance). The crash I was referencing was attempting to change the scene while the script was yielding twice.
	
	# For more info, the error is "data.blocked > 0". Also, yes, I know losing threads normally means that it runs in the background potentially indefinitely, but that issue is solved by the fact that when the main menu is freed(), then so is every child (including the player creation thread).
	# This means that the thread is cleaned up, although not in a traditional way.
	
	if scene != "":
		get_tree().change_scene(scene)

func _about_to_show() -> void:
	"""
		Check Save Data for Existing Slots
		
		Not Meant to Be Called Directly
	"""
	
	old_title = functions.get_title()
	functions.set_title(tr("Select_Character_Title"))
	check_existing_slots()

func _about_to_hide() -> void:
	"""
		Reset Title to Before
		
		Not Meant to Be Called Directly
	"""
	
	functions.set_title(old_title)
