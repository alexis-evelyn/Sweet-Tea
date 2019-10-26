extends Node
class_name ServerCommands

# NOTE (IMPORTANT): Outside of a third party authentication system, a builtin login system on server join can help
# set permissions.

# Commands are in separate file because they can become really lengthy really quickly

# A Permission System Does Not Exist Yet, So The Permission Levels are Moot. This will be implemented eventually.
# Integer Constants for Determining Permission Levels of Commands (basically only allow those with permission to use or even see the commands they have permission for)
# Note: The lower the number is, the more power the permission level has.
enum permission_level {
	# Anything below 0 is automatically denied as the permission level that the command is supposed to have is unknown.
	# Someone could have badly implemented a nuke the world command and forgot to set the permission in supported_commands.
	# Let's not nuke the world because someone forgot to add it to the dictionary.
	missing_permission = -2, # Missing Permission From Command From Permission List
	missing_command = -1, # Missing Command From Permission List

	server_owner = 0, # Owner of Server
	admin = 1, # Paid helpers of Server Owner (manages the server plugins/mods and moderators)
	mod = 2, # Trusted Moderators (Manages Operators and Helps Deal With Problems Such as Griefing)
	op = 3, # Player With More Permissions Than Normal (Can access some commands a normal player cannot access) - Most useful with server plugins
	player = 4, # A Normal Player
	jail = 5, # A Joke Permission, but can be Used To Prevent Player From Executing Most Commands (except msg or invite, etc...)
	max_security = 6 # Another Joke Permission, Prevents Any Commands At All (might be renamed to solitary)
}

# Used by Help Command to Provide List of Commands
var supported_commands : Dictionary = {
	"help": {"description": "help_help_desc", "permission": permission_level.player, "cheat": false},
	"kick": {"description": "help_kick_desc", "permission": permission_level.mod, "cheat": false},
	"kickip": {"description": "help_kickip_desc", "permission": permission_level.mod, "cheat": false},
	"ban": {"description": "help_ban_desc", "permission": permission_level.mod, "cheat": false},
	"banip": {"description": "help_banip_desc", "permission": permission_level.mod, "cheat": false},
	"shutdown": {"description": "help_shutdown_desc", "permission": permission_level.server_owner, "cheat": false},

	"changeworld": {"description": "help_changeworld_desc", "permission": permission_level.op, "cheat": true},
	"createworld": {"description": "help_createworld_desc", "permission": permission_level.mod, "cheat": true},
	"spawn": {"description": "help_spawn_desc", "permission": permission_level.admin, "cheat": true},
	"wspawn": {"description": "help_wspawn_desc", "permission": permission_level.admin, "cheat": true},
	"setspawn": {"description": "help_setspawn_desc", "permission": permission_level.admin, "cheat": true},
#	"setwspawn": {"description": "help_setwspawn_desc", "permission": permission_level.admin, "cheat": true},
	"tp": {"description": "help_tp_desc", "permission": permission_level.op, "cheat": true},
	"seed": {"description": "help_seed_desc", "permission": permission_level.server_owner, "cheat": true},
	"servertime": {"description": "help_servertime_desc", "permission": permission_level.player, "cheat": false},
	"gravity": {"description": "help_gravity_desc", "permission": permission_level.op, "cheat": true},
	"setspawnworld": {"description": "help_setspawnworld_desc", "permission": permission_level.admin, "cheat": true},

	# These are essentially the same command
	"msg": {"description": "help_msg_desc", "permission": permission_level.player, "cheat": false},
	"tell": {"description": "help_msg_desc", "permission": permission_level.player, "cheat": false}
}

var arguments : PoolStringArray # To Convert Message into Arguments

var load_world_server_thread : Thread = Thread.new()
var create_world_server_thread : Thread = Thread.new()

# The NWSC is used to break up BBCode submitted by user without deleting characters - Should be able to be disabled by Server Request
var NWSC : String = PoolByteArray(['U+8203']).get_string_from_utf8() # No Width Space Character (Used to be called RawArray?) - https://docs.godotengine.org/en/3.1/classes/class_poolbytearray.html

