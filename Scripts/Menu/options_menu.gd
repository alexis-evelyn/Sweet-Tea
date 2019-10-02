extends Control
class_name OptionsMenu

# Declare member variables here. Examples:

# Option Labels
onready var locale_label : RichTextLabel = $Scroll/Center/Options/Locale/lblLocale
onready var keyboard_config_label : RichTextLabel = $Scroll/Center/Options/KeyboardConfig/lblKeyboardConfig
onready var keyboard_button : Button = $Scroll/Center/Options/KeyboardConfig/btnKeyboardConfig
onready var fullscreen_label : RichTextLabel = $Scroll/Center/Options/Fullscreen/lblFullscreen
onready var window_size_label : RichTextLabel = $Scroll/Center/Options/WindowSize/lblWindowSize
onready var vsync_label : RichTextLabel = $Scroll/Center/Options/VSync/lblVSync
onready var fps_label : RichTextLabel = $Scroll/Center/Options/Fullscreen/lblFullscreen
onready var shader_usage_label : RichTextLabel = $Scroll/Center/Options/ShaderUsage/lblShaderUsage
onready var music_volume_label : RichTextLabel = $Scroll/Center/Options/MusicVolume/lblMusicVolume
onready var sound_volume_label : RichTextLabel = $Scroll/Center/Options/SoundVolume/lblSoundVolume
onready var lpum_label : RichTextLabel = $Scroll/Center/Options/LPUM/lblLPUM
onready var physics_fps_label : RichTextLabel = $Scroll/Center/Options/PhysicsFPS/lblPhysicsFPS
onready var physics_jitter_fix_label : RichTextLabel = $Scroll/Center/Options/PhysicsFPS/lblPhysicsFPS
onready var timescale_label : RichTextLabel = $Scroll/Center/Options/TimeScale/lblSelectedTimeScale

# Category Labels
onready var controls_label : RichTextLabel = $Scroll/Center/Options/lblControls
onready var video_label : RichTextLabel = $Scroll/Center/Options/lblVideo
onready var audio_label : RichTextLabel = $Scroll/Center/Options/lblAudio
onready var advanced_setting_label : RichTextLabel = $Scroll/Center/Options/lblAdvancedSetting

# Option Values
onready var selected_locale : RichTextLabel = $Scroll/Center/Options/Locale/lblSelectedLocale
onready var fullscreen_checkbox : CheckBox = $Scroll/Center/Options/Fullscreen/ckbFullscreen
onready var window_size_slider : Slider = $Scroll/Center/Options/WindowSize/sldWindowSize
onready var vsync_checkbox : CheckBox = $Scroll/Center/Options/VSync/ckbVSync
onready var fps_value_label : RichTextLabel = $Scroll/Center/Options/FPS/lblSelectedFPS
onready var shader_usage_value_label : RichTextLabel = $Scroll/Center/Options/ShaderUsage/lblSelectedShaderUsage
onready var music_volume_slider : Slider = $Scroll/Center/Options/MusicVolume/sldMusicVolume
onready var sound_volume_slider : Slider = $Scroll/Center/Options/SoundVolume/sldSoundVolume
onready var lpum_checkbox : CheckBox = $Scroll/Center/Options/LPUM/ckbLPUM
onready var physics_fps_value_label : RichTextLabel = $Scroll/Center/Options/PhysicsFPS/lblSelectedPhysicsFPS
onready var physics_jitter_fix_value_label : RichTextLabel = $Scroll/Center/Options/PhysicsJitterFix/lblSelectedJitterPhysicsFix
onready var time_scale_value_label : RichTextLabel = $Scroll/Center/Options/TimeScale/lblSelectedTimeScale

# Options
# Set Locale - TranslationServer.set_locale("en") and gamestate.player_info.locale = TranslationServer.get_locale()

# Controls
# Keyboard Config - Menu...
# Controller Config - Menu...

