extends Node
class_name UPNP_Server

# UPNP API - https://docs.godotengine.org/en/3.1/classes/class_upnp.html

# Declare member variables here. Examples:
var external_port : int = 4001
var mapping_desc : String = "%s UDP Game Port" % functions.get_translation(ProjectSettings.get_setting("application/config/name"), "en")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func forward_game(port: int) -> int:
	# This currently does not seem to work, so I am disabling it for now until I investigate further.
#	var upnp : UPNP = UPNP.new()
#	upnp.discover(2000, 2, "InternetGatewayDevice")
#	var successful : int = upnp.add_port_mapping(external_port, port, mapping_desc, "UDP", 0)
#
#	logger.debug("UPNP Add Port Mapping (%s to %s): %s" % [port, external_port, successful])

	return 0
