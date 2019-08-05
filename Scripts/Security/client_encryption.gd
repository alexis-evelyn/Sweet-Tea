extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# This is to test a custom module I compiled Godot with for encryption that I can use with RPC.
# More on this later.
# TODO: Add MBedTLS and Cripte to License Docs

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
