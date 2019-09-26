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
		"meaning": "meaning_language_name",
		"effect": effect.language_name
	},
	"language_name_closed": {
		"character": "\udb81",
		"entry": "entry_language_name_closed",
		"meaning": "meaning_language_name_closed",
		"effect": effect.language_name_closed
	},
	"rs": {
		"character": "\udb82",
		"entry": "entry_",
		"meaning": "meaning_",
		"effect": effect.rs
	},
	"rsc": {
		"character": "\udb83",
		"entry": "entry_",
		"meaning": "meaning_",
		"effect": effect.rsc
	},
	"s": {
		"character": "\udb84",
		"entry": "entry_",
		"meaning": "meaning_",
		"effect": effect.s
	},
	"sc": {
		"character": "\udb85",
		"entry": "entry_",
		"meaning": "meaning_",
		"effect": effect.sc
	},
	"camera": {
		"character": "\udb86",
		"entry": "entry_camera",
		"meaning": "meaning_camera",
		"effect": effect.camera
	},
	"camera_closed": {
		"character": "\udb87",
		"entry": "entry_camera_closed",
		"meaning": "meaning_camera_closed",
		"effect": effect.camera_closed
	},
	"effect_strength": {
		"character": "\udb88",
		"entry": "entry_effect_strength",
		"meaning": "meaning_effect_strength",
		"modifier": modifier.strength,
	},
	"effect_weakness": {
		"character": "\udb89",
		"entry": "entry_effect_weakness",
		"meaning": "meaning_effect_weakness",
		"modifier": modifier.weakness,
	},
	"eye": {
		"character": "\udb8a",
		"entry": "entry_eye",
		"meaning": "meaning_eye",
		"effect": effect.eye
	},
	"eye_closed": {
		"character": "\udb8b",
		"entry": "entry_eye_closed",
		"meaning": "meaning_eye_closed",
		"effect": effect.eye_closed
	},
	"confusion": {
		"character": "\udb8c",
		"entry": "entry_confusion",
		"meaning": "meaning_confusion",
		"effect": effect.confusion
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

# Effects
enum effect {
	language_name = 0,
	language_name_closed = 1,
	rs = 2,
	rsc = 3,
	s = 4,
	sc = 5,
	camera = 6,
	camera_closed = 7,
	eye = 8,
	eye_closed = 9,
	confusion = 10
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_effects() -> Array:
	return mazawalza.keys()

func get_effect_detail(effect_name: String) -> Dictionary:
	if not mazawalza.has(effect_name):
		# Do Something
		pass

	return mazawalza.get(effect_name)

func search_dictionary(some_kind_of_search_in_dictionary_form: Dictionary) -> Dictionary:
	# Perform Search Here!!!

	return mazawalza # Replace Me With Results From Search
