extends Node

func _ready():
	# Define mouse left click as an InputEvent
	var mouse_left_click = InputEventMouseButton.new()
	mouse_left_click.set_button_index(BUTTON_LEFT)
	mouse_left_click.set_pressed(true)
	
	# Add mouse left click to ui_select options
	InputMap.action_add_event("ui_select", mouse_left_click)
	
	# Add power action
	InputMap.add_action("use_power")
	
	# Define mouse left click as an InputEvent
	var mouse_right_click = InputEventMouseButton.new()
	mouse_right_click.set_button_index(BUTTON_RIGHT)
	mouse_right_click.set_pressed(true)
	
	# Add mouse right click to use_power options
	InputMap.action_add_event("use_power", mouse_right_click)
