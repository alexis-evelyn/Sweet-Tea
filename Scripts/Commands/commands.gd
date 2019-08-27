extends Node

# NOTE (IMPORTANT): Outside of a third party authentication system, a builtin login system on server join can help
# set permissions.

# Commands are in separate file because they can become really lengthy really quickly

# A Permission System Does Not Exist Yet, So The Permission Levels are Moot. This will be implemented eventually.
# Integer Constants for Determining Permission Levels of Commands (basically only allow those with permission to use or even see the commands they have permission for)
# Note: The lower the number is, the more power the permission level has.
const server_owner : int = 0 # Owner of Server
const admin : int = 1 # Paid helpers of Server Owner (manages the server plugins/mods and moderators)
const mod : int = 2 # Trusted Moderators (Manages Operators and Helps Deal With Problems Such as Griefing)
const op : int = 3 # Player With More Permissions Than Normal (Can access some commands a normal player cannot access) - Most useful with server plugins
const player : int = 4 # A Normal Player
const jail : int = 5 # A Joke Permission, but can be Used To Prevent Player From Executing Most Commands (except msg or invite, etc...)
const max_security : int = 6 # Another Joke Permission, Prevents Any Commands At All (might be renamed to solitary)

# Used by Help Command to Provide List of Commands
var supported_commands : Dictionary = {
"help": {"description": "help_help_desc", "permission": player},
"kick": {"description": "help_kick_desc", "permission": mod},
"kickip": {"description": "help_kickip_desc", "permission": mod},
"ban": {"description": "help_ban_desc", "permission": mod},
"banip": {"description": "help_banip_desc", "permission": mod},
"shutdown": {"description": "help_shutdown_desc", "permission": server_owner}
}

var arguments : PoolStringArray # To Convert Message into Arguments

# Process the Command and Return Result if Any
func process_command(net_id: int, message: String) -> void:
	"""
		Processes Command Sent By Client
		
		Only Meant to Be Called By RPC (and by server)
	"""
	#logger.verbose("UserID: %s Command: %s" % [net_id, message])
	arguments = message.split(" ", false, 0) # Convert Message into Arguments
	
	var response : String = check_command(net_id, arguments)
	
	# If response is empty, then don't send anything to chat
	if response == "":
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
	
	match command:
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
		_: # Default Result - Put at Bottom of Match Results
			if command == "":
				return ""
			else:
				return "command_not_found"

# Help Command
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func help_command(net_id, message) -> String:
	"""
		Help Command
		
		Not Meant to Be Called Directly
	"""
	
	var output_array : PoolStringArray = PoolStringArray()
	
	#output_array.append("Commands" + '\n')
	#output_array.append("-----------------------" + "\n")
	for command in supported_commands:
		# TODO: Alphanumerically Sort Commands using PSA.insert(index, string)
		output_array.append(command + ": " + supported_commands[str(command)]["description"])
		output_array.append(" - " + str(supported_commands[str(command)]["permission"]))
		output_array.append('\n')
	
	# I was hoping for a builtin method to convert array to string without the array brackets and commas
	var output : String = ""
	
	for line in output_array:
		output += line
	
	return str(output)
	
# Kick Player Command
# warning-ignore:unused_argument
func kick_player(net_id: int, message: PoolStringArray) -> String:
	"""
		Kick Command
		
		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	# player_control
	
	return "Kick Player and Optional Message - Permission Needed: " + str(permission_level)
	
# Kick Player by IP Command
# warning-ignore:unused_argument
func kick_player_ip(net_id: int, message: PoolStringArray) -> String:
	"""
		Kick By IP Command
		
		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
# warning-ignore:unused_variable
	var ip_address : String = str(message[1]) # Check to make sure IP Address is Specified
	
	# player_control
	
	return "Kick Player By IP and Optional Message - Permission Needed: " + str(permission_level)

