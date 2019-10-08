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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	set_process(true)

	set_theme(gamestate.game_theme)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

func _input(event) -> void:
	# This statement can run regardless if world is loaded.
	if Input.is_action_pressed("toggle_fullscreen") and !panelChat.visible:
			if OS.window_fullscreen:
				OS.window_fullscreen = false
			else:
				OS.window_fullscreen = true

	# Checks to See if connected to server (if not, just return)
	if not get_tree().has_network_peer() or not network.connected:
		return

	if event is InputEventJoypadButton:
		logger.debug("Pressed Joypad Button: %s - Pressure (If Applicable): %s" % [Input.get_joy_button_string(event.get_button_index()), event.get_pressure()])
#		logger.debug("Pressed Joypad Button: %s - Pressure (If Applicable): %s" % [event.get_button_index(), event.get_pressure()])

#		logger.debug("Share Button: %s" % Input.get_joy_button_string(17))
#		logger.debug("Controller GUID 0: %s" % Input.get_joy_guid(0))
#		logger.debug("Controller GUID 1: %s" % Input.get_joy_guid(1))

		# Fixed Guide (Sony Logo) and Share Button in Godot - https://github.com/alex-evelyn/Godot-3.2-Sweet-Tea/commit/37e8be7946794fba1783c95255a6a23cad167758
		if event.is_action_pressed("test_guide"):
			logger.debug("Logo Button Pressed!!!")

		if event.is_action_pressed("test_share"):
			logger.debug("Share Button Pressed!!!")

		if event.get_button_index() == JOY_GUIDE: # PS Button
			Input.start_joy_vibration(event.get_device(), 1, 1, 3)
#			logger.debug("Device: %s" % event.get_device())

	elif event is InputEventJoypadMotion:
#		logger.debug("Pressed Joypad Axis: %s - Value (-1.0, 1.0): %s" % [event.get_axis(), event.get_axis_value()])
		pass


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

func get_class() -> String:
	return "PlayerUI"
