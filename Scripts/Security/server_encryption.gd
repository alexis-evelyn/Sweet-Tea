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
# Diffie-Hellman Example - https://www.geeksforgeeks.org/implementation-diffie-hellman-algorithm/ - I learn best by actually doing what it is I want to learn, so this page is useful as it has a simple, working Diffie-Hellman example to play with.
# Diffie-Hellman Explanation - https://security.stackexchange.com/questions/45963/diffie-hellman-key-exchange-in-plain-english
# Emphemeral RSA (Computationally Expensive) - https://crypto.stackexchange.com/questions/29744/can-an-ephemeral-rsa-key-give-forward-secrecy
# RSA Keysizes - https://danielpocock.com/rsa-key-sizes-2048-or-4096-bits/

# Authentication (Computation Speed) - https://crypto.stackexchange.com/questions/58571/is-authentication-more-computationally-expensive-than-encryption
# Authentication vs Encryption - https://support.1password.com/authentication-encryption/

# References To Existing Game Encryption Schemes
# Minecraft - https://wiki.vg/Protocol_Encryption

# Diffie-Hellman allows Perfect Forward Secrecy
# Ephemeral RSA does too, but I don't know enough about encryption to implement it
# I will have to see if I can find a professor at my university or someone else who knows cryptography to help me improve this

# Diffie-Hellman - Color Bit - Computerphile on Youtube - https://www.youtube.com/watch?v=NmM9HA2MQGI
# Diffie-Hellman - Math Bit - Computerphile on Youtube - https://www.youtube.com/watch?v=Yjrfm_oRO0w
# What is GCM Encryption (YouTube) - https://www.youtube.com/watch?v=g_eY7JXOc8U

# NOTE (IMPORTANT): I plan on modifying this to use a third party server to prevent MITM attacks (e.g. my own server if I cannot use Steam, Gamejolt, or Discord). If I use my own server, it would be based off of Mojang's auth server (maybe).
# My Implementation Plans (Using Diffie-Hellman and GCM)
# Client Establishes Connection to Server
# Generate Key using 4096 bits (0.000512 megabytes) over Diffie-Hellman
# Client Sends Master Key (gcm_key) Using Diffie Hellman (DH Key is tossed after Master Key is sent)
# Both Client and Server will Increment 96 bit IV (gcm_add) every message
# Profit...

# Public/Private Keypair - Assymetric Keypair (e.g. RSA)
# Public Key is Used to Encrypt Data
# Private Key is Used to Decrypt Data

# Symmetric Key
# Master Key is A Non-Public/Private Key that can be used to encrypt/decrypt Messages With The Same Key

# Both the client and server have their own private/public keypair.
# In HTTPs, the server has the keypair pre-generated and the client generates one on the fly (for that specific session).

# Cripte Module supports RSA Public/Private Key System, So I Will Be Using That Here
# I may use GCM for the Master Key (I Have To Do More Research)

# It appears the Cripter uses AES-256-GCM according to this line of code: "mbedtls_gcm_setkey(&ctx, MBEDTLS_CIPHER_ID_AES, key, 256);"
# https://github.com/Malkverbena/cripter/blob/6ba5b795603e2cf9a0e76fcc65eb7e9b4078d1f9/cripter/cripter.cpp#L96

# It appears GCM add is an IV? (the MBedTLS function in the url is used by cripter.cpp) - https://tls.mbed.org/api/gcm_8h.html#a3ad456f90f60211f72005dc815b808b5
# GCM is a stream cipher (so it can be used over networking) - https://crypto.stackexchange.com/a/24096/39179

# The IV needs to be 96 bits (standard size) and it must never be reused with the same key.
# The IV does not need to be secret, just unique.
# I can implement a counter with a randomly generated key.
# The client and server will increment their counter from the same starting point every session and they will transfer the key over diffie-hellman.

# Declare member variables here. Examples:
var dh = preload("diffie-hellman.gd").new() # Preload Diffie-Hellman Script (Math is Exact Same No Matter if Client or Server)

# Called when the node enters the scene tree for the first time.
func _ready():
	dh.test()
	load_key()

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
