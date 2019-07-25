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

# Gets The Button That Was Pressed (and Loads or Creates Character)
func _character_slot_pressed(button):
	print("Character Slot Pressed: " + str(button.get_index()))

# Debug Message To See If Popup Should Show
func _on_Popup_about_to_show():
	print("Player Selection About to Show!!!")