# Process the Command and Return Result if Any
func process_command(net_id: int, message: String) -> void:
	"""
		Processes Command Sent By Client

		Only Meant to Be Called By RPC (and by server)
	"""
	#logger.verbose("UserID: %s Command: %s" % [net_id, message])
	arguments = message.split(functions.space_string, false, 0) # Convert Message into Arguments

	var response : String = check_command(net_id, arguments)

	# If response is empty, then don't send anything to chat
	if response == functions.empty_string:
		return

	#var response = "UserID: " + str(net_id) + " Command: " + message

	# The server is not allowed to RPC itself (neither is the client, but only the server could run this code (providing the client is not modified))
	if net_id != 1:
		get_parent().rpc_unreliable_id(net_id, "chat_message_client", response)
	else:
		get_parent().chat_message_client(response) # This just calls the chat_message_client directly as the server wants to message itself

# Check What Command and Arguments
func check_command(net_id: int, message: PoolStringArray) -> String:
	"""
		Checks Command Against List of Available Commands

		Not Meant to Be Called Directly
	"""

	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)

	# Compare lowercase version of command so it is not case sensitive.
	match command.to_lower():
		"help":
			return help_command(net_id, message)
		"kick":
			return kick_player(net_id, message)
		"kickip":
			return kick_player_ip(net_id, message)
		"ban":
			return ban_player(net_id, message)
		"banip":
			return ban_player_ip(net_id, message)
		"shutdown":
			return shutdown_server(net_id, message)
		"changeworld":
			return change_player_world(net_id, message)
		"createworld":
			return create_world(net_id, message)
		"spawn":
			return server_spawn(net_id, message)
		"wspawn":
			return world_spawn(net_id, message)
#		"setspawn":
#			return set_server_spawn(net_id, message)
		"setspawn": # Originally /setwspawn
			return set_world_spawn(net_id, message)
		"tp":
			return teleport(net_id, message)
		"seed":
			return get_seed(net_id, message)
		"msg":
			return private_message(net_id, message)
		"tell":
			return private_message(net_id, message)
		"servertime":
			return get_server_time(net_id, message)
		"gravity":
			return toggle_gravity(net_id, message)
		"setspawnworld":
			return set_spawn_world(net_id, message)
		"lua":
			return execute_lua(net_id, message)
		_: # Default Result - Put at Bottom of Match Results
			if command == functions.empty_string:
				return functions.empty_string
			else:
				return functions.get_translation("command_not_found", player_registrar.players[net_id].locale) % command

# Get Command's Permission Level (If Set)
func get_permission(command: String) -> int:
	"""
		Find Out Command's Permission Level
	"""

	if not supported_commands.has(command):
		return permission_level.missing_command

	if not supported_commands[command].has("permission"):
		return permission_level.missing_permission

	return supported_commands[command]["permission"]

# Check Player's Permission Level
func check_permission(players_permission_level: int, command_permission_level: int) -> bool:
	# What this does is it checks if the player's permission level is lower or equal to the command's required permission level.
	# It then checks if the player's permission level is at least that of a server owner.
	# Lower numbers means more permission. However, a number lower than the server owner means the player is denied.
	# If a player's permission number is higher than the command's required number, then the player is also denied.
	# In my setup, the player's permission number has to be greater than 0 and less than or equal to the command's permission number.

	return players_permission_level <= command_permission_level && players_permission_level >= permission_level.get("server_owner")

