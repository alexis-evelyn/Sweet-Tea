extends Node

# Declare member variables here. Examples:
var current_title : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# I may replace the default window title bar with my own. - https://www.youtube.com/watch?v=alKdkRJy-iY&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r&index=4&t=0s
func set_title(title: String):
	current_title = title
	OS.set_window_title(title) # Sets Window's Title

# Gets Title of Window
func get_title():
	# There is no builtin way to get the window title, so I have to store it in a variable. - https://github.com/godotengine/godot/issues/27536
	return current_title

func get_translation(key: String, locale: String) -> String:
	var translations_file : String = ProjectSettings.get_setting("locale/csv")
	
	var file = File.new()
	var open_csv_status = file.open(translations_file, file.READ)
	
	# Make sure there is at least one line available to read, otherwise just return
	if open_csv_status != OK:
		logger.error("Failed to find locale '%s' for key '%s' because the csv file '%s' couldn't be opened!!!" % [locale, key, translations_file])
		return ""
	
	if file.eof_reached():
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is empty!!!" % [locale, key, translations_file])
		return ""
	
	var index : int = -1 # Column that Locale Is On
	var line : Array = Array(file.get_csv_line()) # Get first line of csv file
		
	# If it does not have the locale requested, then just return
	if not line.has(locale):
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is does not have the locale!!!" % [locale, key, translations_file])
		return ""
		
	index = line.find(locale) # Get column the locale is on
	
	while !file.eof_reached():
		line = Array(file.get_csv_line())
		
		if line[0] == key:
			#print("Translation: %s" % line[index])
			file.close()
			return line[index]
	
	logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' does not have the key!!!" % [locale, key, translations_file])
	return "" # If it does not have the key, then just return

# Get Translation For Specified Locale
# Currently, I cannot find a way to read the .translation files directly, so I am just holding off on this.
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_translation_experimental(key: String, locale: String) -> String:
	# Also make sure to add support for po files later.
#	var translations : PoolStringArray = ProjectSettings.get_setting("locale/translations")
#
#	for translation in translations:
#		print("Translation File: %s" % translation)
	
	var translator : Translation = Translation.new()
	
#	translator.generate(load("res://Assets/Languages/default.en.translation"))
	
#	translator.set_locale("pr")
#	translator.add_message("create_character_title", "Test")
#
#	translator.set_locale("en")
#	translator.add_message("create_character_title", "Test 2")
#
#	print("Locale B: %s" % translator.locale)
#	translator.set_locale("pr")
#	print("Locale A: %s" % translator.locale)

	var message = translator.get_message("create_character_title")
	
	print("Message: %s" % message)
	
	return "Not Set"
