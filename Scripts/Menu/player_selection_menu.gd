extends Control

# Declare member variables here. Examples:
var scene : String = "" # Menu to load if set

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	#print("Checking For Existing Slots")
	
	# This was intentionally setup so a modder can just add more slots.
	# Once I create a modding API (currently I am just going to load PackedScenes, but I will add an actual API later), then I will set this up so adding slots is trivial.
	for slot in $PlayerSelectionWindow/PlayerSlots.get_child_count():
		#print("Checking Slot: " + str(slot))
		
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
	
	#print("Character Slot Pressed: %s" % slot)
	
	if slot_exists:
		print("Loading Character and World!!!")
		gamestate.load_player(slot) # Load Character To Memory
		print("Character Pressed: %s" % gamestate.player_info.name)
		
		# Only load world if a scene to load is not selected.
		if scene == "":
			network.server_info.max_players = 5
			network.start_server()
	else:
		print("Creating Character and World!!!")
		return # This will be replaced by a coroutine which will pull up a character creation menu
		
	# Load's menu after selecting player (may have to move to make Player Creation Screen Work).
	if scene != "":
		get_tree().change_scene(scene)

func _on_PlayerSelectionWindow_about_to_show() -> void:
	"""
		Check Save Data for Existing Slots
		
		Not Meant to Be Called Directly
	"""
	
	check_existing_slots()
