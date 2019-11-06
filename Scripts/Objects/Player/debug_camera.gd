extends Camera2D
class_name DebugCamera

# NOTE (IMPORTANT): The coordinates are measured in pixels.
# The tilemap quadrant size is 16x16 blocks
# The block size is 32x32 pixels.
# To convert coordinates to chunk positions you need to run the formula ((coordinate_x_or_y/16)/32)
# The decimal after the chunk position shows where in the chunk the coordinate is located (if no decimal, then you are at the start of the chunk).
# You may have to give or take a one depending on if the coordinate was negative or positive.

# Declare member variables here. Examples:
var cam_speed : int = 70
var last_position_resize : Vector2
var offset_position_label : Vector2 = Vector2(0, 11)

var player : Node2D
var powerstate_status : String

var date_time : Dictionary
var formatted_time : String
var time_milliseconds : int

var key_color : Color = Color.webgray
var value_color : Color = Color.silver

var value_begin_bbcode : String = "[color=#" + value_color.to_html(true) + "]"
var key_begin_bbcode : String = "[color=#" + key_color.to_html(true) + "]"
var both_end_bbcode : String = "[/color]"

onready var panelChat : Panel = get_tree().get_root().get_node("Player_UI/panelChat")
onready var pauseMenu : Panel = get_tree().get_root().get_node("Player_UI/PauseMenu")

onready var coor_label = $PlayerCoordinates
onready var cam_coor_label = $CameraCoordinates
onready var chunk_position_label = $ChunkPosition
onready var world_name_label = $WorldName
onready var fps_label = $FPS
onready var physics_fps_label = $PhysicsFPS
onready var cpu_usage_label = $CPUUsage
onready var memory_usage_label = $MemoryUsage
onready var battery_label = $BatteryStats
onready var clock_label = $Clock
onready var engine_start_time_label = $TimeSinceStart

onready var crosshair = $Crosshair

onready var world : Node = get_parent().get_parent()
onready var world_generator : TileMap = world.get_node("Viewport/WorldGrid/WorldGen")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_theme(gamestate.game_theme)

	world_generator.connect("chunk_change", self, "update_chunk_label")
	get_tree().get_root().connect("size_changed", self, "screen_size_changed")

	update_world_label()

	set_physics_process(true)

	player = get_player_node()

	update_camera_pos(player.position)
	update_crosshair_pos()
	update_camera_pos_label()
	update_battery_label()
	update_player_pos_label()

func screen_size_changed() -> void:
	# If camera is in same spot as player, then make sure it stays in that position.
	# I may change this to keep the same spot relative to the pixel it was on the screen.
	if (last_position_resize) == player.position:
		update_camera_pos(player.position)

	update_crosshair_pos()

func _process(_delta: float) -> void:
	update_fps_label()
	update_battery_label()
	update_cpu_usage_label()
	update_clock_label()
	update_memory_usage_label()
	update_time_since_start()

func _physics_process(_delta: float) -> void:
	update_physics_fps_label()

#	Stuff That Doesn't Work for SDL (And Therefore Godot)
#	For Some Reason, SDL Does Not Seem To Work With DS4 on Haptic Feedback!!!
#	https://discourse.libsdl.org/t/haptic-broken-for-sixad/20890/8
#
#	Also, Controller Shows As Dead With SDL!!! The one exception is if it was plugged in with a data cable (marked as Plugged In).
#	The weird part is, if I unplug it (and it is also connected by Bluetooth), it still says Plugged In.
#
#	My Goal Is To Figure Out Rumble and LED Color Changes!!!
#
#	There is also the mic, speaker, touchpad capacitive swiping, earphone port, accelerometer, and gyroscope.
#	Also, there's some kind of extension port next to the earphone port and proper battery level detection.
#
#	It appears the external port is used for dock charging and the earphone port can also be used for a keyboard.

	# Doesn't Work With DS4 on OSX
