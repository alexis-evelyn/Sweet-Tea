extends CanvasLayer
class_name PlayerUI

# Signals
signal cleanup_ui

# Declare member variables here. Examples:
onready var panelPlayerList : Panel = $panelPlayerList
onready var panelChat : Panel = $panelChat
# warning-ignore:unused_class_variable
onready var panelStats : Panel = $panelPlayerStats
onready var pauseMenu : Control = $PauseMenu
onready var alphaGameVersionLabel : RichTextLabel = $alphaGameVersionLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	set_process(true)

	set_theme(gamestate.game_theme)
	set_alpha_game_version_label() # Puts Up Alpha Version Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

func set_alpha_game_version_label() -> void:
	alphaGameVersionLabel.bbcode_text = tr("alpha_game_version_warning_label") % gamestate.game_version

func _input(event: InputEvent) -> void:
	# Checks to See if connected to server (if not, just return)
	if not get_tree().has_network_peer() or not network.connected:
		return

	# Checks To Make Sure Game is Focused
	if not main_loop_events.game_is_focused:
		return

	# Generic Joypad Test Code
	# Not Necessary for Regular InputMap Events
	if event is InputEventJoypadButton:
		# For Detecting Generic Buttons
#		logger.debug("Pressed Joypad Button: %s - Pressure (If Applicable): %s" % [Input.get_joy_button_string(event.get_button_index()), event.get_pressure()])
#		logger.debug("Pressed Joypad Button: %s - Pressure (If Applicable): %s" % [event.get_button_index(), event.get_pressure()])

#		logger.debug("Share Button: %s" % Input.get_joy_button_string(17))
#		logger.debug("Controller GUID 0: %s" % Input.get_joy_guid(0))
#		logger.debug("Controller GUID 1: %s" % Input.get_joy_guid(1))

#		# Fixed Guide (Sony Logo) and Share Button in Godot - https://github.com/alex-evelyn/Godot-3.2-Sweet-Tea/commit/37e8be7946794fba1783c95255a6a23cad167758
#		if event.is_action_pressed("test_guide"):
#			logger.debug("Logo Button Pressed!!!")

#		if event.is_action_pressed("test_share"):
#			logger.debug("Share Button Pressed!!!")

#		if event.get_button_index() == JOY_GUIDE: # PS Button
#			Input.start_joy_vibration(event.get_device(), 1, 1, 3)
#			logger.debug("Device: %s" % event.get_device())
		pass

	elif event is InputEventJoypadMotion:
		# For Detecting Generic Axes.
#		logger.debug("Pressed Joypad Axis: %s - Value (-1.0, 1.0): %s" % [event.get_axis(), event.get_axis_value()])
		pass

	if event is InputEventScreenTouch:
		process_screentouch(event)

	# This allows user to see player list (I will eventually add support to change keys and maybe joystick support)
	if event.is_action("show_playerlist") and !pauseMenu.is_paused():
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		panelPlayerList.show_player_list()

	if event.is_action_released("show_playerlist") and !pauseMenu.is_paused():
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		panelPlayerList.hide_player_list()

	# Makes Chat Window Visible
	if event.is_action_pressed("chat_command") and !pauseMenu.is_paused() and !panelChat.visible and !is_calc_open():
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		panelChat.show_panelchat() # Prevent's Input from Being Sent to Any _unhandled_input functions
		panelChat.get_node("userChat").grab_focus() # Causes LineEdit (where user types) to grab focus of keyboard
		panelChat.get_node("userChat").set_text("/") # Replaces text with a Forward Slash
		panelChat.get_node("userChat").set_cursor_position(1) # Moves Caret In Front of Slash
		panelChat.just_opened = true

	if event.is_action_pressed("chat_show") and !pauseMenu.is_paused() and !panelChat.visible and !is_calc_open():
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		panelChat.show_panelchat()
		panelChat.get_node("userChat").grab_focus() # Causes LineEdit (where user types) to grab focus of keyboard
		panelChat.just_opened = true

	# Makes Chat Window Invisible
	if event.is_action_pressed("chat_hide") and !pauseMenu.is_paused() and panelChat.visible:
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		panelChat.hide_panelchat()
		return # Prevents Forwarding Escape Key to Pause Menu

	if event.is_action_pressed("pause") and !pauseMenu.visible:
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		pauseMenu.pause()
	elif event.is_action_pressed("resume") and pauseMenu.visible:
		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		pauseMenu.resume()

	if Input.is_action_just_released("toggle_fullscreen") and !panelChat.visible:
		# For some reason this gets buggy and takes over all controls if using is_action_pressed(...).
		# So, is_action_just_released it is then.

		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions

		if OS.window_fullscreen:
			OS.window_fullscreen = false
		else:
			OS.window_fullscreen = true

	detect_command_presses(event) # Detect When Command Actions Are Pressed

