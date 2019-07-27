extends Panel

# panelPlayerStats is meant for information like health and a hotbar

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Cleanup PlayerStats - Meant to be Called by PlayerUI
func cleanup():
	pass