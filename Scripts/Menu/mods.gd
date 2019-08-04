extends Control

# This scene is for the modloader.
# The idea is to dynamically load mods at runtime before the MainMenu is even loaded

# https://gamedev.stackexchange.com/a/174312/97290

# Declare member variables here. Examples:
var mods_installed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not mods_installed:
		get_tree().change_scene("res://Menus/MainMenu.tscn")
	else:
		self.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