# Make Sure Game Saves World On Quit or Crash
func _notification(what: int) -> void:
	# This isn't an override of the normal behavior, it just allows listening for the events and doing something based on the event happening.

	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			# This will run no matter if autoquit is on. Disabling autoquit just means that I can quit when needed (so I don't get interrupted, say if I am saving data).
			if not get_tree().has_network_peer():
				return

			network.close_connection()
			logger.info("Saved Worlds On Quit!!!")
			#main_loop_events.quit()
		MainLoop.NOTIFICATION_CRASH:
			# I don't know if this will work on crash as I have not had an opportunity to properly crash my game to test it.
			if not get_tree().has_network_peer():
				return

			network.close_connection()
			logger.info("Saved Worlds On Crash!!!")

# Cleanup PlayerUI
func cleanup() -> void:
	#logger.verbose("Cleanup PlayerUI")
	emit_signal("cleanup_ui") # Both Standard Code and Modded Code Should Listen for this Signal

# Sets PlayerUI Theme
func set_theme(theme) -> void:
	$panelPlayerList.set_theme(theme)
	$panelPlayerStats.set_theme(theme)
	$panelChat.set_theme(theme)

# Checks if Calculator is Open (from Easter Eggs)
func is_calc_open() -> bool:
	return get_tree().get_root().has_node("Calculator")

func detect_command_presses(event: InputEvent) -> void:
	# Test For Assigning Hotkeys to Commands
	if event.is_action_pressed("command_0") and !pauseMenu.is_paused():
		# TODO: Figure Out How To Read ID in Command Action (To Help with Modding More Commands)

		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		functions.run_button_command(panelChat, "0") # Activate Command Assigned to Command 0
#		functions.run_axes_command(panelChat, "0") # Activate Command Assigned to Command 0

	if event.is_action_pressed("command_1") and !pauseMenu.is_paused():
		# TODO: Figure Out How To Read ID in Command Action (To Help with Modding More Commands)

		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		functions.run_button_command(panelChat, "1") # Activate Command Assigned to Command 0
#		functions.run_axes_command(panelChat, "1") # Activate Command Assigned to Command 0

	if event.is_action_pressed("command_2") and !pauseMenu.is_paused():
		# TODO: Figure Out How To Read ID in Command Action (To Help with Modding More Commands)

		get_tree().set_input_as_handled() # Prevent's Input from Being Sent to Any _unhandled_input functions
		functions.run_button_command(panelChat, "2") # Activate Command Assigned to Command 0
#		functions.run_axes_command(panelChat, "1") # Activate Command Assigned to Command 0

func process_screentouch(event: InputEvent) -> void:
#	event.get_index()
#	event.get_position()
#	event.is_pressed()

	# I am not officially supporting mobile devices, I am just allowing unofficial binaries to be made while I work on the desktop versions.
	# Do note, if an unofficial port is made, make sure it still uses my same auth server. Anything else can be changed (e.g. improve performance, better controls, etc...).
	# Just make sure it is obvious it is not an official port. See the License File For More Detail.
	if OS.has_virtual_keyboard():
		if OS.get_virtual_keyboard_height() == 0: # If the height is 0, the keyboard is not visible.
			OS.show_virtual_keyboard()
		else:
			OS.hide_virtual_keyboard()

func get_class() -> String:
	return "PlayerUI"