# Video
# Fullscreen - OS.window_fullscreen = true
# Window Size - OS.set_window_size(Vector2(640, 480))
# VSync - OS.vsync_enabled = true
# FPS - Engine.set_target_fps(30) # Rendering FPS - Default Unlimited
# Shader Usage - ...Performance Reasons

# Audio
# Music - Range...
# Sounds - Range...

# Advanced Settings
# Low Processor Usage Mode - OS.low_processor_usage_mode = true
# Physics FPS - Engine.set_iterations_per_second(30) # Physics FPS - Default 60
# Physics Jitter Fix - Engine.set_physics_jitter_fix(1) # Default 0.5 - No Idea How This Value Works
# Time Scale - Engine.set_time_scale(1) # How fast the game clock runs compared to realtime.
# ...

# Called when the node enters the scene tree for the first time.
func _ready():
	translate_labels_to_locale() # Translate Labels to Currently Set Locale
	retrieve_current_values() # Retrieve Current Values and Set in Options Menu

	set_theme(gamestate.game_theme)

func translate_labels_to_locale() -> void:
	"""
		...
	"""

	pass

func retrieve_current_values() -> void:
	"""
		...
	"""

	# Locale
	selected_locale.bbcode_text = TranslationServer.get_locale_name(TranslationServer.get_locale())

	# Fullscreen Checkbox
	fullscreen_checkbox.pressed = OS.window_fullscreen

	# Window Size Slider
	window_size_slider.value = 100.0 # Not Implemented Yet
	# OS.set_window_size(Vector2(640, 480))

	# VSync Checkbox
	vsync_checkbox.pressed = OS.vsync_enabled

	# FPS Value Label
	fps_value_label.text = str(Engine.target_fps)
	# Engine.set_target_fps(30)

	# Shader Usage Value Label
	shader_usage_value_label.text = "Not Implemented Yet"

	# Audio Sliders
	music_volume_slider.value = 100.0
	sound_volume_slider.value = 100.0

	# Low Process Usage Mode Checkbox
	lpum_checkbox.pressed = OS.low_processor_usage_mode

	# Physics FPS Value Label
	physics_fps_value_label.text = str(Engine.get_iterations_per_second())

	# Physics Jitter Fix Value Label
	physics_jitter_fix_value_label.text = str(Engine.physics_jitter_fix)

	# Time Scale Value Label
	time_scale_value_label.text = str(Engine.time_scale)

func locale_left_pressed() -> void:
	pass # Replace with function body.

func locale_right_pressed() -> void:
	pass # Replace with function body.

func open_keyboard_config_pressed() -> void:
	pass # Replace with function body.

func fullscreen_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed

func window_size_changed(value: float) -> void:
	pass # Replace with function body.

func vsync_toggled(button_pressed: bool) -> void:
	OS.vsync_enabled = button_pressed

func fps_left_pressed() -> void:
	pass # Replace with function body.

func fps_right_pressed() -> void:
	pass # Replace with function body.

func shader_usage_left_pressed() -> void:
	pass # Replace with function body.

func shader_usage_right_pressed() -> void:
	pass # Replace with function body.

func music_volume_changed(value: float) -> void:
	pass # Replace with function body.

func sound_volume_changed(value: float) -> void:
	pass # Replace with function body.

func low_process_usage_mode_toggled(button_pressed: bool) -> void:
	OS.low_processor_usage_mode = button_pressed

func physics_fps_left_pressed() -> void:
	pass # Replace with function body.

func physics_fps_right_pressed() -> void:
	pass # Replace with function body.

func physics_jitter_left_pressed() -> void:
	pass # Replace with function body.

func physics_jitter_right_pressed() -> void:
	pass # Replace with function body.

func time_scale_left_pressed() -> void:
	pass # Replace with function body.

func time_scale_right_pressed() -> void:
	pass # Replace with function body.

func get_class() -> String:
	return "OptionsMenu"

func set_theme(theme: Theme) -> void:
	.set_theme(theme)
