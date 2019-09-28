extends WindowDialog
class_name Mazawalza_Dictionary

# Declare member variables here. Examples:
onready var entries : ItemList = $background/entries
onready var details : Node = get_parent().get_node("DetailedInfo")

var dictionary = preload("res://Scripts/functions/dictionary_registry.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.window_title = tr("dictionary_title")

	# Listens for cleanup_ui signal. Allows cleaning up on server shutdown.
	get_tree().get_root().get_node("PlayerUI").connect("cleanup_ui", self, "cleanup") # Register With PlayerUI Cleanup Signal - Useful for Modders

	# ItemList Handling - https://docs.godotengine.org/en/3.1/classes/class_itemlist.html
	entries.connect("item_selected", self, "item_selected") # Detect Selected Item
	entries.connect("item_activated", self, "item_activated") # Detect When Item Is Double Clicked (or Enter Pressed)

	# Sets the Dictionary's Theme
	set_theme(gamestate.game_theme)

	populate_dictionary() # Add Entries to Dictionary

	# Show Dictionary
	popup_dictionary()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func populate_dictionary() -> void:
	# How do I make a searchable dictionary efficiently?
#	var output : String = "[font=%s]" % gamestate.mazawalza_regular.resource_path
	var item_text : String # Item Text For ItemList
	var item_hint : String # Item Hint For Hovering Over ItemList
	# warning-ignore:unused_variable
	var entry : Dictionary # Detailed Dictionary of Entry
	# warning-ignore:unused_variable
	var player_locale_entry : String # Current Locale's Definition of Entry
#	var mazawalza_locale_entry : String # Mazawalza's Unicode Symbol
#	var font : DynamicFont = gamestate.mazawalza_regular # Font to Use For Mazawalza
	var font_image : Image = Image.new() # Image Loader for Mazawalza Symbols

	for entry in dictionary.get_effects():
		# Don't Allow Modifiers to Show Up
		if dictionary.get_effect_detail(entry).has("modifier"):
#			continue # Skip To Next Loop
			pass # NOP

		entry = dictionary.get_effect_detail(entry) # Get Dictionary For Effect
#		mazawalza_locale_entry = functions.parse_for_unicode(functions.get_translation(entry.entry, "mz"))

		# Don't Allow Empty Entries
#		if mazawalza_locale_entry.strip_edges().empty():
#			continue

		# http://docs.godotengine.org/en/3.0/classes/class_image.html
		font_image.load(entry.image) # Load Image From Resource Path
		font_image.lock() # Allows Editing But Prevents Other Resources/Threads From Accessing
		font_image.resize(64, 64, 1) # Size To Use and Interpolation
		font_image.unlock() # Disables Editing, But Allows Access By Other Resources/Threads

		var font_icon : ImageTexture = ImageTexture.new() # Placed Here To Create New Texture Every Loop
		font_icon.create_from_image(font_image) # Create Texture From ImageTexture

#		output += "%s: %s\n" % [player_locale_entry, mazawalza_locale_entry]
		item_text = tr(entry.meaning) # Get Current Locale's Definition of Entry
		item_hint = tr(entry.entry) # Get Current Locale's Definition of Entry
		entries.add_item(item_text, font_icon, true) # Text, Icon, Selectable
		entries.set_item_metadata(entries.get_item_count() - 1, entry) # Useful for Storing More Info The Displayed to Users - Can be Used When Entry is Clicked
		entries.set_item_tooltip(entries.get_item_count() - 1, item_hint)

#	output += "[/font]"

# Show Dictionary Window
func popup_dictionary() -> void:
	#get_tree().set_input_as_handled()

	var dict_x : float = (get_tree().get_root().size.x/2) - (self.get_rect().size.x/2)
	var dict_y : float = (get_tree().get_root().size.y/2) - (self.get_rect().size.x/2)

	self.set_position(Vector2(dict_x, dict_y))
	self.call_deferred("show")

# Sets Dictionary's Theme
func set_theme(theme: Theme) -> void:
	# https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_basics.html#inheritance
	.set_theme(theme) # This is Godot's version of a super
	entries.set_theme(theme) # Entries ItemList

# Cleanup Dictionary and Free Itself From Memory
func cleanup():
	#logger.verbose("Close Dictionary...")
	self.hide() # Hides Dictionary Window
	get_parent().queue_free() # Frees Dictionary From Memory

func get_class() -> String:
	return "Mazawalza_Dictionary"

func item_selected(index: int) -> void:
	var json : Dictionary = entries.get_item_metadata(index)

	logger.debug("Selected Item: %s" % index)
	logger.superverbose("Metadata: %s" % json)

func item_activated(index: int) -> void:
	var json : Dictionary = entries.get_item_metadata(index)

	logger.debug("Activated Item: %s" % index)
	logger.superverbose("Metadata: %s" % json)

	details.populate(json)

func _about_to_show() -> void:
	pass # Replace with function body.

func _dict_hide() -> void:
	pass # Replace with function body.
