extends Node

# Godot does not have builtin support for encrypted server/client communication.
# Because of that, I have to add an encryption module to Godot's engine and implement my own key exchange system.
# Also, I will need to implement a public server using HTTPs so I can prevent MITM attacks.

# Note (IMPORTANT): Without some third party "certificate authority", there is no way to prevent a MITM attack using current technology (there is the quantum key exchange, but that requires special hardware that does not exist yet).

# Questions I Asked To Get Help with SSL/TLS server support in Godot (yet to be answered)
# https://www.reddit.com/r/godot/comments/cm28n5/does_streampeerssl_work_with_tcp_server/
# https://gamedev.stackexchange.com/questions/174348/how-can-i-use-streampeerssl-with-godot-server-side

# Answer that gives simple explanation how a key exchange works.
# SSL/TLS Exchange - https://security.stackexchange.com/a/109093/123902
# Diffie-Hellman - https://security.stackexchange.com/a/38207/123902

# References To Existing Game Encryption Schemes
# Minecraft - https://wiki.vg/Protocol_Encryption

# My Implementation Plans (Based on SSL/TLS)
# TODO (IMPORTANT): Modify to Generate Key With Diffie-Hellman
# Client Establishes Connection to Server
# Server Public Key (no cert, because SSL/TLS server not implemented in Godot) 
# Client Sends Own Master Key Encrypted With Server Public Key
# Server Uses Master Key to Encrypt Messages to Client

# Public Key is Used to Decrypt Data
# Private Key is Used to Encrypt Data

# Master Key is A Non-Public/Private Key that can be used to encrypt/decrypt Messages With The Same Key

# Both the client and server have their own private/public keypair.
# In HTTPs, the server has the keypair pre-generated and the client generates one on the fly (for that specific session).

# Cripte Module supports RSA Public/Private Key System, So I Will Be Using That Here
# I may use GCM for the Master Key (I Have To Do More Research)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_key()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_key():
	pass

func load_key():
	generate_key()

# This is to test a custom module I compiled Godot with for encryption that I can use with RPC.
# Lets Hope it Works
func test_module():
	var Cripte = cripter.new()

	var key = "My not secret key"

	var gcm_add = "adicional data is: port: 316"
	var gcm_input = var2bytes("The cow goes muuuu")

	var encrypted_array_gcm = Cripte.encrypt_byte_GCM(gcm_input, key, gcm_add)
	var decrypted_array_gcm = Cripte.decrypt_byte_GCM(encrypted_array_gcm, key, gcm_add) 

	print("Encrypted: ", encrypted_array_gcm.get_string_from_ascii())
	print("Decrypted: ", bytes2var(decrypted_array_gcm))