# Ban Player Command
# warning-ignore:unused_argument
func ban_player(net_id: int, message: PoolStringArray) -> String:
	"""
		Ban Command
		
		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	# player_control
	
	return "Ban Player and Optional Message - Permission Needed: " + str(permission_level)

# Ban Player By IP Command
# warning-ignore:unused_argument
func ban_player_ip(net_id: int, message: PoolStringArray) -> String:
	"""
		Ban By IP Command
		
		Not Meant to Be Called Directly
	"""
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	# player_control
	
	return "Ban Player By IP and Optional Message - Permission Needed: " + str(permission_level)
	
# Change Player's World - Server Side Only
func change_player_world(net_id: int, message: PoolStringArray) -> String:
	"""
		Change Player's World Command
		
		This Command is Meant for Debug
		
		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	#var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	var world_path : String = "user://worlds/World 2"
	var world_name : String = world_handler.load_world_server(net_id, world_path)
	
	# Clears Loaded Chunks From Previous World Generator's Memory
	var world_generation = spawn_handler.get_world_generator(spawn_handler.get_world(net_id))
	world_generation.clear_player_chunks(net_id)
	#logger.verbose("Previous World: %s" % spawn_handler.get_world(net_id))
	
	if world_name == "":
		# TODO: Replace world_path in error message with name user gave!!!
		return "failed to Load World %s For Player ID %s" % [world_path, net_id]
	
	spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else
	
	player_registrar.players[net_id].current_world = world_name # Update World Player is In (server-side)
	
	if net_id != 1:
		#logger.verbose("NetID Change World: %s" % net_id)
		spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name)
	else:
		#logger.verbose("Server Change World: %s" % net_id)
		spawn_handler.change_world(world_name)
		
	# Use Client's Language To Determine What Strings to Use
	return "Player " + str(net_id) + " Changing World to: " + str(world_name)
	
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
	#var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	# TODO (IMPORTANT): Make sure to restrict access with permission levels!!!
	
	# When Permission Levels are implemented, the net_id == 1 check will be replaced
	if net_id == 1:
		# Clears Loaded Chunks From Previous World Generator's Memory
		var world_generation = spawn_handler.get_world_generator(spawn_handler.get_world(net_id))
		world_generation.clear_player_chunks(net_id)
		#logger.verbose("Previous World: %s" % spawn_handler.get_world(net_id))
		
		var world_name = world_handler.create_world(net_id, "") # Run's createworld function
		
		spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else
		player_registrar.players[net_id].current_world = world_name # Update World Player is In (server-side)
		#spawn_handler.spawn_player_server(gamestate.player_info) # Will be moved to spawn handler
		
		if net_id != 1:
			#logger.verbose("NetID Change World: %s" % net_id)
			spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name)
		else:
			#logger.verbose("Server Change World: %s" % net_id)
			spawn_handler.change_world(world_name)
		
		return "Created New World Named %s!!!" % world_name
	return "You are not the server!!!"
	
# TODO: Add Restart Command
# Shutdown Server Command
# warning-ignore:unused_argument
func shutdown_server(net_id: int, message: PoolStringArray) -> String:
	"""
		Shutdown Server Command
		
		Not Meant to Be Called Directly
	"""
	
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	return "Shutdown Command Not Implemented - Permission Needed: " + str(permission_level)
	
func server_spawn(net_id: int, message: PoolStringArray) -> String:
	"""
		Teleport To Server Spawn Command
		
		Not Meant to Be Called Directly
	"""
	# warning-ignore:unused_variable
	var command : String = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	#var permission_level : int = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	var world_path : String = world_handler.starting_world
	var world_name : String = world_handler.load_world_server(net_id, world_path)
	
	# Clears Loaded Chunks From Previous World Generator's Memory
	var world_generation = spawn_handler.get_world_generator(spawn_handler.get_world(net_id))
	world_generation.clear_player_chunks(net_id)
	#logger.verbose("Previous World: %s" % spawn_handler.get_world(net_id))
	
	if world_name == "":
		# TODO: Replace world_path in error message with name user gave!!!
		return "(Server Spawn) failed to Load World %s For Player ID %s" % [world_path, net_id]
	
	spawn_handler.despawn_player(net_id) # Removes Player From World Node and Syncs it With Everyone Else
	
	player_registrar.players[net_id].current_world = world_name # Update World Player is In (server-side)
	
	if net_id != 1:
		#logger.verbose("NetID Change World: %s" % net_id)
		spawn_handler.rpc_unreliable_id(net_id, "change_world", world_name)
	else:
		#logger.verbose("Server Change World: %s" % net_id)
		spawn_handler.change_world(world_name)
		
	return "Teleported to Spawn"
