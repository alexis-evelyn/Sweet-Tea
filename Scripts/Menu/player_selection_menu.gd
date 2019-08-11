extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in $PlayerSelectionWindow/PlayerSlots.get_children():
		slot.connect("pressed", self, "_character_slot_pressed", [slot])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float):
#	pass

func check_existing_slots() -> void:
	"""
		Check Save Data for Existing Slots
		
		Updates Player Selection Buttons
	"""
	
	#print("Checking For Existing Slots")
	
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
	
	print("Character Slot Pressed: " + str(button.get_index()))

func _on_PlayerSelectionWindow_about_to_show() -> void:
	"""
		Check Save Data for Existing Slots
		
		Not Meant to Be Called Directly
	"""
	
	check_existing_slots()
