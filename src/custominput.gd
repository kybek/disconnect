extends Node

func _ready():
	# Define mouse left click as an InputEvent
	var mouse_left_click = InputEventMouseButton.new()
	mouse_left_click.set_button_index(BUTTON_LEFT)
	mouse_left_click.set_pressed(true)
	
	# Add mouse left click to ui_select options
	InputMap.action_add_event("ui_select", mouse_left_click)
