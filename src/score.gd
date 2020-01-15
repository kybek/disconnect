extends HBoxContainer

var player_labels = {}

#func _process(_delta):
#	var rocks_left = 0 # get_node("../rocks").get_child_count()
#	if rocks_left == 0:
#		var winner_name = ""
#		var winner_score = -1
#		for p in player_labels:
#			if player_labels[p].score > winner_score:
#				winner_score = player_labels[p].score
#				winner_name = player_labels[p].name

#		get_node("../winner").set_text("THE WINNER IS:\n" + winner_name)
#		get_node("../winner").show()

sync func increase_score(for_who):
	assert(for_who in player_labels)
	var pl = player_labels[for_who]
	pl.score += 1
	pl.label.set_text(pl.name + "\n" + str(pl.score))

func add_player(id, new_player_name):
	var l : Label = Label.new()
	l.set_align(Label.ALIGN_CENTER)
	l.set_text(new_player_name + "\n" + "0")
	l.set_h_size_flags(SIZE_EXPAND_FILL)
	var font = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/montserrat.otf"))
	l.add_font_override("font", font)
	l.set("custom_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
	add_child(l)

	player_labels[id] = { name = new_player_name, label = l, score = 0 }



func update_current_player():
	var current_turn := gamestate.current_turn
	var current_player := ""
	
	current_turn += 1
	
	for pl in gamestate.player_names.values():
		print(current_turn, pl)
		if current_turn <= 0:
			break
		
		current_player = pl
		current_turn -= 1
	
	get_node("current_player").set_text("Current Player\n" + current_player)


func _ready():
#	get_node("../winner").hide()
	
	var l : Label = Label.new()
	l.name = "current_player"
	l.set_align(Label.ALIGN_CENTER)
	l.set_text("Current Player\n")
	l.set_h_size_flags(SIZE_EXPAND_FILL)
	var font = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/montserrat.otf"))
	l.add_font_override("font", font)
	l.set("custom_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
	add_child(l)
	
	set_process(true)

func _on_exit_game_pressed():
	gamestate.end_game()

func _on_board_increase_score(who):
	increase_score(who)
