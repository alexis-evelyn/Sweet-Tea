extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# GameJolt Plugin API Source: https://github.com/rojekabc/-godot-gj-api

onready var api = $GameJoltAPI

var gamejolt_credentials_name = ".gj-credentials"
var executable_directory = get_executable_folder()
var protocol = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	test()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func test():
	var gamejolt_auth_path = protocol.plus_file(executable_directory.plus_file(gamejolt_credentials_name))
	
	# There is no real way to protect the API key and a bad actor will be able to get it anyway.
	# So, instead of wasting my time trying to hide it from people, I am just putting it in ProjectSettings
	# I least it can only be tied to the bad actor's accounts.
	var api_key = ProjectSettings.get_setting("application/config/Gamejolt API Key")
	var game_id = ProjectSettings.get_setting("application/config/Gamejolt Game ID")
	api.init(game_id, api_key)
	
	var gamejolt_auth = File.new()
	
#	print("Credentials: ", gamejolt_auth.file_exists(gamejolt_auth_path))
#	print("Path: ", gamejolt_auth_path)

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
	
func login(name: String, token: String):
	api.auth_user(name, token)
	
	var result = yield(api, 'gamejolt_request_completed')
	if api.is_ok(result):
		print("Successful Login: ", result.responseBody.success)
	else:
		api.print_error(result)
	
	api.fetch_time()
	result = yield(api, 'gamejolt_request_completed')
	if api.is_ok(result):
		print("GameJolt's Server's Time: ", result.responseBody.timestamp)
	else:
		api.print_error(result)
	
func get_executable_folder():
	# Keeps folder in Project Directory (will probably bug out on OSX if running a debug build outside the editor)
	if OS.is_debug_build(): #Engine.is_editor_hint(): is for if running inside editor (put tool at top of file)
		return ""
	
	# Godot on OSX will try to return a path inside the .app file. Back out of that directory.
	if OS.get_name() == "OSX":
		var path = OS.get_executable_path()
		var split_path = path.rsplit(".app", false, 1)
		
		return split_path[0].rsplit("/", true, 1)[0]
		
		#return OS.get_executable_path()
		
	return OS.get_executable_path()
