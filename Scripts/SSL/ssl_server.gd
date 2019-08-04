extends Node

# I plan on replacing Chat's RPC sending/receiving with StreamPeerSSL
# I also plan on adding authentication (before connecting to server) over StreamPeerSSL

# Declare member variables here. Examples:
var server : StreamPeerSSL

# Called when the node enters the scene tree for the first time.
func _ready():
	server = StreamPeerSSL.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