# Help Command
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func help_command(net_id: int, message: PoolStringArray) -> String:
	"""
		Help Command

		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	var output_array : PoolStringArray = PoolStringArray()
	var key_value_format : String = functions.get_translation("generic_key_value", str(player_registrar.players[net_id].locale))

	#output_array.append("Commands" + '\n')
	#output_array.append("-----------------------" + "\n")
	for supported_command in supported_commands:
		# Only return commands the player has access to
		if check_permission(players_permission_level, get_permission(supported_command)):
			# TODO: Alphanumerically Sort Commands using PSA.insert(index, string)
			output_array.append(key_value_format % [supported_command, functions.get_translation(supported_commands[str(supported_command)]["description"], str(player_registrar.players[net_id].locale))])

	return output_array.join('\n')

# Private Message User
func private_message(net_id: int, message: PoolStringArray) -> String:
	"""
		Private Message Command

		Not Meant to Be Called Directly
	"""

	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if not message.size() > 2:
		return functions.get_translation("private_message_not_enough_arguments", player_registrar.players[net_id].locale)

	var username : String = message[1]

	if not "#" in username:
		return functions.get_translation("private_message_user_not_found", player_registrar.players[net_id].locale) % username

	# This currently cannot handle usernames with spaces in it and I am not getting rid of the spaces.
	# TODO: Set this up so that it cross references a dictionary to look up the user's net_id
	# key will be username and value will be net_id
	var user_id_pool : PoolStringArray = username.rsplit("#", false, 1)

	if user_id_pool.size() != 2:
		return functions.get_translation("private_message_user_not_found", player_registrar.players[net_id].locale) % username

	var user_id : String = user_id_pool[1] # Remove this once dictionary lookup by username exists
	var user_net_id : int = int(user_id)
	# The function setting this is player_registrar.register_player(...)

	print("User ID: '%s'" % user_id)

	# Faster way to extract whole private message from PoolStringArray
	message.remove(0) # Remove command from arguments
	message.remove(0) # Remove username from arguments (Index is now 0 since the last 0 was removed)

	# Find out if user actually exists and then send message to them.
	if not player_registrar.players.has(user_net_id) or player_registrar.players[user_net_id].name.to_lower() != username.to_lower():
		return functions.get_translation("private_message_user_not_found", player_registrar.players[net_id].locale) % username

	var private_message_string : String = PoolStringArray(message).join(functions.space_string)

	# Set Color for Player's Username
	var chat_color = "#" + player_registrar.color(int(net_id)).to_html(false) # For now, I am specify chat color as color of character. I may change how color is set later.

	# Insert No Width Space After Open Bracket to Prevent BBCode - Should be able to be turned on and off by server (scratch that, let the server inject bbcode in if it approves the code or command)
	private_message_string = private_message_string.replace("[", "[" + NWSC)

	# The URL Idea Came From: https://docs.godotengine.org/en/latest/classes/class_richtextlabel.html?highlight=bbcode#signals
	var username_start : String = "[url={\"player_net_id\":\"" + str(net_id) + "\"}][color=" + chat_color + "][b][u]"
	var username_end : String = "[/u][/b][/color][/url]"
	var private_message_start : String = "[color=" + chat_color + "][i]"
	var private_message_end : String = "[/i][/color]"

	# There's Probably A Way To Make This Use Less Code!!!
	if net_id != gamestate.standard_netids.server:
		# Whisper To A Client
		if net_id != user_net_id:
			var added_username = "* " + username_start + str(player_registrar.name(int(net_id))) + username_end + functions.get_translation("private_message_whisper", player_registrar.players[net_id].locale) + private_message_start + private_message_string + private_message_end
			functions.rpc_unreliable_id(user_net_id, "request_attention", functions.attention_reason.private_message)
			get_parent().rpc_unreliable_id(user_net_id, "chat_message_client", added_username)
			return functions.get_translation("private_message_whisper_success", player_registrar.players[net_id].locale) % username
		else:
			var added_username = "* " + functions.get_translation("private_message_whisper_self", player_registrar.players[net_id].locale) + private_message_start + private_message_string + private_message_end
			functions.rpc_unreliable_id(user_net_id, "request_attention", functions.attention_reason.private_message)
			get_parent().rpc_unreliable_id(user_net_id, "chat_message_client", added_username)
			return functions.empty_string
	else:
		if net_id != user_net_id:
			var added_username = "* " + username_start + str(player_registrar.name(int(net_id))) + username_end + functions.get_translation("private_message_whisper", player_registrar.players[net_id].locale) + private_message_start + private_message_string + private_message_end
			functions.rpc_unreliable_id(user_net_id, "request_attention", functions.attention_reason.private_message)
			get_parent().rpc_unreliable_id(user_net_id, "chat_message_client", added_username)
			return functions.get_translation("private_message_whisper_success", player_registrar.players[net_id].locale) % username
		else:
			# Whisper To Server
			var added_username = "* " + functions.get_translation("private_message_whisper_self", player_registrar.players[net_id].locale) + private_message_start + private_message_string + private_message_end
			functions.request_attention(functions.attention_reason.private_message)
			get_parent().chat_message_client(added_username) # This just calls the chat_message_client directly as the server wants to message itself
			return functions.empty_string

# Kick Player Command
# warning-ignore:unused_argument
func kick_player(net_id: int, message: PoolStringArray) -> String:
	"""
		Kick Command

		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	# player_control

	return functions.get_translation("kick_player_command_no_permission", player_registrar.players[net_id].locale) % str(permission_level)

