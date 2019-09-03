extends Node
class_name ClientEncryption

# Please Refer to server_encryption.gd for my notes.
# I always start development on server/client by starting with the server, so all of my notes will be there.

# Declare member variables here. Examples:
# warning-ignore:unused_class_variable
var dh = preload("diffie-hellman.gd").new() # Preload Diffie-Hellman Script (Math is Exact Same No Matter if Client or Server)

# Called when the node enters the scene tree for the first time.
func _ready():
	dh.test()

# Test Module for Cripte
func test_module():
#	var Cripte = cripter.new()
#
#	var key = "My not secret key"
#
#	var gcm_add = "adicional data is: port: 316"
#	var gcm_input = var2bytes("The cow goes muuuu")
#
#	var encrypted_array_gcm = Cripte.encrypt_byte_GCM(gcm_input, key, gcm_add)
#	var decrypted_array_gcm = Cripte.decrypt_byte_GCM(encrypted_array_gcm, key, gcm_add) 
#
#	#logger.verbose("Encrypted: ", encrypted_array_gcm.get_string_from_ascii())
#	#logger.verbose("Decrypted: ", bytes2var(decrypted_array_gcm))
	pass

func get_class() -> String:
	return "ClientEncryption"
