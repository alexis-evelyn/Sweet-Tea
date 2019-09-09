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
	
	mixer.init_song("test")
	mixer.start_alone("test", "Timer")
#	mixer.play("test")

func mixer_beat(beat: int):
	logger.debug("Beat: %s" % beat)

func mixer_bar(bar: int):
	logger.debug("Bar: %s" % bar)

func song_ended(track: int):
	logger.debug("Song Ended: %s" % track)

func mixer_shuffle(songs: Array):
	logger.debug("Songs Shuffled: %s" % songs)

	var current_track : int = songs[0]
	var next_track : int = songs[1]

func song_changed(songs: Array):
	logger.debug("Songs Changed: %s" % songs)

	var old_track : int = songs[0]
	var new_track : int = songs[1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
