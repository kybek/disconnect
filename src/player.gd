extends Node2D

var power_name: String = "none"
var color: Color
var my_turn: int = -1
var player_name
var can_input: bool = false
var power_uses: int = 0

signal next_turn
signal prev_turn


func _process(_delta):
	var current_turn: int = gamestate.current_turn
	
	if can_input and Input.is_action_just_pressed("ui_select"):
		if current_turn == my_turn:
			var col = floor(get_global_mouse_position().x / 64.0)
			gamestate.rpc_id(1, "request_move", col)
	
	if can_input and Input.is_action_just_pressed("use_power") and power_uses > 0:
		if power_name == "rewind":
			gamestate.rpc_id(1, "request_rewind")
	
	if can_input:
		if Input.is_action_pressed("ui_focus_next"):
			get_node("../../board").modulate = Color(0.5, 0.5, 0.5, 0.5)
			get_node("../../background").modulate = Color(0.5, 0.5, 0.5, 0.5)
			get_node("../../baseground").modulate = Color(0.5, 0.5, 0.5, 1.0)
			get_node("../../score").show()
		else:
			get_node("../../board").modulate = Color(1.0, 1.0, 1.0, 1.0)
			get_node("../../background").modulate = Color(1.0, 1.0, 1.0, 1.0)
			get_node("../../baseground").modulate = Color(1.0, 1.0, 1.0, 1.0)
			get_node("../../score").hide()