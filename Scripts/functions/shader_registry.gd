extends Node

# Used by Shaders Command in client_commands.gd
var shaders : Dictionary = {
	# LGBT Shaders
	"transgender_flag": {
		"name": "Transgender Flag",
		"lgbt": true, # Used to Verify That This is A LGBT Shader
		"path": "res://Scripts/Shaders/lgbt/transgender_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"polysexual_flag": {
		"name": "Polysexual Flag",
		"lgbt": true, # Custom Keys Can Be Added To Help With Mods/Builtin Functions to Organize/Setup Shaders
		"path": "res://Scripts/Shaders/lgbt/polysexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"pansexual_flag": {
		"name": "Pansexual Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/pansexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"nonbinary_flag": {
		"name": "Non-binary Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/non-binary_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"lgbt_flag": {
		"name": "LGBT Pride Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/lgbt_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"lesbian_flag": {
		"name": "Lesbian Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/lesbian_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"intersex_flag": {
		"name": "Intersex Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/intersex_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"genderqueer_flag": {
		"name": "Genderqueer Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/genderqueer_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"genderfluid_flag": {
		"name": "Genderfluid Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/genderfluid_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"bisexual_flag": {
		"name": "Bisexual Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/bisexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"asexual_flag": {
		"name": "Asexual Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/asexual_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"aromantic_flag": {
		"name": "Aromantic Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/aromantic_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"agender_flag": {
		"name": "Agender Flag",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/agender_flag.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},

	# Other Shaders
	"animated_rainbow": {
		"name": "Animated Rainbow",
		"path": "res://Scripts/Shaders/third_party/ShaderToy/animated_rainbow_gradient.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"animated_blur": {
		"name": "Animated Blur",
		"path": "res://Scripts/Shaders/animated_blur.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"earthquake": {
		"name": "Earthquake",
		"path": "res://Scripts/Shaders/earthquake.shader",
		"animated": true,
		"description": "",
		"seizure_warning": true # TODO: Find our what to look for to accurately predict potential seizure causing shaders
	},
	"fabric_of_time": {
		"name": "Fabric of Time",
		"path": "res://Scripts/Shaders/fabric_of_time.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"grayscale": {
		"name": "Grayscale",
		"path": "res://Scripts/Shaders/grayscale.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"peeling_back_reality": {
		"name": "Peeling Back Reality",
		"path": "res://Scripts/Shaders/peeling_back_reality.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"bcs": {
		"name": "Brightness, Contrast, Saturation",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/bcs.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"blur": {
		"name": "Blur",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/blur.shader",
		"animated": false,
		"default_params": {
			"blur": 2.0 # (0-5)
		},
		"description": "",
		"seizure_warning": false
	},
	"contrasted": {
		"name": "Contrasted",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/contrasted.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"fisheye": {
		"name": "Fisheye",
		"path": "res://Scripts/Shaders/third_party/JEGX/fisheye.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"mirage": {
		"name": "Mirage",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/mirage.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"negative": {
		"name": "Negative",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/negative.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"normalized": {
		"name": "Normalized",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/normalized.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"pixelize": {
		"name": "Pixelize",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/pixelize.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"sepia": {
		"name": "Sepia",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/sepia.shader",
		"animated": false,
		"default_params": {
			"color": Color("#8b6867") # Defaults to Sepia Color
		},
		"description": "",
		"seizure_warning": false
	},
	"whirl": {
		"name": "Whirl",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/whirl.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"whirl_strong": {
		"name": "Strong Whirl",
		"path": "res://Scripts/Shaders/whirl_strong.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"animated_whirl": {
		"name": "Animated Whirl",
		"path": "res://Scripts/Shaders/animated_whirl.shader",
		"animated": false,
		"description": "",
		"seizure_warning": false
	},
	"weird_boxy_rotation": {
		"name": "Weird Boxy Shader",
		"path": "res://Scripts/Shaders/weird_boxy_rotation.shader",
		"animated": true,
		"description": "",
		"seizure_warning": false
	},
	"flip": {
		"name": "Screen Flip",
		"path": "res://Scripts/Shaders/flip.shader",
		"animated": false,
		"default_params": {
			"angle": 180,
		}, "description": "",
		"seizure_warning": false
	},
	"highlighter": {
		"name": "Highlighter (The Darkener)",
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
