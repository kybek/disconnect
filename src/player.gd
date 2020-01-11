extends Node2D

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

var _class_name : String = "warrior"
var color : Color
var turn : int = 0
var player_name

var last_move_is_valid = false

# Use sync because it will be called everywhere
sync func move(row : int, by_who : int, color : Color):
	last_move_is_valid = get_node("../../board").move(row, by_who, color)


sync func next_turn() -> void:
	gamestate.current_turn = (gamestate.current_turn + 1) % get_node("../../players").get_child_count()


func _process(_delta):
	if Input.is_action_pressed("ui_select"):
		if gamestate.current_turn == turn:
			var col = floor(get_global_mouse_position().x / 64.0)
			print("Trying to make a move on col " + str(col))
			
			rpc("move", col, get_tree().get_network_unique_id(), color)
			
			if last_move_is_valid:
				print("Valid move")
				next_turn()
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
