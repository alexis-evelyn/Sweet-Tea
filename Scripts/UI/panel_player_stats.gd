extends Panel
class_name PlayerStats

# panelPlayerStats is meant for information like health and a hotbar

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	self.hide() # Keeps Player Stats From Stealing Input From Other Nodes in the Menus
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

# Cleanup PlayerStats - Meant to be Called by PlayerUI
func cleanup() -> void:
	pass

func get_class() -> String:
	return "PlayerStats"
