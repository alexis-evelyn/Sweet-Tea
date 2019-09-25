extends Node

# This is specifically for Mazawalza!!! Nothing Else!!!

# Links
# https://conlang.stackexchange.com/a/1031/1369
# https://en.wikipedia.org/w/index.php?title=Blissymbols&oldid=915905921#Examples

# What Is Mazawalza
# Mazawalza is a magic based language for the lore of my game.
# As such, the concepts behind the characters will be geared toward spells and potions.
# Unlike Mincraft's random symbols with enchanting tables,
# I want these symbols to have meaning so that someone who puts the effort to learn to read it can understand what the spells and potions do.

# Declare member variables here. Examples:
var mazawalza : Dictionary = {
	# Tag (Dictionary Key), Unicode Representation, Meaning, Modifier, Etc...
	# Don't Access Dictionary Directly. Use Getter Function to Fill in Missing Info For Current Locale
	"language_name": {
		"character": "\udb80",
		"entry": "entry_language_name",
		"meaning": "meaning_language_name"
	},
	"language_name_closed": {
		"character": "\udb81",
		"entry": "entry_language_name_closed",
		"meaning": "meaning_language_name_closed"
	},
	"rs": {
		"character": "\udb82",
		"entry": "entry_",
		"meaning": "meaning_"
	},
	"rsc": {
		"character": "\udb83",
		"entry": "entry_",
		"meaning": "meaning_"
	},
	"s": {
		"character": "\udb84",
		"entry": "entry_",
		"meaning": "meaning_"
	},
	"sc": {
		"character": "\udb85",
		"entry": "entry_",
		"meaning": "meaning_"
	},
	"camera": {
		"character": "\udb86",
		"entry": "entry_camera",
		"meaning": "meaning_camera"
	},
	"camera_closed": {
		"character": "\udb87",
		"entry": "entry_camera_closed",
		"meaning": "meaning_camera_closed"
	},
	"effect_strength": {
		"character": "\udb88",
		"entry": "entry_effect_strength",
		"meaning": "meaning_effect_strength",
		"modifier": modifier.strength
	},
	"effect_weakness": {
		"character": "\udb89",
		"entry": "entry_effect_weakness",
		"meaning": "meaning_effect_weakness",
		"modifier": modifier.weakness
	},
	"eye": {
		"character": "\udb8a",
		"entry": "entry_eye",
		"meaning": "meaning_eye"
	},
	"eye_closed": {
		"character": "\udb8b",
		"entry": "entry_eye_closed",
		"meaning": "meaning_eye_closed"
	}
}

# May Use. May Not
var entry : String = "entry_"
var meaning : String = "meaning_"

# Effect Modifiers
enum modifier {
	strength = 0,
	weakness = 1
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
