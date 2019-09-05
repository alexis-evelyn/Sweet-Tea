extends Control
class_name LoadingScreen

# Declare member variables here. Examples:
# warning-ignore:unused_class_variable
onready var loading_bar : Node = $background/loadingBar
# warning-ignore:unused_class_variable
onready var loading_bar_plain : Node = $background/loadingBarPlain

var main_menu : String = "res://Menus/MainMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	loading_bar_plain.value = 0
	
	world_handler.connect("world_created", self, "world_created")
	world_handler.connect("world_loaded_server", self, "world_loaded_server")
	world_handler.connect("world_loaded_client", self, "world_loaded_client")
	
	world_handler.connect("missing_starting_world", self, "failed_loading_world")
	world_handler.connect("missing_starting_world_reference", self, "failed_loading_world")
	world_handler.connect("missing_current_world_reference", self, "failed_loading_world")
	world_handler.connect("failed_loading_world", self, "failed_loading_world")

func get_class() -> String:
	return "LoadingScreen"

func failed_loading_world():
#	get_tree().change_scene(main_menu)
	network.close_connection()
	close_loading_screen()

func world_created():
	logger.debug("World Created!!!")
	loading_bar_plain.value = 100
	close_loading_screen()
	
func world_loaded_server():
	logger.debug("World Loaded Server!!!")
	loading_bar_plain.value = 100
	close_loading_screen()
	
func world_loaded_client():
	logger.debug("World Loaded Client!!!")
	loading_bar_plain.value = 100
	close_loading_screen()
	
func close_loading_screen():
#	gamestate.reset_player_info() # Clear GameState Player's Info!!!
	
	self.queue_free()
