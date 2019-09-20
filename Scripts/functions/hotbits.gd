extends Node

# Pulls Random Data From Geiger Counter At Fourmilabs. Can be used to retrieve truly random data in the quantum sense.
# Take that determinism!!! :P

# Do note, the geiger counter is not a number flooding machine, so it is rate limited and now requires an API key to prevent abuse.
# Read more here: https://www.fourmilab.ch/fourmilog/archives/2017-06/001684.html

# Also, psuedorandom data is data that was seeded with real data from the geiger counter, so it is still randomish, but in most cases is still good enough.

# Based on My Project From Web Development Class - https://github.com/SenorContento/self-hosted-blog/blob/6748e365a16ceffdebd6579a8269603f0fb0e323/api/hotbits/index.php

# Declare member variables here. Examples:
var api_url : String = "https://www.fourmilab.ch/cgi-bin/Hotbits.api" # API Url
var test_key : String = "pseudo" # Useful for testing without rate limiting or banning
var data_format : String = "json" # Available Formats: hex, bin, c, xml, json, password
var number_of_requested_bytes : int = 2048 # Maximum 2048 bytes - Not Active When format is password

var real_key : String # Do Not Store Real Key in Code - Key To Be Requested From This Form: https://www.fourmilab.ch/hotbits/apikey_request.html

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
