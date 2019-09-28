extends WindowDialog
class_name Mazawalza_Dictionary_Detailed

# Declare member variables here. Examples:
onready var character : RichTextLabel = $background/character
onready var entry : RichTextLabel = $background/entry
onready var meaning : RichTextLabel = $background/meaning

# Called when the node enters the scene tree for the first time.
func _ready():
	# Listens for cleanup_ui signal. Allows cleaning up on server shutdown.
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

	# Sets the Dictionary's Theme
	set_theme(gamestate.game_theme)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func populate(json: Dictionary) -> void:
	self.window_title = "TR - Modifier or Effect"

	character.bbcode_text = "[font=%s]%s[/font]" % [gamestate.mazawalza_regular.resource_path, json.character]
	entry.text = "%s" % [tr(json.entry)]
	meaning.text = "%s" % [tr(json.meaning)]

	# Show Dictionary
	popup_detailed_dictionary()

# Sets Dictionary's Theme
func set_theme(theme: Theme) -> void:
	# https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	.set_theme(theme) # This is Godot's version of a super
#	entries.set_theme(theme) # Entries ItemList

# Cleanup Dictionary and Free Itself From Memory
func cleanup():
	#logger.verbose("Close Dictionary...")
	self.hide() # Hides Dictionary Window
	get_parent().queue_free() # Frees Dictionary From Memory

func get_class() -> String:
	return "Mazawalza_Dictionary_Detailed"

# Show Dictionary Window
func popup_detailed_dictionary() -> void:
	#get_tree().set_input_as_handled()

	var dict_x : float = (get_tree().get_root().size.x/2) - (self.get_rect().size.x/2)
	var dict_y : float = (get_tree().get_root().size.y/2) - (self.get_rect().size.x/2)

	self.set_position(Vector2(dict_x, dict_y))
	self.call_deferred("show")

func _about_to_show() -> void:
	pass # Replace with function body.

func _dict_hide() -> void:
	pass # Replace with function body.