# Kick Player by IP Command
# warning-ignore:unused_argument
func kick_player_ip(net_id: int, message: PoolStringArray) -> String:
	"""
		Kick By IP Command

		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	# warning-ignore:unused_variable
#	var ip_address : String = str(message[1]) # Check to make sure IP Address is Specified

	# player_control

	return functions.get_translation("kick_player_ip_command_no_permission", player_registrar.players[net_id].locale) % str(permission_level)

# Ban Player Command
# warning-ignore:unused_argument
func ban_player(net_id: int, message: PoolStringArray) -> String:
	"""
		Ban Command

		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	# player_control

	return functions.get_translation("ban_player_command_no_permission", player_registrar.players[net_id].locale) % str(permission_level)

# Ban Player By IP Command
# warning-ignore:unused_argument
func ban_player_ip(net_id: int, message: PoolStringArray) -> String:
	"""
		Ban By IP Command

		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	# player_control

	return functions.get_translation("ban_player_ip_command_no_permission", player_registrar.players[net_id].locale) % str(permission_level)

# Change Player's World - Server Side Only
func change_player_world(net_id: int, message: PoolStringArray) -> String:
	"""
		Change Player's World Command

		This Command is Meant for Debug

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var world_path : String = world_handler.get_world_folder("World 2")
#		var world_name : String = world_handler.load_world_server(net_id, world_path)

		load_world_server_thread.start(world_handler, "load_world_server_threaded", [net_id, world_path])

		if net_id == gamestate.standard_netids.server:
			# If Server, show loading screen here.
			pass

		var world_name : String = load_world_server_thread.wait_to_finish()

		# Clears Loaded Chunks From Previous World Generator's Memory
		var world_generation = spawn_handler.get_world_generator_node(spawn_handler.get_world_name(net_id))
		world_generation.clear_player_chunks(net_id)
		#logger.verbose("Previous World: %s" % spawn_handler.get_world_name(net_id))

		if world_name == functions.empty_string:
			# TODO: Replace world_path in error message with name user gave!!!
			return functions.get_translation("change_world_command_failed_load_world", player_registrar.players[net_id].locale) % [world_path, net_id]

		spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else

		player_registrar.players[net_id].current_world = world_name # Update World Player is In (server-side)

		if net_id != 1:
			#logger.verbose("NetID Change World: %s" % net_id)
			spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name)
		else:
			#logger.verbose("Server Change World: %s" % net_id)
			spawn_handler.change_world(world_name)

		return functions.get_translation("change_world_command_success", player_registrar.players[net_id].locale) % [net_id, world_path]
	return functions.get_translation("change_world_no_permission", player_registrar.players[net_id].locale)

