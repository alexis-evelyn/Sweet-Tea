extends Control

# Declare member variables here. Examples:
var scene : String = "" # Menu to load if set
var old_title : String = "" # Title From Before Window Was Shown

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
	
	if slot_exists:
		#logger.verbose("Loading Character and World!!!")
		gamestate.load_player(slot) # Load Character To Memory
		#logger.verbose("Character Pressed: %s" % gamestate.player_info.name)
		
		# Only load world if a scene to load is not selected.
		if scene == "":
			network.server_info.max_players = 2
			network.start_server()
	else:
		#logger.verbose("Creating Character and World!!!")
		if not has_node("PlayerCreationMenu"):
			creation_menu = load(player_creation_menu).instance() # Instance Creation Menu
			creation_menu.set_name("PlayerCreationMenu") # Set's a Name (Basically an ID) to make sure I don't create this twice unless it was freed from memory.
		
			add_child(creation_menu) # Add Player Creation Menu As Child of Player Selection Menu
		
		if creation_menu != null:
			if not creation_menu.get_node("PlayerCreationWindow"):
				logger.error("Player Creation Window Cannot Be Found!!!")
				return
				
			creation_menu.set_slot(slot) # Passes Slot Number to Character Creation Window
			$PlayerSelectionWindow.hide() # Hide own Popup Window
			creation_menu.get_node("PlayerCreationWindow").popup_centered() # Open PlayerCreationWindow
		else:
			logger.error("Player Creation Menu Cannot Be Found!!!")
			return
			
	# Load's menu after selecting player (may have to move to make Player Creation Screen Work).
	if scene != "":
		get_tree().change_scene(scene)

func _about_to_show() -> void:
	"""
		Check Save Data for Existing Slots
		
		Not Meant to Be Called Directly
	"""
	
	old_title = functions.get_title()
	functions.set_title("Select A Character")
	check_existing_slots()

func _about_to_hide() -> void:
	"""
		Reset Title to Before
		
		Not Meant to Be Called Directly
	"""
	
	functions.set_title(old_title)
