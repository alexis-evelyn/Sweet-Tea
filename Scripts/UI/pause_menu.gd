extends Control
class_name PauseMenu

# Declare member variables here. Examples:
#onready var title : RichTextLabel = $background/Title
onready var resume_button : Button = $background/buttons/Resume
#onready var options_button : Button = $background/Options
#onready var open_to_lan_button : Button = $background/OpenToLan
#onready var quit_button : Button = $background/Quit

#var ui_select_group_name : String = "Pause Menu UI Select"

var paused : bool = false
var time_scale : float = 0.0

var pause_shaders : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_theme(gamestate.game_theme)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pause() -> void:
	# TODO (IMPORTANT): Detect if Game is Open to Lan

	resume_button.grab_focus()

	paused = true
	get_tree().paused = true
	self.visible = true

	# This is to pause shaders
	# If this causes trouble with say animations on the pause menu, I may have to find another solution for shaders
	if pause_shaders:
		time_scale = Engine.time_scale
		Engine.time_scale = 0.0

func resume() -> void:
	# TODO (IMPORTANT): Detect if Game is Open to Lan

	paused = false
	get_tree().paused = false
	self.visible = false

	# This is to pause shaders
	# If this causes trouble with say animations on the pause menu, I may have to find another solution for shaders
	if pause_shaders:
		Engine.time_scale = time_scale

func open_to_lan() -> void:
	# Look at LanFinder Helper and Make Sure It Isn't Activated Until Open to Lan
	# Also Look at Network Too and Change If Accepting New Players
	pass

func set_theme(theme: Theme) -> void:
	.set_theme(theme)

func get_class() -> String:
	return "PauseMenu"


func options():
	pass # Replace with function body.


func quit():
	network.close_connection()
	resume()
