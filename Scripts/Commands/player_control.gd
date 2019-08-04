extends Node

# NOTE (IMPORTANT): None of this script is functional!!! It will be fixed later.
# At the time of writing: I am currently organizing my code so it is more legible and easier to traverse.

# Declare member variables here. Examples:

# List of Banned Players (will be saved to file)
var banned_players : Dictionary = {} # If I add actual authentication (via Steam or my own custom implementation, this will be useful)
var banned_ips : Dictionary = {} # Allows banning players via IP address (if player ban is not enough). Use with restraint as multiple players could share the same IP address (e.g. in a university)

# Load Necessary Scripts
#onready var player_registrar = preload("res://Scripts/player_registrar.gd")

func check_if_banned(id: int) -> void:
	var net : NetworkedMultiplayerENet = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	#print("Ban Check - Player ID: ", str(id), " Player IP: ", str(net.get_peer_address(id)))
	
	if banned_players.has(id) or banned_ips.has(net.get_peer_address(id)):
		#print("Player Was Previously Banned")
		
		# Function is Missing - rpc_unreliable_id(id, "player_kicked", "You were banned!!!") # Notify Player They Have Been Kicked
		net.disconnect_peer(id, false) # Disconnect the peer immediately (true means no flushing messages)

func kick_player() -> void:
	var net : NetworkedMultiplayerENet= get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	# TODO: Currently, the server disconnects everyone, but as chat gets added, the ability to select a peer (client) will be added to
	
	# The server will do the kicking of players, but mods can request the server to do so (with the right permissions)
	if get_tree().is_network_server():
		# TODO: This for loop will be replaced by a player ID (do not replace with name, but do set a permanent id via third party such as with Steam) specified by chat
		for player in player_registrar.players:
			if player != 1: # If player is not server
				# Function is Missing - rpc_unreliable_id(player, "player_kicked", "You, " + str(player) + ", has been kicked!!! Your IP address is: " + str(net.get_peer_address(player))) # Notify Player They Have Been Kicked
				net.disconnect_peer(player, false) # Disconnect the peer immediately (true means no flushing messages)
				
func kick_player_ip(ip_address: String) -> void:
	var net = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	# TODO: Make Efficient for Large Player Base
	
	for player in player_registrar.players:
		if player != 1: # If player is not server
			if str(net.get_peer_address(player)) == ip_address:
				pass
				#kick_player() # Will specify Player ID "player"
				
func ban_player() -> void:
	var ban_message : String = "Player Banned!!!" # Will be replaced by a function argument
	
	var net : NetworkedMultiplayerENet = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	var banned : Dictionary = OS.get_datetime(true)  # true means UTC format (helps consistency even if computer timezone is changed)
	var pardoned : int = 10 # How many seconds to ban for (0 means indefinitely)
	
	if get_tree().is_network_server():
		# TODO: This for loop will be replaced by a player ID (do not replace with name, but do set a permanent id via third party such as with Steam) specified by chat
		for player in player_registrar.players:
			if player != 1: # If player is not server
				var ban_data : Dictionary = {
					player_id = player, # Player's Network ID
					player_ip_address = str(net.get_peer_address(player)), # Player's IP Address
					banned_time = banned, # Sets Time Player Was Banned
					pardon_time = pardoned # Time User Will be Pardoned
				}
			
				banned_players[player] = ban_data
				#kick_player() # Will add arguments later (player id and ban message)
				
func ban_player_ip() -> void:
	var ban_message : String = "IP Banned!!!" # Will be replaced by a function argument
	
	var net : NetworkedMultiplayerENet = get_tree().get_network_peer() # Grab the existing Network Peer Node
	
	var banned : Dictionary = OS.get_datetime(true) # true means UTC format (helps consistency even if computer timezone is changed)
	var pardoned : int = 10  # How many seconds to ban for (0 means indefinitely)
	
	if get_tree().is_network_server():
		# TODO: This for loop will be replaced by a player ID (do not replace with name, but do set a permanent id via third party such as with Steam) specified by chat
		for player in player_registrar.players:
			if player != 1: # If player is not server
				var ip_address : String = str(net.get_peer_address(player))
			
				var ban_data : Dictionary = {
					player_id = player, # Player's Network ID
					player_ip_address = ip_address, # Player's IP Address
					banned_time = banned, # Sets Time Player Was Banned
					pardon_time = pardoned # Time User Will be Pardoned
				}
				
				banned_ips[ip_address] = ban_data
				#kick_player_by_ip(ip_address) # Will add arguments later (player id and ban message)