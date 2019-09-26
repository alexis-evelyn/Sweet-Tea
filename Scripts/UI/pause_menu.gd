extends Control
class_name PauseMenu

# Declare member variables here. Examples:
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