# Change Player's World - Server Side Only
func create_world(net_id: int, message: PoolStringArray) -> String:
	"""
		Creates New World and
		Changes Player's World Command

		This Command is Meant for Debug
		This command only works server side (for now)

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	# Get Player's Permission Level
	if check_permission(players_permission_level, command_permission_level):
		# Clears Loaded Chunks From Previous World Generator's Memory
		var world_generation = spawn_handler.get_world_generator_node(spawn_handler.get_world_name(net_id))
		world_generation.clear_player_chunks(net_id)
		#logger.verbose("Previous World: %s" % spawn_handler.get_world_name(net_id))

#		var world_name = world_handler.create_world(net_id, functions.empty_string) # Run's createworld function

		create_world_server_thread.start(world_handler, "create_world_server_threaded", [net_id, functions.empty_string]) # Run's createworld function

		if net_id == gamestate.standard_netids.server:
			# If Server, show loading screen here.
			pass

		var world_name : String = create_world_server_thread.wait_to_finish()

		spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else
		player_registrar.players[net_id].current_world = world_name # Update World Player is In (server-side)
		#spawn_handler.spawn_player_server(gamestate.player_info) # Will be moved to spawn handler

		if net_id != 1:
			#logger.verbose("NetID Change World: %s" % net_id)
			spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name)
		else:
			#logger.verbose("Server Change World: %s" % net_id)
			spawn_handler.change_world(world_name)

		return functions.get_translation("created_world_success", player_registrar.players[net_id].locale) % world_name
	return functions.get_translation("created_world_no_permission", player_registrar.players[net_id].locale)

# TODO: Add Restart Command
# Shutdown Server Command
# warning-ignore:unused_argument
func shutdown_server(net_id: int, message: PoolStringArray) -> String:
	"""
		Shutdown Server Command

		Not Meant to Be Called Directly
	"""

	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	# warning-ignore:unused_variable
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		# Server is Shutdown, so player cannot see the message regardless
		network.close_connection()
		return functions.empty_string

	return functions.get_translation("shutdown_server_no_permission", player_registrar.players[net_id].locale)

func server_spawn(net_id: int, message: PoolStringArray) -> String:
	"""
		Teleport To Server Spawn Command

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var world_path : String = world_handler.starting_world
#		var world_name : String = world_handler.load_world_server(net_id, world_path)

		load_world_server_thread.start(world_handler, "load_world_server_threaded", [net_id, world_path])

		if net_id == gamestate.standard_netids.server:
			# If Server, show loading screen here.
			pass

		var world_name : String = load_world_server_thread.wait_to_finish()

		# Clears Loaded Chunks From Previous World Generator's Memory
		var world_generation : TileMap = spawn_handler.get_world_generator_node(spawn_handler.get_world_name(net_id))
		world_generation.clear_player_chunks(net_id)
		#logger.verbose("Previous World: %s" % spawn_handler.get_world_name(net_id))

		if world_name == functions.empty_string:
			# TODO: Replace world_path in error message with name user gave!!!
			return functions.get_translation("spawn_command_failed", player_registrar.players[net_id].locale) % [world_path, net_id]

		spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else

		player_registrar.players[net_id].current_world = world_name # Update World Player is In (server-side)

		player_registrar.players[net_id].world_spawn = true # Set To Use World's Spawn Location

		if net_id != 1:
			#logger.verbose("NetID Change World: %s" % net_id)
			spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name)
		else:
			#logger.verbose("Server Change World: %s" % net_id)
			spawn_handler.change_world(world_name)

		return functions.get_translation("spawn_command_success", player_registrar.players[net_id].locale)
	return functions.get_translation("spawn_command_no_permission", player_registrar.players[net_id].locale)

