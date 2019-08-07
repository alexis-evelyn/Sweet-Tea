extends Node

# Please Refer to server_encryption.gd for my notes.
# I always start development on server/client by starting with the server, so all of my notes will be there.

# Declare member variables here. Examples:
var dh = preload("diffie-hellman.gd").new() # Preload Diffie-Hellman Script (Math is Exact Same No Matter if Client or Server)

# Called when the node enters the scene tree for the first time.
func _ready():
	dh.test()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Test Module for Cripte
func test_module():
	var Cripte = cripter.new()

	var key = "My not secret key"

	var gcm_add = "adicional data is: port: 316"
	var gcm_input = var2bytes("The cow goes muuuu")

	var encrypted_array_gcm = Cripte.encrypt_byte_GCM(gcm_input, key, gcm_add)
	var decrypted_array_gcm = Cripte.decrypt_byte_GCM(encrypted_array_gcm, key, gcm_add) 

	print("Encrypted: ", encrypted_array_gcm.get_string_from_ascii())
	print("Decrypted: ", bytes2var(decrypted_array_gcm))
