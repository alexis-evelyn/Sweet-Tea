extends Node

#internal vars
# warning-ignore:unused_class_variable
var fading_out : bool = false
# warning-ignore:unused_class_variable
var fading_in : bool = false
# warning-ignore:unused_class_variable
var muted_tracks = []
# warning-ignore:unused_class_variable
var concats : Array

#external properties
# warning-ignore:unused_class_variable
export(int) var tempo
# warning-ignore:unused_class_variable
export(int) var bars
# warning-ignore:unused_class_variable
export(int) var beats_in_bar
# warning-ignore:unused_class_variable
export(float) var transition_beats

func _get_core():
	for i in get_children():
		if i.cont == "core":
			return i
