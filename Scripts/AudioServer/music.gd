extends Node

# Mixer Desk Music ReadMe - https://github.com/kyzfrintin/Godot-Mixing-Desk/blob/master/readme.md

# Declare member variables here. Examples:
onready var mixer : MixingDeskMusic = $MixingDeskMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	mixer.connect("beat", self, "mixer_beat")
	mixer.connect("bar", self, "mixer_bar")
	mixer.connect("end", self, "song_ended")
	mixer.connect("shuffle", self, "mixer_shuffle")
	mixer.connect("song_changed", self, "song_changed")

#	mixer.init_song("test")
#	mixer.init_song("SonicPi - Acid Walk")
	mixer.init_song("Title Song")

#	mixer.start_alone("test", "Timer")
#	mixer.start_alone("SonicPi - Acid Walk", "Acid Walk")
#	mixer.start_alone("Title Song", "Modern Plague")

	mixer.play("Title Song")

func add_audio_effect() -> void:
	var custom_effect : AudioEffect = AudioEffect.new()
#	custom_effect.
	pass

func mixer_beat(beat: int):
	logger.debug("Beat: %s" % beat)

func mixer_bar(bar: int):
	logger.debug("Bar: %s" % bar)

func song_ended(track: int):
	logger.debug("Song Ended: %s" % track)

func mixer_shuffle(songs: Array):
	var current_track : int = songs[0]
	var next_track : int = songs[1]

	logger.debug("Songs Shuffled - Current Track: %s - Next Track: %s" % [current_track, next_track])

func song_changed(songs: Array):
	var old_track : int = songs[0]
	var new_track : int = songs[1]

	logger.debug("Songs Changed - Old Track: %s - New Track: %s" % [old_track, new_track])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
