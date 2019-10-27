extends Node
class_name HotbitsSDK

# Unfinished But Mostly Ready For Use - May Use Later

# Pulls Random Data From Geiger Counter At Fourmilabs. Can be used to retrieve truly random data in the quantum sense.
# Take that determinism!!! :P

# Do note, the geiger counter is not a number flooding machine, so it is rate limited and now requires an API key to prevent abuse.
# Read more here: https://www.fourmilab.ch/fourmilog/archives/2017-06/001684.html

# Also, psuedorandom data is data that was seeded with real data from the geiger counter, so it is still randomish, but in most cases is still good enough.

# Based on My Project From Web Development Class - https://github.com/SenorContento/self-hosted-blog/blob/6748e365a16ceffdebd6579a8269603f0fb0e323/api/hotbits/index.php

# Declare member variables here. Examples:
const api_url : String = "https://www.fourmilab.ch/cgi-bin/Hotbits.api" # API Url
const test_key : String = "Pseudorandom" # Useful for testing without rate limiting or banning
var data_format : String = "json" # Available Formats: hex, bin, c, xml, json, password
var number_of_requested_bytes : int = 2048 # Maximum 2048 bytes - Not Active When format is password

var number_of_passwords : int = 0
var length_of_passwords : int = 0
var requested_password_type : int = password_type.letters_numbers_and_punctuation

# Apparently Hotbits No Longer Supports Post Requests :(
var request_method : int = HTTPClient.METHOD_GET

var user_agent : String = functions.get_translation(ProjectSettings.get_setting("application/config/name"), "en")
var validate_domain : bool = true # Validate Domain if Using HTTPS.

var real_key : String # Do Not Store Real Key in Code - Key To Be Requested From This Form: https://www.fourmilab.ch/hotbits/apikey_request.html

var sent_headers : Array = [
	"user-agent: %s" % [user_agent],
	"Content-type: application/x-www-form-urlencoded"
]

var query : Dictionary = {
	"nbytes": number_of_requested_bytes,
	"fmt": data_format,
	"apikey": get_api_key(),

	"pwtype": requested_password_type,
	"npass": number_of_passwords,
	"lpass": length_of_passwords
}

enum password_type {
	lower_case_letters = 0,
	mixed_case_letters = 1,
	letters_and_numbers = 2,
	letters_numbers_and_punctuation = 3
}

var json_response : JSONParseResult # Response From Hotbits

# Called when the node enters the scene tree for the first time.
func _ready():
#	request_data()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func request_data():
	$HTTPRequest.request(api_url + to_query_string(query), sent_headers, validate_domain, request_method)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
#	logger.verbose("Hotbits Result Code: %s" % result)
#	logger.verbose("Hotbits Response Code: %s" % response_code)
#
#	for header in headers:
#		logger.verbose("Hotbits Header: %s" % header)

#	logger.warn("Body: %s" % body.get_string_from_utf8())

	if data_format == "json":
		# Run Function to Parse As Json (After Checking To Make Sure Not HTML Rate Limit Message)
		process_json_response(body.get_string_from_utf8())
	else:
		# Unrecognized Format, Print To Logger and stdout
		logger.warn("Format: %s\nBody: %s" % [data_format, body.get_string_from_utf8()])

func process_json_response(body: String):
	json_response = JSON.parse(body)

	if json_response.error != OK:
		pass
		return

	# Inside Dictionary - version: string, schema: string, status: int, requestInformation: Dictionary, data: Integer Array
	# Inside requestInformation - serverVersion: string, generationTime: string, bytesRequested: int, bytesReturned: int, quotaRequestsRemaining: int, quotaBytesRemaining: int, generatorType: string

#	logger.warn("Version: %s" % json_response.result.version)
#	logger.warn("Schema: %s" % json_response.result.schema)
#	logger.warn("Status: %s" % json_response.result.status)
#
#	for request_info in json_response.result.requestInformation:
#		logger.warn("RequestInfo %s: %s" % [request_info, json_response.result.requestInformation.get(request_info)])
#
#	for byte in json_response.result.data:
#		logger.warn("Byte: %s" % [byte])

	if json_response.result.has("data"):
		logger.verbose("Hotbits Bytes: %s" % json_response.result.data)

func get_api_key() -> String:
	if real_key.empty():
		return test_key

	return real_key

func to_query_string(dictionary: Dictionary) -> String:
	var query_string : String = "?"

	for key in dictionary.keys():
		query_string += "%s=%s&" % [key, dictionary[key]]

	query_string = query_string.rstrip("&") # Remove last Ampersand

	return query_string

func get_class() -> String:
	return "Hotbits"
