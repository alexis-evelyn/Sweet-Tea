extends Control
class_name PauseMenu

# Declare member variables here. Examples:
#onready var title : RichTextLabel = $background/Title
onready var resume_button : Button = $background/buttons/Resume
#onready var options_button : Button = $background/buttons/Options
onready var open_to_lan_button : Button = $background/buttons/OpenToLan
#onready var quit_button : Button = $background/buttons/Quit

#var ui_select_group_name : String = "Pause Menu UI Select"

var paused : bool = false # Marks if Game is Paused
var time_scale : float = 0.0 # Store Game's Timescale (Usually 1.0)

var pause_shaders : bool = true # Pause Shaders
var is_open_to_lan : bool = false # Mark whether game is open to lan or not

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

	if not is_open_to_lan:
		get_tree().paused = true

	self.visible = true

	# This is to pause shaders
	# If this causes trouble with say animations on the pause menu, I may have to find another solution for shaders
	if pause_shaders and not is_open_to_lan:
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

	var net : NetworkedMultiplayerENet = get_tree().get_network_peer() # Get Current Network Peer

	net.set_refuse_new_connections(false) # Allow New Connections
	network.start_server_finder_helper() # Start Lan Server Finder Helper

	# Do I Want Close to Lan?
	open_to_lan_button.set_disabled(true) # Disabled Open to Lan Button
	open_to_lan_button.focus_mode = Control.FOCUS_NONE # Disable Ability to Focus on Button

	is_open_to_lan = true # Mark that game is open to lan

	resume() # Resume Game

func is_paused() -> bool:
	return paused

func set_theme(theme: Theme) -> void:
	.set_theme(theme)

func get_class() -> String:
	return "PauseMenu"

func options():
	pass # Replace with function body.

func quit():
	open_to_lan_button.set_disabled(false) # Enable Open to Lan Button
	open_to_lan_button.focus_mode = Control.FOCUS_ALL # Enable Ability to Focus on Button
	is_open_to_lan = false # Mark that game is not open to lan

	network.close_connection()
	resume()
