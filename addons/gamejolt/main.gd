extends HTTPRequest

# Original GameJolt Godot plugin by Ackens https://github.com/ackens/-godot-gj-api
# Fork Gamegolt Godot plugin by rojekabc https://github.com/rojekabc/-godot-gj-api
# GameJolt API index page https://gamejolt.com/game-api/doc

const BASE_GAMEJOLT_API_URL = 'https://api.gamejolt.com/api/game/v1_2'

export(String) var private_key
export(String) var game_id
export(bool) var verbose = false

signal gamejolt_request_completed(requestResults)

var username_cache
var token_cache
var busy = false
var queue = []

var requestResult = {
	requestPath = null,
	requestError = null,
	responseResult = null,
	responseBody = null,
	responseHeaders = null,
	responseStatus = null,
	jsonParseError = null,
	gameJoltErrorMessage = null
}

func init(gameId, gamePrivateKey):
	game_id = gameId
	private_key = gamePrivateKey

func _ready():
	connect("request_completed", self, '_on_HTTPRequest_request_completed')
	pass

func auto_auth():
	#get username and token form url on gamejolt (only work with html5)
	username_cache = JavaScript.eval('var urlParams = new URLSearchParams(window.location.search); urlParams.get("gjapi_username")', true)
	token_cache = JavaScript.eval('var urlParams = new URLSearchParams(window.location.search); urlParams.get("gjapi_token")', true)
	if username_cache and not username_cache.empty():
		_call_gj_api('/users/auth/', {user_token = token_cache, username = username_cache})
	else:
		_verbose('No GameJolt logged user')

func auth_user(username, token):
	_call_gj_api('/users/auth/', {user_token = token, username = username})
	username_cache = username
	token_cache = token
	pass
	
func fetch_user(username=null, id=0):
	_call_gj_api('/users/', {username = username, user_id = id})
	pass
	
func fetch_friends():
	_call_gj_api('/friends/',
		{username = username_cache, user_token = token_cache})
	pass
	
func open_session():
	_call_gj_api('/sessions/open/',
		{username = username_cache, user_token = token_cache})
	pass
	
func ping_session():
	_call_gj_api('/sessions/ping/',
		{username = username_cache, user_token = token_cache})
	pass
	
func close_session():
	_call_gj_api('/sessions/close/',
		{username = username_cache, user_token = token_cache})
	pass
	
func check_session():
	_call_gj_api('/sessions/check/',
		{username = username_cache, user_token = token_cache})
	pass
	
func fetch_trophy(achieved=null, trophy_ids=null):
	_call_gj_api('/trophies/',
		{username = username_cache, user_token = token_cache, achieved = achieved, trophy_id = trophy_ids})
	pass
	
func set_trophy_achieved(trophy_id):
	if username_cache!=null:
		_call_gj_api('/trophies/add-achieved/',
			{username = username_cache, user_token = token_cache, trophy_id = trophy_id})
		pass
	
func remove_trophy_achieved(trophy_id):
	_call_gj_api('/trophies/remove-achieved/',
		{username = username_cache, user_token = token_cache, trophy_id = trophy_id})
	pass

