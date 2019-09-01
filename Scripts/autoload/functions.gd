extends Node
class_name Functions

# get_class() - https://godotengine.org/qa/46057/how-to-get-the-class-name-of-a-custom-node?show=46059#a46059

# Declare member variables here. Examples:
var current_title : String = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# I may replace the default window title bar with my own. - https://www.youtube.com/watch?v=alKdkRJy-iY&list=PL0t9iz007UitFwiu33Vx4ZnjYQHH9th2r&index=4&t=0s
func set_title(title: String):
	current_title = title
	OS.set_window_title(title) # Sets Window's Title

# Gets Title of Window
func get_title() -> String:
	# There is no builtin way to get the window title, so I have to store it in a variable. - https://github.com/godotengine/godot/issues/27536
	return current_title

# While this is no longer used as Github user merumelu helped me out with reading the .translation files, but I am keeping it here incase it becomes useful later.
# For example, I don't know if the Godot engine can generate translation files after the game is built, so I may build in an interface to let users produce their own translation in game and then just save it in csv format.
func get_translation_csv(translations_file: String, key: String, locale: String) -> String:
	#var translations_file : String = ProjectSettings.get_setting("locale/csv")
	
	var file = File.new()
	var open_csv_status = file.open(translations_file, file.READ)
	
	# Make sure there is at least one line available to read, otherwise just return
	if open_csv_status != OK:
		logger.error("Failed to find locale '%s' for key '%s' because the csv file '%s' couldn't be opened!!!" % [locale, key, translations_file])
		file.close()
		return ""
	
	if file.eof_reached():
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is empty!!!" % [locale, key, translations_file])
		file.close()
		return ""
	
	var index : int = -1 # Column that Locale Is On
	var line : Array = Array(file.get_csv_line()) # Get first line of csv file
		
	# If it does not have the locale requested, then just return
	if not line.has(locale):
		logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' is does not have the locale!!!" % [locale, key, translations_file])
		file.close()
		return ""
		
	index = line.find(locale) # Get column the locale is on
	
	while !file.eof_reached():
		line = Array(file.get_csv_line())
		
		if line[0] == key:
			#print("Translation: %s" % line[index])
			file.close()
			return line[index]
	
	logger.warn("Failed to find locale '%s' for key '%s' because the csv file '%s' does not have the key!!!" % [locale, key, translations_file])
	file.close()
	return "" # If it does not have the key, then just return

# Get Translation For Specified Locale
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_translation(key: String, locale: String) -> String:
	# Thank merumelu for their help on my reading translation files issue: https://github.com/godotengine/godot/issues/31749
	
	# Also make sure to add support for po files later.
	var translations : PoolStringArray = ProjectSettings.get_setting("locale/translations")
	# warning-ignore:unassigned_variable
	var selected_translation : PoolStringArray

	for translation in translations:
		#res://Assets/Languages/default.pr.translation
		var translation_locale : String = translation.rsplit(".", false, 2)[1]
		#print("Translation File: %s" % translation_locale)
		
		if translation_locale == locale:
			selected_translation.append(translation)
		
	# If No Translation File Found, Then Just Return. This will crash on debug builds, but not release builds.
	if selected_translation.size() == 0:
		logger.error("No Translation File Found For Locale '%s'" % locale)
		return "No Translation File Found For Locale '%s'" % locale
		
	var translator : Translation = load(selected_translation[0]) # I may add support for searching more than one file of the same locale later.
	var message = translator.get_message(key)
	
	# Should I check if the translation came back successful or will translator handle it for me?
	
	#print("Message: %s" % message)
	
	return message

func get_class() -> String:
	return "Functions"
	
# I don't have a use for this yet, so I am just leaving this here.
func _to_string() -> String:
	return "Hello"
