extends KinematicBody2D

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

var _class_name : String = "warrior"
var color : Color

# Use sync because it will be called everywhere
sync func move(row : int, by_who : int, _class_name : int):
	var valid_move = get_node("../../board").move(row, by_who, color)
	

sync func next_turn() -> void:
	for player in get_node("../../players"):
		pass


func _physics_process(_delta):
	if Input.is_action_just_pressed("show_info"):
		


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	color = Color(randf(), randf(), randf(), 1.0)
	current_player = get_node("../../players")