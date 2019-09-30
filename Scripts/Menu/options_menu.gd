extends Control
class_name OptionsMenu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
	pass # Replace with function body.

func get_class() -> String:
	return "OptionsMenu"
