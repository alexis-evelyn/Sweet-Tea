extends Node

# NOTE (IMPORTANT): Outside of a third party authentication system, a builtin login system on server join can help
# set permissions.

# Commands are in separate file because they can become really lengthy really quickly

# A Permission System Does Not Exist Yet, So The Permission Levels are Moot. This will be implemented eventually.
# Integer Constants for Determining Permission Levels of Commands (basically only allow those with permission to use or even see the commands they have permission for)
# Note: The lower the number is, the more power the permission level has.
const server_owner = 0 # Owner of Server
const admin = 1 # Paid helpers of Server Owner (manages the server plugins/mods and moderators)
const mod = 2 # Trusted Moderators (Manages Operators and Helps Deal With Problems Such as Griefing)
const op = 3 # Player With More Permissions Than Normal (Can access some commands a normal player cannot access) - Most useful with server plugins
const player = 4 # A Normal Player
const jail = 5 # A Joke Permission, but can be Used To Prevent Player From Executing Most Commands (except msg or invite, etc...)
const max_security = 6 # Another Joke Permission, Prevents Any Commands At All (might be renamed to solitary)

# Used by Help Command to Provide List of Commands
var supported_commands = {
"help": {"description": "Provides List of Commands and What They Do", "permission": player},
"kick": {"description": "Kicks Player Specified As Argument", "permission": mod},
"kickip": {"description": "Kicks All Players On Specified IP", "permission": mod},
"ban": {"description": "Bans Player Specified As Argument", "permission": mod},
"banip": {"description": "Bans IP Address From Joining Server", "permission": mod},
"shutdown": {"description": "Shuts Down Server", "permission": server_owner}
}

# Process the Command and Return Result if Any
func process_command(net_id, message):
	print("UserID: " + str(net_id) + " Command: " + message)
	
	var arguments = PoolStringArray()
	arguments = message.split(" ", false, 0)
	
	var response = check_command(net_id, arguments)
	
	#var response = "UserID: " + str(net_id) + " Command: " + message

	# The server is not allowed to RPC itself (neither is the client, but only the server could run this code (providing the client is not modified))
	if net_id != 1:
		rpc_id(net_id,"chat_message_client", response)
	else:
		chat_message_client(response) # This just calls the chat_message_client directly as the server wants to message itself

# Apparently if I try calling a function not in the same file, I get an error that I am not the network master.
# Duplicating the function and redirecting it to the proper place fixes that issue.
sync func chat_message_client(message):
	get_parent().chat_message_client(message)
	
# Check What Command and Arguments
func check_command(net_id, message):
	var command = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	
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
		_: # Default Result - Put at Bottom of Match Results
			return "Command, " + command + ", Not Found!!!"

# Help Command
func help_command(net_id, message):
	var output_array = PoolStringArray()
	
	#output_array.append("Commands" + '\n')
	#output_array.append("-----------------------" + "\n")
	for command in supported_commands:
		# TODO: Alphanumerically Sort Commands using PSA.insert(index, string)
		output_array.append(command + ": " + supported_commands[str(command)]["description"])
		output_array.append(" - " + str(supported_commands[str(command)]["permission"]))
		output_array.append('\n')
	
	# I was hoping for a builtin method to convert array to string without the array brackets and commas
	var output = ""
	
	for line in output_array:
		output += line
	
	return str(output)
	
# Kick Player Command
func kick_player(net_id, message):
	var command = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	return "Kick Player and Optional Message - Permission Needed: " + str(permission_level)
	
# Kick Player by IP Command
func kick_player_ip(net_id, message):
	var command = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	return "Kick Player By IP and Optional Message - Permission Needed: " + str(permission_level)

# Ban Player Command
func ban_player(net_id, message):
	var command = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	return "Ban Player and Optional Message - Permission Needed: " + str(permission_level)

# Ban Player By IP Command
func ban_player_ip(net_id, message):
	var command = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	return "Ban Player By IP and Optional Message - Permission Needed: " + str(permission_level)
	
# TODO: Add Restart Command
# Shutdown Server Command
func shutdown_server(net_id, message):
	var command = message[0].substr(1, message[0].length()-1) # Removes Slash From Command (first character)
	var permission_level = supported_commands[str(command)]["permission"] # Gets Command's Permission Level
	
	return "Shutdown Command Not Implemented - Permission Needed: " + str(permission_level)