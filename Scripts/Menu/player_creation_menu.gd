extends Control

# Declare member variables here. Examples:
var old_title : String = "" # Title From Before Window Was Shown
var character_slot : int # Save Slot to Use

# Called when the node enters the scene tree for the first time.
func _ready():
	#$PlayerCreationWindow.window_title = "Hello" # Can be used for translation code
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_slot(slot: int) -> void:
	character_slot = slot
	logger.verbose("Creating Character At Slot %s" % character_slot)

func _about_to_show() -> void:
	old_title = functions.get_title()
	functions.set_title("Create Character")

func _about_to_hide() -> void:
	"""
		Reset Title to Before
		
		Not Meant to Be Called Directly
	"""
	
	functions.set_title(old_title)