func world_spawn(net_id: int, message: PoolStringArray) -> String:
	"""
		Teleport To World Spawn Command

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var world_name : String = spawn_handler.get_world_name(net_id) # Pick world player is currently in

		# Clears Loaded Chunks From Previous World Generator's Memory
		var world_generation : TileMap = spawn_handler.get_world_generator_node(spawn_handler.get_world_name(net_id))
		world_generation.clear_player_chunks(net_id)
		#logger.verbose("Previous World: %s" % spawn_handler.get_world_name(net_id))

		spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else

		player_registrar.players[net_id].world_spawn = true # Set To Use World's Spawn Location

		if net_id != 1:
			#logger.verbose("NetID Change World: %s" % net_id)
			spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name, true)
		else:
			#logger.verbose("Server Change World: %s" % net_id)
			spawn_handler.change_world(world_name)

		return functions.get_translation("world_spawn_command_success", player_registrar.players[net_id].locale)
	return functions.get_translation("world_spawn_command_no_permission", player_registrar.players[net_id].locale)

func set_server_spawn(net_id: int, message: PoolStringArray) -> String:
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	# warning-ignore:unused_variable
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var world_path : String = world_handler.starting_world # Server Spawn World
#		var world_name : String = spawn_handler.get_world_name(net_id) # Pick world player is currently in

		load_world_server_thread.start(world_handler, "load_world_server_threaded", [net_id, world_path])
		var world_name : String = load_world_server_thread.wait_to_finish()

		# World Name not Found
		if world_name == functions.empty_string:
			return functions.get_translation("set_server_spawn_command_world_name_not_found", player_registrar.players[net_id].locale)

		var world_gen_node : TileMap = spawn_handler.get_world_generator_node(world_name) # Get the node for the picked world

		# World Gen Node not Found
		if world_gen_node == null:
			return functions.get_translation("set_server_spawn_command_world_node_not_found", player_registrar.players[net_id].locale) % [world_name]

		var new_spawn : Vector2 = spawn_handler.get_player_body_node(net_id).position

		# Get Coordinates From Player Position
		world_gen_node.set_spawn(new_spawn)

		return functions.get_translation("set_server_spawn_command_success", player_registrar.players[net_id].locale) % [new_spawn.x, new_spawn.y]
	return functions.get_translation("set_server_spawn_command_no_permission", player_registrar.players[net_id].locale)

func set_world_spawn(net_id: int, message: PoolStringArray) -> String:
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var world_name : String = spawn_handler.get_world_name(net_id) # Pick world player is currently in

		# World Name not Found
		if world_name == functions.empty_string:
			return functions.get_translation("set_world_spawn_command_world_name_not_found", player_registrar.players[net_id].locale)

		var world_gen_node : TileMap = spawn_handler.get_world_generator_node(world_name) # Get the node for the picked world

		# World Gen Node not Found
		if world_gen_node == null:
			return functions.get_translation("set_world_spawn_command_world_node_not_found", player_registrar.players[net_id].locale) % [world_name]

		var new_spawn : Vector2 = spawn_handler.get_player_body_node(net_id).position

		# Either Get Coordinates From Player Position or From Arguments
		world_gen_node.set_spawn(new_spawn)

		return functions.get_translation("set_world_spawn_command_success", player_registrar.players[net_id].locale) % [new_spawn.x, new_spawn.y]
	return functions.get_translation("set_world_spawn_command_no_permission", player_registrar.players[net_id].locale)

func get_seed(net_id: int, message: PoolStringArray) -> String:
	"""
		Return World's Seed

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		# Get Seed From World Player Is In
		var world_generation : TileMap = spawn_handler.get_world_generator_node(spawn_handler.get_world_name(net_id))
		var world_seed : int = world_generation.world_seed

		return functions.get_translation("world_seed_command_success", player_registrar.players[net_id].locale) % world_seed
	return functions.get_translation("world_seed_command_no_permission", player_registrar.players[net_id].locale)

func get_server_time(net_id: int, message: PoolStringArray) -> String:
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var date_time : Dictionary
		var formatted_time : String
		var time_milliseconds : int

		date_time = OS.get_datetime()
		time_milliseconds = OS.get_system_time_msecs() - (OS.get_system_time_secs() * 1000)
		formatted_time = tr("datetime_formatting") % [int(date_time["hour"]), int(date_time["minute"]), int(date_time["second"]), time_milliseconds, OS.get_time_zone_info().name]
		return functions.get_translation("servertime_command_success", player_registrar.players[net_id].locale) % formatted_time
	return functions.get_translation("servertime_command_no_permission", player_registrar.players[net_id].locale)

