extends Control
class_name LoadingScreen

# Declare member variables here. Examples:
# warning-ignore:unused_class_variable
onready var loading_bar : Node = $background/loadingBar
# warning-ignore:unused_class_variable
onready var loading_bar_plain : Node = $background/loadingBarPlain

# Called when the node enters the scene tree for the first time.
func _ready():
	loading_bar_plain.value = 0
	
	world_handler.connect("world_created", self, "world_created")
	world_handler.connect("world_loaded_server", self, "world_loaded_server")
	world_handler.connect("world_loaded_client", self, "world_loaded_client")

func get_class() -> String:
	return "LoadingScreen"

func world_created():
	logger.debug("World Loaded Created!!!")
	close_loading_screen()
	
func world_loaded_server():
	logger.debug("World Loaded Server!!!")
	loading_bar_plain.value = 100
	close_loading_screen()
	
func world_loaded_client():
	logger.debug("World Loaded Client!!!")
	close_loading_screen()
	
func close_loading_screen():
	self.queue_free()
