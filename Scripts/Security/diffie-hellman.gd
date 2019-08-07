extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
	
# TODO (IMPORTANT): Figure out how to do math on bits (ints cannot hold that much data)
func generate_secret(public_base: int, public_modulus: int, private_exponent: int):
	# There is no reason the exponent should be 1.
	if private_exponent == 1:
		return public_base
	
	return convert(pow(public_base, private_exponent), TYPE_INT) % public_modulus

func test():
	print("Diffie-Hellman Test")
	
	# Generate Base (smaller than modulus) and Modulus to Share Across Clearnet
	var public_base = 20 # This does not need to be prime
	var public_modulus = 23 # This has to be a prime number - https://crypto.stackexchange.com/questions/30328/why-does-the-modulus-of-diffie-hellman-need-to-be-a-prime#comment70299_30333
	
	print("Public Base: ", public_base, " Public Modulus: ", public_modulus)
	
	# Public Base and Public Modulus should be Shared Between Both Computers
	
	# These do not need to be prime (they can be)
	var private_key_a = 4
	var private_key_b = 3
	
	print("Private Key A: ", private_key_a, " Private Key B: ", private_key_b)
	
	# Generate Secrets to Share Across Clearnet
	var shared_secret_a = generate_secret(public_base, public_modulus, private_key_a)
	var shared_secret_b = generate_secret(public_base, public_modulus, private_key_b)

	print("Shared Secret A: ", shared_secret_a, " Shared Secret B: ", shared_secret_b)
	
	# Shared Secret A and B would be exchanged with each other here
	# The idea is that the secret can be safely shared while the keys are never sent
	
	# Computer A Calculates This With Shared Secret B
	var secret_key_a = generate_secret(shared_secret_b, public_modulus, private_key_a)
	
	# Computer B Calculates This With Shared Secret A
	var secret_key_b = generate_secret(shared_secret_a, public_modulus, private_key_b)

	# The Keys Are Supposed to Match - This is Done Without Sharing private_key_a/b or secret_key_a/b
	# Only public_base/modulus and shared_secret_a/b should be shared with each other
	print("Secret Key A: ", secret_key_a, " Secret Key B: ", secret_key_b)
	
	if secret_key_a == secret_key_b:
		print("Test Successful!!!")
	else:
		print("Test Failed!!!")
