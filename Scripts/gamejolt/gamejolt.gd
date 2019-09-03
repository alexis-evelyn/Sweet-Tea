extends Node
class_name GameJoltFunctions

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# GameJolt Plugin API Source: https://github.com/rojekabc/-godot-gj-api
# GameJolt Client Issues: https://github.com/gamejolt/gamejolt/issues/309

signal function_finished

onready var api = $GameJoltAPI

var gamejolt_credentials_name = ".gj-credentials"
var executable_directory = get_executable_folder()
var protocol = ""
var gamejolt_auth_path = protocol.plus_file(executable_directory.plus_file(gamejolt_credentials_name))

# Called when the node enters the scene tree for the first time.
func _ready():
	if not gamestate.server_mode:
		#debug_auth_path()
		#test()
		pass

func debug_auth_path():
	var output = []
	OS.execute('export', [], true, output)
	
	var test = File.new()
	test.open("user://testgodot.txt", File.WRITE)
	test.store_string(gamejolt_auth_path + "\n\n")
	
	test.store_string(str(output))
	test.close()

func test():
	# There is no real way to protect the API key and a bad actor will be able to get it anyway.
	# So, instead of wasting my time trying to hide it from people, I am just putting it in ProjectSettings
	# I least it can only be tied to the bad actor's accounts.
	var api_key = ProjectSettings.get_setting("application/config/Gamejolt API Key")
	var game_id = ProjectSettings.get_setting("application/config/Gamejolt Game ID")
	api.init(game_id, api_key)
	
	var gamejolt_auth = File.new()
	
	#logger.verbose("Credentials: %s" % gamejolt_auth.file_exists(gamejolt_auth_path))
	#logger.verbose("Path: %s" % gamejolt_auth_path)

	if gamejolt_auth.file_exists(gamejolt_auth_path):
		gamejolt_auth.open(gamejolt_auth_path, File.READ)
	
		var auth = PoolStringArray()
		while not gamejolt_auth.eof_reached():
			auth.append(gamejolt_auth.get_line())
	
		gamejolt_auth.close()
		
		if auth.size() >= 3:
			var name : String = auth[1]
			var token : String = auth[2]
			
			login(name, token)
			yield(self, "function_finished") # Wait Until Function is Finished
			
			get_gj_time()
			yield(self, "function_finished") # Wait Until Function is Finished
			
			get_trophies()
			yield(self, "function_finished") # Wait Until Function is Finished
			
			toggle_trophy("109979")
			yield(self, "function_finished") # Wait Until Function is Finished
	else:
		logger.error("GameJolt File Not Found")
	
func login(name: String, token: String):
	# There's a user friendly token on GameJolt's site. This token functions in place of the one inside the gamejolt file.
	api.auth_user(name, token)
	
	var result = yield(api, 'gamejolt_request_completed')
	if api.is_ok(result):
		logger.verbose("Successful Login: %s" % result.responseBody.success)
	else:
		api.print_error(result)
		
	emit_signal("function_finished")
	
func get_gj_time():
	api.fetch_time()
	var result = yield(api, 'gamejolt_request_completed')
	if api.is_ok(result):
		logger.verbose("GameJolt's Server's Time: %s" % result.responseBody.timestamp)
	else:
		api.print_error(result)
		
	emit_signal("function_finished")
	
func get_trophies():
	api.fetch_trophy()
	var result = yield(api, 'gamejolt_request_completed')
	if api.is_ok(result):
		loop_trophies(result.responseBody.trophies)
	else:
		api.print_error(result)
		
	emit_signal("function_finished")
	
func loop_trophies(trophies: Array):
	for trophy in trophies:
		logger.verbose("Trophy Name: %s - ID: %s - Achieved: %s" % [trophy.title, trophy.id, trophy.achieved])

func toggle_trophy(trophy: String):
	api.fetch_trophy(trophy)
	var result = yield(api, 'gamejolt_request_completed')
	if api.is_ok(result):
		var trophies = result.responseBody.trophies
		
		if trophies.size() > 0:
			var achieved = trophies[0].achieved
			
			if achieved == "false":
				api.set_trophy_achieved(trophy)
				#logger.verbose("Trophy Achieved: %s" % trophies[0].title)
			else:
				api.remove_trophy_achieved(trophy)
				#logger.verbose("Trophy Removed: %s" % trophies[0].title)
	else:
		api.print_error(result)
		
	emit_signal("function_finished")

func get_executable_folder():
	# Keeps folder in Project Directory (will probably bug out on OSX if running a debug build outside the editor)
	# Godot Keeps Defaulting Back to Debug Mode and I Keep Forgetting to Change Exports Back to Release Mode, So I Am Disabling This
#	if OS.is_debug_build(): #Engine.is_editor_hint(): is for if running inside editor (put tool at top of file)
#		return ""
	
	var path = OS.get_executable_path()
	
	# Godot on OSX will try to return a path inside the .app file. Back out of that directory.
	if OS.get_name() == "OSX":
		var split_path = path.rsplit(".app", false, 1)
		
		return split_path[0].rsplit("/", true, 1)[0]
		
	# TODO: Test to make sure this works
	return path[0].rsplit("/", true, 1)[0]

func get_class() -> String:
	return "GameJoltFunctions"
