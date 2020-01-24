extends Node2D

var power_name: String = "none"
var color: Color
var my_turn: int = -1
var player_name
var can_input: bool = false
var power_uses: int = 0

signal next_turn
signal prev_turn

#
#sync func move(col: int, by_who: String, color: Color) -> void:
#	get_node("../../board").move(col, by_who, get_tree().get_rpc_sender_id(), color)
#
#
#sync func undo_last_move() -> void:
#	get_node("../../board").undo_last_move()


func _process(_delta):
	var current_turn: int = gamestate.current_turn
	
	if can_input and Input.is_action_just_pressed("ui_select"):
		if current_turn == my_turn:
			var col = floor(get_global_mouse_position().x / 64.0)
			gamestate.rpc_id(1, "request_move", col)
	
	if can_input and Input.is_action_just_pressed("use_power"):
		if power_name == "rewind":
			gamestate.rpc_id(1, "request_rewind")