func fetch_scores(table_id=null, limit=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{username = username_cache, user_token = token_cache, limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass

func fetch_guest_scores(guest, table_id=null, limit=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{guest = guest, limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass
	
func fetch_global_scores(table_id=null, limit=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass
	
func add_score(score, sort, table_id=null):
	if username_cache!=null:
		_call_gj_api('/scores/add/',
			{score = score, sort = sort, username = username_cache, user_token = token_cache, table_id = table_id})
		pass
	
func add_guest_score(score, sort, guest, table_id=null):
	_call_gj_api('/scores/add/',
		{score = score, sort = sort, guest = guest, table_id = table_id})
	pass
	
func fetch_score_rank(sort, table_id=null):
	_call_gj_api('/scores/get_rank/', {sort = sort, table_id = table_id})
	pass
	
func fetch_tables():
	_call_gj_api('/scores/tables/',{})
	pass
	
func fetch_data(key, global=true):
	if global:
		_call_gj_api('/data-store/', {key = key})
	else:
		_call_gj_api('/data-store/', {key = key, username = username_cache, user_token = token_cache})
	pass
	
func set_data(key, data, global=true):
	if global:
		_call_gj_api('/data-store/set/', {key = key, data = data})
	else:
		_call_gj_api('/data-store/set/', {key = key, data = data, username = username_cache, user_token = token_cache})
	pass
	
func update_data(key, operation, value, global=true):
	if global:
		_call_gj_api('/data-store/update/',
			{key = key, operation = operation, value = value})
	else:
		_call_gj_api('/data-store/update/',
			{key = key, operation = operation, value = value, username = username_cache, user_token = token_cache})
	pass
	
func remove_data(key, global=true):
	if global:
		_call_gj_api('/data-store/remove/', {key = key})
	else:
		_call_gj_api('/data-store/remove/', {key = key, username = username_cache, token = token_cache})
	pass
	
func get_data_keys(pattern=null, global=true):
	if global:
		_call_gj_api('/data-store/get-keys/', {pattern = pattern})
	else:
		_call_gj_api('/data-store/get-keys/',
			{username = username_cache, user_token = token_cache, pattern = pattern})
	pass
	
func fetch_time():
	_call_gj_api('/time/',{})
	pass

func get_username():
	return username_cache
	pass
	
func get_user_token():
	return token_cache
	pass

# returns true if request execution was positive and response is received
func is_ok(requestResults):
	return (
		(requestResults.requestError == OK) and
		(requestResults.responseResult == RESULT_SUCCESS) and
		(requestResults.responseStatus >= 200) and
		(requestResults.responseStatus < 300) and
		(requestResults.jsonParseError == OK) and
		(requestResults.gameJoltErrorMessage == null)
	)

func print_error(requestResults):
	logger.verbose('GameJolt error.'
	+ ' RequestError: ' + str(requestResults.requestError)
	+ ' ResponseResult: ' + str(requestResults.responseResult)
	+ ' JsonParseError: ' + str(requestResults.jsonParseError)
	+ ' GameJoltErrorMessage: ' + str(requestResults.gameJoltErrorMessage))

func clear_call_queue():
	queue.clear()

func _reset():
	requestResult.requestError = null
	requestResult.responseResult = null
	requestResult.responseHeaders = null
	requestResult.responseStatus = null
	requestResult.responseBody = null
	requestResult.jsonParseError = null
	requestResult.gameJoltErrorMessage = null

func _complete_request():
	busy = false
	emit_signal('gamejolt_request_completed', requestResult)
	_next_call_from_queue()


func _call_gj_api(type, parameters):
	if busy:
		queue.append([type,parameters])
		return
	busy = true
	_reset()
	requestResult.requestPath = type
	var url = _compose_url(type, parameters)
	requestResult.requestError = request(url)
	if requestResult.requestError != OK:
		_complete_request()
	pass

func _compose_url(urlpath, parameters={}):
	var final_url = BASE_GAMEJOLT_API_URL + urlpath
	final_url += '?game_id=' + str(game_id)

	for key in parameters.keys():
		var parameter = parameters[key]
		if parameter == null:
			continue
		parameter = str(parameter)
		if parameter.empty():
			continue;
		final_url += '&' + key + '=' + parameter.percent_encode()

	var signature = final_url + str(private_key)
	signature = signature.md5_text()
	final_url += '&signature=' + signature
	if verbose:
		_verbose(final_url)
	return final_url
	pass
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if result != OK:
		_complete_request()
		return
	requestResult.responseResult = result
	requestResult.responseStatus = response_code
	requestResult.responseHeaders = headers
	requestResult.responseBody = body.get_string_from_utf8()
	if verbose:
		_verbose(requestResult.responseBody)
	requestResult.responseBody = JSON.parse(requestResult.responseBody)
	requestResult.jsonParseError = requestResult.responseBody.error
	if requestResult.jsonParseError == OK:
		requestResult.responseBody = requestResult.responseBody.result['response']
		if requestResult.responseBody['success'] == 'true':
			requestResult.gameJoltErrorMessage = null
		elif requestResult.responseBody.has('message'):
			requestResult.gameJoltErrorMessage = requestResult.responseBody['message']
		else:
			requestResult.gameJoltErrorMessage = ''
	else:
		requestResult.responseBody = null
	_complete_request()
	pass

func _next_call_from_queue():
	if queue.empty():
		return
	var nextCall = queue.pop_front()
	_call_gj_api(nextCall[0], nextCall[1])
	pass

func _verbose(message):
	if verbose:
		logger.verbose('[GAMEJOLT] ' + message)
