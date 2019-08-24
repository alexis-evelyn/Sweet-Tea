extends Control

signal character_created # Signal to Let Other Popup Know When Character Has Been Created

# Declare member variables here. Examples:
var old_title : String = "" # Title From Before Window Was Shown
var slot : int # Save Slot to Use For Character

# Called when the node enters the scene tree for the first time.
func _ready():
	#$PlayerCreationWindow.window_title = "Hello" # Can be used for translation code
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_character() -> void:
	logger.error("Slot: %s" % slot)
	
	$PlayerCreationWindow.hide() # Hides Own Popup Menu
	emit_signal("character_created") # Alerts Player Selection Menu That It Can Continue Processing The Scene To Load (If Any)

func set_slot(character_slot: int) -> void:
	slot = character_slot
	logger.verbose("Selecting Slot %s for Creating Character" % character_slot)

func _about_to_show() -> void:
	old_title = functions.get_title()
	functions.set_title("Create Character")

func _about_to_hide() -> void:
	"""
		Reset Title to Before
		
		Not Meant to Be Called Directly
	"""
	
	functions.set_title(old_title)
