extends Node

# Used by Shaders Command in client_commands.gd
# warning-ignore:unused_class_variable
var shaders : Dictionary = {
	# LGBT Shaders
	"transgender_flag": {
		"name": "transgender_flag_name",
		"lgbt": true, # Used to Verify That This is A LGBT Shader
		"path": "res://Scripts/Shaders/lgbt/transgender_flag.shader",
		"animated": false,
		"description": "transgender_flag_description",
		"seizure_warning": false
	},
	"polysexual_flag": {
		"name": "polysexual_flag_name",
		"lgbt": true, # Custom Keys Can Be Added To Help With Mods/Builtin Functions to Organize/Setup Shaders
		"path": "res://Scripts/Shaders/lgbt/polysexual_flag.shader",
		"animated": false,
		"description": "polysexual_flag_description",
		"seizure_warning": false
	},
	"pansexual_flag": {
		"name": "pansexual_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/pansexual_flag.shader",
		"animated": false,
		"description": "pansexual_flag_description",
		"seizure_warning": false
	},
	"nonbinary_flag": {
		"name": "nonbinary_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/non-binary_flag.shader",
		"animated": false,
		"description": "nonbinary_flag_description",
		"seizure_warning": false
	},
	"lgbt_flag": {
		"name": "lgbt_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/lgbt_flag.shader",
		"animated": false,
		"description": "lgbt_flag_description",
		"seizure_warning": false
	},
	"lesbian_flag": {
		"name": "lesbian_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/lesbian_flag.shader",
		"animated": false,
		"description": "lesbian_flag_description",
		"seizure_warning": false
	},
	"intersex_flag": {
		"name": "intersex_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/intersex_flag.shader",
		"animated": false,
		"description": "intersex_flag_description",
		"seizure_warning": false
	},
	"genderqueer_flag": {
		"name": "genderqueer_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/genderqueer_flag.shader",
		"animated": false,
		"description": "genderqueer_flag_description",
		"seizure_warning": false
	},
	"genderfluid_flag": {
		"name": "genderfluid_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/genderfluid_flag.shader",
		"animated": false,
		"description": "genderfluid_flag_description",
		"seizure_warning": false
	},
	"bisexual_flag": {
		"name": "bisexual_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/bisexual_flag.shader",
		"animated": false,
		"description": "bisexual_flag_description",
		"seizure_warning": false
	},
	"asexual_flag": {
		"name": "asexual_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/asexual_flag.shader",
		"animated": false,
		"description": "asexual_flag_description",
		"seizure_warning": false
	},
	"aromantic_flag": {
		"name": "aromantic_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/aromantic_flag.shader",
		"animated": false,
		"description": "aromantic_flag_description",
		"seizure_warning": false
	},
	"agender_flag": {
		"name": "agender_flag_name",
		"lgbt": true,
		"path": "res://Scripts/Shaders/lgbt/agender_flag.shader",
		"animated": false,
		"description": "agender_flag_description",
		"seizure_warning": false
	},

	# Other Shaders
	"animated_rainbow": {
		"name": "animated_rainbow_name",
		"path": "res://Scripts/Shaders/third_party/ShaderToy/animated_rainbow_gradient.shader",
		"animated": true,
		"description": "animated_rainbow_description",
		"seizure_warning": false
	},
	"animated_blur": {
		"name": "animated_blur_name",
		"path": "res://Scripts/Shaders/animated_blur.shader",
		"animated": true,
		"description": "animated_blur_description",
		"seizure_warning": false
	},
	"earthquake": {
		"name": "earthquake_name",
		"path": "res://Scripts/Shaders/earthquake.shader",
		"animated": true,
		"description": "earthquake_description",
		"seizure_warning": true # TODO: Find our what to look for to accurately predict potential seizure causing shaders
	},
	"fabric_of_time": {
		"name": "fabric_of_time_name",
		"path": "res://Scripts/Shaders/fabric_of_time.shader",
		"animated": true,
		"description": "fabric_of_time_description",
		"seizure_warning": false
	},
	"grayscale": {
		"name": "grayscale_name",
		"path": "res://Scripts/Shaders/grayscale.shader",
		"animated": false,
		"description": "grayscale_description",
		"seizure_warning": false
	},
	"peeling_back_reality": {
		"name": "peeling_back_reality_name",
		"path": "res://Scripts/Shaders/peeling_back_reality.shader",
		"animated": false,
		"description": "peeling_back_reality_description",
		"seizure_warning": false
	},
	"bcs": {
		"name": "bcs_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/bcs.shader",
		"animated": false,
		"description": "bcs_description",
		"seizure_warning": false
	},
	"blur": {
		"name": "blur_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/blur.shader",
		"animated": false,
		"default_params": {
			"blur": 2.0 # (0-5)
		},
		"description": "blur_description",
		"seizure_warning": false
	},
	"contrasted": {
		"name": "contrasted_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/contrasted.shader",
		"animated": false,
		"description": "contrasted_description",
		"seizure_warning": false
	},
	"fisheye": {
		"name": "fisheye_name",
		"path": "res://Scripts/Shaders/third_party/JEGX/fisheye.shader",
		"animated": false,
		"description": "fisheye_description",
		"seizure_warning": false
	},
	"mirage": {
		"name": "mirage_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/mirage.shader",
		"animated": true,
		"description": "mirage_description",
		"seizure_warning": false
	},
	"negative": {
		"name": "negative_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/negative.shader",
		"animated": false,
		"description": "negative_description",
		"seizure_warning": false
	},
	"normalize": {
		"name": "normalize_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/normalized.shader",
		"animated": false,
		"description": "normalize_description",
		"seizure_warning": false
	},
	"pixelize": {
		"name": "pixelize_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/pixelize.shader",
		"animated": false,
		"description": "pixelize_description",
		"seizure_warning": false
	},
	"sepia": {
		"name": "sepia_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/sepia.shader",
		"animated": false,
		"default_params": {
			"color": Color("#8b6867") # Defaults to Sepia Color
		},
		"description": "sepia_description",
		"seizure_warning": false
	},
	"whirl": {
		"name": "whirl_name",
		"path": "res://Scripts/Shaders/third_party/Official Godot Shaders/whirl.shader",
		"animated": false,
		"description": "whirl_description",
		"seizure_warning": false
	},
	"whirl_strong": {
		"name": "whirl_strong_name",
		"path": "res://Scripts/Shaders/whirl_strong.shader",
		"animated": true,
		"description": "whirl_strong_description",
		"seizure_warning": false
	},
	"animated_whirl": {
		"name": "animated_whirl_name",
		"path": "res://Scripts/Shaders/animated_whirl.shader",
		"animated": false,
		"description": "animated_whirl_description",
		"seizure_warning": false
	},
	"weird_boxy_rotation": {
		"name": "weird_boxy_rotation_name",
		"path": "res://Scripts/Shaders/weird_boxy_rotation.shader",
		"animated": true,
		"description": "weird_boxy_rotation_description",
		"seizure_warning": false
	},
	"flip": {
		"name": "flip_name",
		"path": "res://Scripts/Shaders/flip.shader",
		"animated": false,
		"default_params": {
			"angle": 180,
		}, "description": "flip_description",
		"seizure_warning": false
	},
	"highlighter": {
		"name": "highlighter_name",
		"path": "res://Scripts/Shaders/highlighter.shader",
		"animated": false,
		"default_params": {
			#"shading": Color("#a9a9a9"),
			"color": Color("#0000ff"),
			# The test player's modulation is #0000ff. This is using the Godot icon that comes with a newly generated project.
			"forgiveness": Vector3(0.0, 0.0, 1.0)
		}, "description": "highlighter_description",
		"seizure_warning": false
	},
	"mirror": {
		"name": "mirror_name",
		"path": "res://Scripts/Shaders/mirror.shader",
		"animated": false,
		"description": "mirror_description",
		"seizure_warning": false
	},
}
