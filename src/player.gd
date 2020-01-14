extends Node2D

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

var _class_name : String = "warrior"
var color : Color
var current_turn : int = 0
var turn : int = -1
var player_name

var can_input := false

signal next_turn

remote func move(col : int, by_who : String, color : Color):
	get_node("../../board").move(col, by_who, get_tree().get_rpc_sender_id(), color)


#remotesync func next_turn() -> void:
#	print(get_node("../../players").get_child_count())
#	current_turn = (current_turn + 1) % gamestate.player_count # get_node("../../players").get_child_count()


func _process(_delta):
	current_turn = gamestate.current_turn
	
	if can_input:
#		print(turn, " ", current_turn, " ", gamestate.player_count)
		pass
	
	if can_input and Input.is_action_just_pressed("ui_select"):
		print(gamestate.players)
		if current_turn == turn:
			var col = floor(get_global_mouse_position().x / 64.0)
			print("Trying to make a move on col " + str(col))
			
			var last_move_is_valid = get_node("../../board").move(col, player_name, get_tree().get_network_unique_id(), color)
			
			if last_move_is_valid:
				print("Valid move")
				rpc("move", col, player_name, color)
				emit_signal("next_turn")
			else:
				print("Invalid move")


func set_player_name(new_player_name):
	player_name = new_player_name


func set_turn(new_turn):
	turn = new_turn


func set_class(new_class):
	_class_name = new_class


func _ready():
	color = Color(randf(), randf(), randf(), 1.0)
