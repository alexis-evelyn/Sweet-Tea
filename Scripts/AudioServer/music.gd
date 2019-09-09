extends Node

# Mixer Desk Music ReadMe - https://github.com/kyzfrintin/Godot-Mixing-Desk/blob/master/readme.md

# Declare member variables here. Examples:
#onready var mixer : MixingDeskMusic = $MixingDeskMusic
onready var scatter_sound = $ScatterSoundContainer

# Called when the node enters the scene tree for the first time.
func _ready():
#	mixer.bar(3)
#	scatter_sound.play()
	
	logger.error("Mixer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
