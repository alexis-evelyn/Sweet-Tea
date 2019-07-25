extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in $PlayerSelectionWindow/PlayerSlots.get_children():
		slot.connect("pressed", self, "_character_slot_pressed", [slot])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Check Which Player Slots Already Exist In Save and Update Player Selection Buttons
func check_existing_slots():
	print("Checking For Existing Slots")
	
	for slot in $PlayerSelectionWindow/PlayerSlots.get_child_count():
		print("Checking Slot: " + str(slot))
		
		var slot_exists = gamestate.check_if_slot_exists(int(slot))
		
		if slot_exists:
			$PlayerSelectionWindow/PlayerSlots.get_child(slot).set_text("Load Character") # Change Button Text If Slot Exists in Save
		else:
			$PlayerSelectionWindow/PlayerSlots.get_child(slot).set_text("New Character") # Change Button Text If Slot Does Not Exist in Save

# Gets The Button That Was Pressed (and Loads or Creates Character)
func _character_slot_pressed(button):
	print("Character Slot Pressed: " + str(button.get_index()))

# Debug Message To See If Popup Should Show
func _on_PlayerSelectionWindow_about_to_show():
	print("Player Selection About to Show!!!")
	
	check_existing_slots()
