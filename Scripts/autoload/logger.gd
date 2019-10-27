extends Node
class_name Logger

# This logger exists so that I can log to file (with varying log verbosities) and if I figure out how to implement system logging,
# then I will be logging to the system log too. This is very useful for the crash handler (especially when the game is in alpha stage).

# Declare member variables here. Examples:
var verbosity : int = values.debug
var save_to_drive : bool = true

var log_data : File
var log_dir : Directory
var log_dir_path : String = OS.get_user_data_dir().plus_file("logs")
var log_file_path : String = log_dir_path.plus_file("%s.log" % OS.get_unix_time())

enum values {
	fatal = 0,
	error = 1,
	warning = 2,
	warn = 2,
	info = 3,
	debug = 4,
	verbose = 5,
	superverbose = 6
}

func create_log():
	if save_to_drive:
		log_dir = Directory.new()

		if not log_dir.dir_exists(log_dir_path): # Check If Regular Logs Folder Exists
			#logger.verbose("Creating Regular Logs Folder!!!")
			log_dir.make_dir(log_dir_path)

		log_data = File.new()
		log_data.open(log_file_path, File.WRITE)

func debug(statement: String = functions.empty_string):
	if verbosity >= values.debug:
		print(statement)

	if save_to_drive:
		flush_to_log("Debug: %s" % statement)

func info(statement: String = functions.empty_string):
	if verbosity >= values.info:
		print(statement)

	if save_to_drive:
		flush_to_log("Info: %s" % statement)

func verbose(statement: String = functions.empty_string):
	if verbosity >= values.verbose:
		print(statement)

	if save_to_drive:
		flush_to_log("Verbose: %s" % statement)

func superverbose(statement: String = functions.empty_string):
	if verbosity >= values.superverbose:
		print(statement)

	if save_to_drive:
		flush_to_log("SuperVerbose: %s" % statement)

func warn(statement: String = functions.empty_string):
	if verbosity >= values.warning:
		printerr("Warning: %s" % statement)
		push_warning("Warning: %s" % statement)

	if save_to_drive:
		flush_to_log("Warning: %s" % statement)

# This is because I apparently can't remember if I used warn or warning, so I am adding both.
func warning(statement: String = functions.empty_string):
	warn(statement)

func error(statement: String = functions.empty_string):
	if verbosity >= values.error:
		push_error("Error: %s" % statement)
		printerr("Error: %s" % statement)

	if save_to_drive:
		flush_to_log("Error: %s" % statement)

func fatal(statement: String = functions.empty_string):
	if verbosity >= values.fatal:
		push_error("Fatal: %s" % statement)
		printerr("Fatal: %s" % statement)

	if save_to_drive:
		flush_to_log("Fatal: %s" % statement)

# Not Meant To Be Printed
func file(statement: String = functions.empty_string):
	if save_to_drive:
		flush_to_log("File: %s" % statement)

func trace(statement: String = functions.empty_string):
	if verbosity >= values.fatal:
		printerr("If trace does not show up, it means Godot still doesn't support stacktraces in exported games. Try breaking the game in the Godot editor (you will need the source code at https://github.com/alex-evelyn/Sweet-Tea)")
		printerr("Error: '%s' Trace: '%s'" % [statement, get_stack()])
		push_error("Error: '%s' Trace: '%s'" % [statement, get_stack()])

	if save_to_drive:
		flush_to_log("Error: '%s' Trace: '%s'" % [statement, get_stack()])

func flush_to_log(line: String):
	log_data.store_string(line + "\n")

func _exit_tree():
	if save_to_drive:
		log_data.close()

func get_class() -> String:
	return "Logger"
