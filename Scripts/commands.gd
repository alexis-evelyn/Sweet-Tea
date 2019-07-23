extends Node

# Commands are in separate file because they can become really complicated really quickly

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Process the Command and Return Result if Any
func process_command(net_id, message):
	print("UserID: " + str(net_id) + " Command: " + message)
	
	var response = "UserID: " + str(net_id) + " Command: " + message

	# The server is not allowed to RPC itself (neither is the client, but only the server could run this code (providing the client is not modified))
	if net_id != 1:
		rpc_id(net_id,"chat_message_client", response)
	else:
		chat_message_client(response) # This just calls the chat_message_client directly as the server wants to message itself

# Apparently if I try calling a function not in the same file, I get an error that I am not the network master.
# Duplicating the function and redirecting it to the proper place fixes that issue.
sync func chat_message_client(message):
	get_parent().chat_message_client(message)