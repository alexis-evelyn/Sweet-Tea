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
	
	world_handler.connect("found_world_data", self, "found_world_data")
	world_handler.connect("loaded_world_grid", self, "loaded_world_grid")
	world_handler.connect("added_players_node", self, "added_players_node")
	world_handler.connect("loaded_template", self, "loaded_template")
	
	world_handler.connect("loaded_foreground_chunks", self, "loaded_foreground_chunks")
	world_handler.connect("loaded_background_chunks", self, "loaded_background_chunks")
	world_handler.connect("loaded_foreground_tiles", self, "loaded_foreground_tiles")
	world_handler.connect("loaded_background_tiles", self, "loaded_background_tiles")
	
	world_handler.connect("missing_starting_world", self, "failed_loading_world")
	world_handler.connect("missing_starting_world_reference", self, "failed_loading_world")
	world_handler.connect("missing_current_world_reference", self, "failed_loading_world")
	world_handler.connect("failed_loading_world", self, "failed_loading_world")

func get_class() -> String:
	return "LoadingScreen"

# Both
func found_world_data():
	logger.debug("Loading Screen - Found World Data!!!")
	set_progress_value(10)

# Already Existing World	
func loaded_world_grid():
	logger.debug("Loading Screen - Loaded World Grid!!!")
	set_progress_value(15)
	
# Already Existing World	
func added_players_node():
	logger.debug("Loading Screen - Added Players Node!!!")
	set_progress_value(20)
	
# New World
func loaded_template():
	logger.debug("Loading Screen - Loaded Templates!!!")
	set_progress_value(20)
	
# New World
func loaded_foreground_chunks():
	logger.debug("Loading Screen - Loaded Foreground Chunks!!!")
	set_progress_value(30)
	
# New World
func loaded_background_chunks():
	logger.debug("Loading Screen - Loaded Background Chunks!!!")
	set_progress_value(40)
	
# New World
func loaded_foreground_tiles():
	logger.debug("Loading Screen - Loaded Foreground Tiles!!!")
	set_progress_value(50)
	
# New World
func loaded_background_tiles():
	logger.debug("Loading Screen - Loaded Background Tiles!!!")
	set_progress_value(60)

func failed_loading_world():
	logger.debug("Loading Screen - Failed Loading World!!!")
#	get_tree().change_scene(main_menu)
	network.close_connection()
	close_loading_screen()

func world_created():
	logger.debug("Loading Screen - World Created!!!")
	set_progress_value(100)
	close_loading_screen()
	
func world_loaded_server():
	logger.debug("Loading Screen - Server World Loaded!!!")
	set_progress_value(100)
	close_loading_screen()
	
func world_loaded_client():
	logger.debug("Loading Screen - World Loaded Client!!!")
	set_progress_value(100)
	close_loading_screen()
	
func close_loading_screen():
#	gamestate.reset_player_info() # Clear GameState Player's Info!!!
	self.queue_free()

func set_progress_value(ending_value: int) -> void:
	var bar : Node = loading_bar_plain
	var starting_value : int = bar.value
	
	if starting_value < ending_value:
		# Add Value
		while bar.value != ending_value:
			bar.value = (bar.value + 1)
	elif starting_value > ending_value:
		# Subtract Value
		while bar.value != ending_value:
			bar.value = (bar.value - 1)