#	logger.warn("Accelerometer: %s" % Input.get_accelerometer()) # Motion of Controller
#	logger.warn("Gravity: %s" % Input.get_gravity()) # Gravity of Controller (May Not Exist in DS4)
#	logger.warn("Gyroscope: %s" % Input.get_gyroscope()) # Rotation of Controller
#	logger.warn("Magnetometer: %s" % Input.get_magnetometer()) # Magnetic Field Strength of Controller (May Not Exist in DS4)

	if pauseMenu.is_paused():
		return

	if not main_loop_events.game_is_focused:
		return

	if Input.is_action_pressed("debug_up") and !panelChat.visible:
		translate(Vector2(0, -cam_speed))
		update_camera_pos_label()
	if Input.is_action_pressed("debug_down") and !panelChat.visible:
		translate(Vector2(0, cam_speed))
		update_camera_pos_label()
	if Input.is_action_pressed("debug_left") and !panelChat.visible:
		if gamestate.mirrored:
			translate(Vector2(cam_speed, 0)) # Right
		else:
			translate(Vector2(-cam_speed, 0)) # Left

		update_camera_pos_label()
	if Input.is_action_pressed("debug_right") and !panelChat.visible:
		if gamestate.mirrored:
			translate(Vector2(-cam_speed, 0)) # Left
		else:
			translate(Vector2(cam_speed, 0)) # Right

		update_camera_pos_label()

	update_player_pos_label()

func get_player_node() -> Node:
	#logger.verbose("Parent: %s" % get_parent().name)
	return spawn_handler.get_player_body_node(gamestate.net_id)

func update_chunk_label(chunk: Vector2) -> void:
	chunk_position_label.bbcode_text = key_begin_bbcode + tr("debug_chunk_label") % [value_begin_bbcode + str(chunk) + both_end_bbcode] + both_end_bbcode

func update_battery_label() -> void:
	match OS.get_power_state():
		OS.POWERSTATE_UNKNOWN:
			powerstate_status = tr("battery_unknown")
		OS.POWERSTATE_ON_BATTERY:
			powerstate_status = tr("battery_battery")
		OS.POWERSTATE_NO_BATTERY:
			powerstate_status = tr("battery_none")
		OS.POWERSTATE_CHARGING:
			powerstate_status = tr("battery_charging")
		OS.POWERSTATE_CHARGED:
			powerstate_status = tr("battery_charged")

	battery_label.bbcode_text = key_begin_bbcode + tr("battery_label") % [value_begin_bbcode + str(OS.get_power_percent_left()) + both_end_bbcode, value_begin_bbcode + str(OS.get_power_seconds_left()) + both_end_bbcode, value_begin_bbcode + powerstate_status + both_end_bbcode] + both_end_bbcode

func update_fps_label() -> void:
	fps_label.bbcode_text = key_begin_bbcode + tr("fps_label") % [value_begin_bbcode + str(Engine.get_frames_per_second()) + both_end_bbcode, value_begin_bbcode + str(Engine.get_frames_drawn()) + both_end_bbcode] + both_end_bbcode

func update_physics_fps_label() -> void:
	physics_fps_label.bbcode_text = key_begin_bbcode + tr("physics_fps_label") % [value_begin_bbcode + str(Engine.get_iterations_per_second()) + both_end_bbcode] + both_end_bbcode

func update_world_label():
	world_name_label.bbcode_text = key_begin_bbcode + tr("world_name_label") % [value_begin_bbcode + world.name + both_end_bbcode] + both_end_bbcode

func update_player_pos_label() -> void:
	# Player's position is based on center of Player, not the edges
	if player != null:
		coor_label.bbcode_text = key_begin_bbcode + tr("player_coordinate_label") % [value_begin_bbcode + str(player.position) + both_end_bbcode] + both_end_bbcode

func update_camera_pos_label() -> void:
	# Get Builtin Screen Size and Find center of screen (add center coordinates to coordinates of camera)
	# This helps locate where the crosshair is (which is only a visual reference for the user. The gdscript does not get position from crosshair)
#	var cross_x = self.position.x + (ProjectSettings.get_setting("display/window/size/width")/2)
#	var cross_y = self.position.y + (ProjectSettings.get_setting("display/window/size/height")/2)

