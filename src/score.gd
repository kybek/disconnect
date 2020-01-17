extends HBoxContainer

var player_labels = {}


sync func increase_score(for_who: int) -> void:
	assert(for_who in player_labels)
	var pl = player_labels[for_who]
	pl.score += 1
	pl.label.set_text(pl.name + "\n" + str(pl.score))


func add_player(id: int, new_player_name: String) -> void:
	var l: Label = Label.new()
	l.set_align(Label.ALIGN_CENTER)
	l.set_text(new_player_name + "\n" + "0")
	l.set_h_size_flags(SIZE_EXPAND_FILL)
	var font = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/fonts/octavius.ttf"))
	l.add_font_override("font", font)
	l.set("custom_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
	add_child(l)

	player_labels[id] = { name = new_player_name, label = l, score = 0 }


func update_current_player() -> void:
	var current_turn: int = gamestate.current_turn
	var current_player: String = ""
	
	current_turn += 1
	
	for pl in gamestate.player_names.values():
		if current_turn <= 0:
			break
		
		current_player = pl
		current_turn -= 1
	
	get_node("current_player").set_text("Current Player\n" + current_player)


func _ready():
	var l: Label = Label.new()
	l.name = "current_player"
	l.set_align(Label.ALIGN_CENTER)
	l.set_text("Current Player\n")
	l.set_h_size_flags(SIZE_EXPAND_FILL)
	var font = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/fonts/octavius.ttf"))
	l.add_font_override("font", font)
	l.set("custom_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
	add_child(l)
	
	set_process(true)


func _on_exit_game_pressed():
	gamestate.end_game()


func _on_board_increased_score(who: int):
	increase_score(who)