func teleport(net_id: int, message: PoolStringArray) -> String:
	"""
		Teleport To Coordinates Command

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var command_arguments : PoolStringArray = message
		command_arguments.remove(0)

		var x_coor : float
		var y_coor : float

		var coordinates : Vector2
		if command_arguments.size() == 2:
			if command_arguments[0] != "~" and command_arguments[0] != "-":
				x_coor = convert(command_arguments[0], TYPE_INT)
			else:
				# If using tilde or minus, then use current coordinate from player
				x_coor = spawn_handler.get_player_body_node(net_id).position.x

			if command_arguments[1] != "~" and command_arguments[1] != "-":
				y_coor = convert(command_arguments[1], TYPE_INT)
			else:
				# If using tilde or minus, then use current coordinate from player
				y_coor = spawn_handler.get_player_body_node(net_id).position.y

			coordinates = Vector2(x_coor, y_coor)

			functions.teleport(net_id, coordinates) # This allows client to just reposition itself without reloading world. So useful for short distances.
#			functions.teleport_despawn(net_id, coordinates) # This allows forcing client to reload world. So, useful for long distances.

			return functions.get_translation("teleport_command_success", player_registrar.players[net_id].locale) % [coordinates.x, coordinates.y]
		elif command_arguments.size() == 1:
			# Teleport to Player (Not Implemented)
			# I may have different permission sublevels for this command.
			# I would have to decide what the best way to implement "sublevels" are.
			# I think it would need more finegrained control than just, are you high enough?

			var player_id : String = command_arguments[0]
			var other_player : Node = functions.grab_player_body_by_id(player_id)

			if player_registrar.players.has(other_player):
				x_coor = other_player.position.x
				y_coor = other_player.position.y

				coordinates = Vector2(x_coor, y_coor)

				functions.teleport(net_id, coordinates) # This allows client to just reposition itself without reloading world. So useful for short distances.
#				functions.teleport_despawn(net_id, coordinates) # This allows forcing client to reload world. So, useful for long distances.

				return "Success TP To Other Player - Replace Me With Translation Friendly String"
			return "Other Player Not Found - Replace Me With Translation Friendly String"
		elif command_arguments.size() == 3:
			# Teleport Player to Other Location (if alphabetical characters are first)
			# Disable Safety Check (if alphabetical characters are third)

			# Not Implemented

			return functions.get_translation("teleport_command_too_many_arguments", player_registrar.players[net_id].locale)
		elif command_arguments.size() == 0:
			return functions.get_translation("teleport_command_not_enough_arguments", player_registrar.players[net_id].locale)
		else:
			return functions.get_translation("teleport_command_too_many_arguments", player_registrar.players[net_id].locale)

	return functions.get_translation("teleport_command_no_permission", player_registrar.players[net_id].locale)

# warning-ignore:unused_argument
func toggle_gravity(net_id: int, message: PoolStringArray) -> String:
	"""
		Toggle Player's Gravity

		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		var player : Player = spawn_handler.get_player_body_node(net_id)

		if player == null:
			return functions.get_translation("toggle_gravity_command_missing_player_node", player_registrar.players[net_id].locale)

		if player.get_gravity_state():
			player.set_gravity_state(false)

			if net_id != gamestate.net_id:
				player.rpc_unreliable_id(net_id, "set_gravity_state", false) # If Player is Not Self, then Send to Client

			return functions.get_translation("toggle_gravity_command_success_off", player_registrar.players[net_id].locale)
		else:
			player.set_gravity_state(true)

			if net_id != gamestate.net_id:
				player.rpc_unreliable_id(net_id, "set_gravity_state", true) # If Player is Not Self, then Send to Client

			return functions.get_translation("toggle_gravity_command_success_on", player_registrar.players[net_id].locale)

	return functions.get_translation("toggle_gravity_command_no_permission", player_registrar.players[net_id].locale)

func set_spawn_world(net_id: int, message: PoolStringArray) -> String:
	"""
		Set Server's Spawn World

		Not Meant to Be Called Directly
	"""

	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var command_permission_level : int = get_permission(command) # Gets Command's Permission Level
	var players_permission_level : int = player_registrar.players[net_id].permission_level # Get Player's Permission Level

	if check_permission(players_permission_level, command_permission_level):
		gamestate.player_info.starting_world = world_handler.get_world_folder(spawn_handler.get_world_name(net_id))

#		gamestate.save_player(gamestate.loaded_save)
		gamestate.overwrite_save_value(gamestate.loaded_save, "starting_world", gamestate.player_info.starting_world)
		return tr("set_spawn_world_command_success") % gamestate.player_info.starting_world

	return tr("set_spawn_world_command_no_permission")

func execute_lua(net_id: int, message: PoolStringArray) -> String:
	"""
		Test Lua Execution and Sandboxing

		Uses Module From https://github.com/perbone/luascript

		Not Meant to Be Called Directly
	"""

	var lua_class = load("res://Scripts/Lua/test_lua.lua").new()

	# Currently it Doesn't Seem Like Engine Callbacks Work ATM...
	return lua_class.command(message.join(" "))

func get_class() -> String:
	return "ServerCommands"