#	var cross_x = self.position.x + (get_viewport().get_visible_rect().size.x/2)
#	var cross_y = self.position.y + (get_viewport().get_visible_rect().size.y/2)

	var cross_x = self.position.x + (get_tree().get_root().size.x/2) + offset_position_label.x # X is correct
	var cross_y = self.position.y + (get_tree().get_root().size.y/2) + offset_position_label.y # Y is off by around 11 pixels (so, add 11 from y position)

#	var cross_x = position.x - (OS.get_real_window_size().x/2)
#	var cross_y = position.y - (OS.get_real_window_size().y/2)

#	var cross_x = self.position.x
#	var cross_y = self.position.y

	var cross_coor = Vector2(cross_x, cross_y)
	last_position_resize = cross_coor

	# Prints center of screen's position in world
	cam_coor_label.bbcode_text = key_begin_bbcode + tr("camera_coordinate_label") % [value_begin_bbcode + str(cross_coor) + both_end_bbcode] + both_end_bbcode

# Relocate Camera to this Specified Position (in middle of screen)
func update_camera_pos(position: Vector2) -> void:
	# Fix this to make it center on player no matter what the screen size is (When stretch mode is disabled)

#	var cross_x = position.x - (ProjectSettings.get_setting("display/window/size/width")/2)
#	var cross_y = position.y - (ProjectSettings.get_setting("display/window/size/height")/2)

#	var cross_x = position.x - (get_viewport().get_visible_rect().size.x/2)
#	var cross_y = position.y - (get_viewport().get_visible_rect().size.y/2)

#	var cross_x = position.x - (get_tree().get_root().size.x/2)
#	var cross_y = position.y - (get_tree().get_root().size.y/2)

	var cross_x = position.x - (OS.get_real_window_size().x/2)
	var cross_y = position.y - (OS.get_real_window_size().y/2)

	self.position = Vector2(cross_x, cross_y)

# warning-ignore:unused_argument
func update_crosshair_pos() -> void:
	# Fix this so that it positions the label exactly in the middle instead of near it.

	var cross_x = (OS.get_real_window_size().x/2) - (crosshair.rect_size.x/2)
	var cross_y = (OS.get_real_window_size().y/2) - (crosshair.rect_size.y/2)

	crosshair.rect_position = Vector2(cross_x, cross_y)

func update_cpu_usage_label() -> void:
	cpu_usage_label.bbcode_text = key_begin_bbcode + "CPU Usage Not Implemented Yet - Need GDNative Module" + both_end_bbcode

func update_memory_usage_label() -> void:
	# warning-ignore:integer_division
	memory_usage_label.bbcode_text = key_begin_bbcode + tr("memory_usage_label") % (value_begin_bbcode + str(OS.get_static_memory_usage()/1000000) + both_end_bbcode) + both_end_bbcode

func update_time_since_start() -> void:
	# warning-ignore:integer_division
	engine_start_time_label.bbcode_text = key_begin_bbcode + tr("engine_start_time_label") % [value_begin_bbcode + str(OS.get_ticks_msec()/1000) + both_end_bbcode, value_begin_bbcode + str(OS.get_ticks_usec()) + both_end_bbcode] + both_end_bbcode

func update_clock_label() -> void:
	date_time = OS.get_datetime()
	time_milliseconds = OS.get_system_time_msecs() - (OS.get_system_time_secs() * 1000)
	formatted_time = tr("datetime_formatting") % [int(date_time["hour"]), int(date_time["minute"]), int(date_time["second"]), time_milliseconds, OS.get_time_zone_info().name]
	clock_label.bbcode_text = key_begin_bbcode + tr("clock_label_formatting") % [value_begin_bbcode + formatted_time + both_end_bbcode] + both_end_bbcode

func set_theme(theme: Theme) -> void:
	coor_label.set_theme(theme)
	cam_coor_label.set_theme(theme)
	chunk_position_label.set_theme(theme)
	world_name_label.set_theme(theme)
	fps_label.set_theme(theme)
	physics_fps_label.set_theme(theme)
	cpu_usage_label.set_theme(theme)
	memory_usage_label.set_theme(theme)
	battery_label.set_theme(theme)
	clock_label.set_theme(theme)
	engine_start_time_label.set_theme(theme)

func get_class() -> String:
	return "DebugCamera"
