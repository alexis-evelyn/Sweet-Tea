extends Node

# Used by Shaders Command in client_commands.gd
var shaders : Dictionary = {
	# LGBT Shaders
	"transgender_flag": {
		"lgbt": true, # Used to Verify That This is A LGBT Shader
		"path": "res://Scripts/Shaders/lgbt/transgender_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"polysexual_flag": {
		"lgbt": true, # Custom Keys Can Be Added To Help With Mods/Builtin Functions to Organize/Setup Shaders
		"path": "res://Scripts/Shaders/lgbt/polysexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"pansexual_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/pansexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"nonbinary_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/non-binary_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"lgbt_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/lgbt_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"lesbian_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/lesbian_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"intersex_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/intersex_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"genderqueer_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/genderqueer_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"genderfluid_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/genderfluid_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"bisexual_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/bisexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"asexual_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/asexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"aromantic_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/aromantic_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"agender_flag": {
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/agender_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},

	# Other Shaders
	"animated_rainbow": {
		"path": "res://Scripts/Shaders/third_party/ShaderToy/animated_rainbow_gradient.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"animated_blur": {
		"path": "res://Scripts/Shaders/animated_blur.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"earthquake": {
		"path": "res://Scripts/Shaders/earthquake.shader",
		"animated": true,
		"description": "",
		"seizure_warning": true # TODO: Find our what to look for to accurately predict potential seizure causing shaders
	},
	"fabric_of_time": {
		"path": "res://Scripts/Shaders/fabric_of_time.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"grayscale": {
		"path": "res://Scripts/Shaders/grayscale.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"peeling_back_reality": {
		"path": "res://Scripts/Shaders/peeling_back_reality.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"bcs": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/bcs.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"blur": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/blur.shader",
		"animated": false,
		"default_params": {
			"blur": 2.0 # (0-5)
		},
		"description": "",
		"seizure_warning": false
	},
	"contrasted": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/contrasted.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"fisheye": {
		"path": "res://Scripts/Shaders/third_party/JEGX/fisheye.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"mirage": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/mirage.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"negative": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/negative.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"normalized": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/normalized.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"pixelize": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/pixelize.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"sepia": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/sepia.shader",
		"animated": false,
		"default_params": {
			"color": Color("#8b6867") # Defaults to Sepia Color
		},
		"description": "",
		"seizure_warning": false
	},
	"whirl": {
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/whirl.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"whirl_strong": {
		"path": "res://Scripts/Shaders/whirl_strong.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"animated_whirl": {
		"path": "res://Scripts/Shaders/animated_whirl.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"weird_boxy_rotation": {
		"path": "res://Scripts/Shaders/weird_boxy_rotation.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"flip": {
		"path": "res://Scripts/Shaders/flip.shader",
		"animated": false,
		"default_params": {
			"angle": 180,
		}, "description": "",
		"seizure_warning": false
	},
	"highlighter": {
		"path": "res://Scripts/Shaders/highlighter.shader",
		"animated": false,
		"default_params": {
			#"shading": Color("#a9a9a9"),
			"color": Color("#0000ff"),
			# The test player's modulation is #0000ff. This is using the Godot icon that comes with a newly generated project.
			"forgiveness": Vector3(0.0, 0.0, 1.0)
		}, "description": "",
		"seizure_warning": false
	}
}
