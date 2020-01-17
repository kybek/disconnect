extends HBoxContainer

# Player label dictionary
#   "name":		Name of the player
#   "label":	Label assigned to the player
#   "score":	Score of the player
var player_labels = {}

# Increases score on all peers for specified player
sync func increase_score(player_id: int) -> void:
	assert(player_id in player_labels)
	# Find the player_entry using player_id
	var player_entry : Dictionary = player_labels[player_id]
	# Increase the score of the entry
	player_entry.score += 1
	# Update the text on the entry's label
	player_entry.label.set_text(player_entry.name + "\n" + str(player_entry.score))

# Decreases score on all peers for specified player
sync func decrease_score(player_id: int) -> void:
	assert(player_id in player_labels)
	# Find the player_entry using player_id
	var player_entry : Dictionary = player_labels[player_id]
	# Increase the score of the entry
	player_entry.score -= 1
	# Update the text on the entry's label
	player_entry.label.set_text(player_entry.name + "\n" + str(player_entry.score))

# Add a new player to score table
func add_player(player_id: int, player_name: String) -> void:
	assert(not player_id in player_labels)
	
	# Create a new label to assign to the new player
	var label: Label = Label.new()
	label.set_align(Label.ALIGN_CENTER)
	label.set_text(player_name + "\n" + "0")
	label.set_h_size_flags(SIZE_EXPAND_FILL)
	
	# Create a new dynamic font and set it as the label's font
	var font: DynamicFont = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/fonts/octavius.ttf"))
	label.add_font_override("font", font)
	label.set("custom_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
	
	add_child(label)
	# Add the player to the player label dictionary
	player_labels[player_id] = {
		"name": player_name,
		"label": label,
		"score": 0
	}

# Update current player label
func update_current_player() -> void:
	var current_turn: int = gamestate.current_turn
	var current_player_id: int = gamestate.player_turns[current_turn]
	var current_player_name: String = gamestate.player_names[current_player_id]
	get_node("current_player").set_text("Current Player\n" + current_player_name)


func _process(delta):
	update_current_player()


func _ready():
	# Create current player label
	var label: Label = Label.new()
	label.name = "current_player"
	label.set_align(Label.ALIGN_CENTER)
	label.set_text("Current Player\n")
	label.set_h_size_flags(SIZE_EXPAND_FILL)
	
	# Create the font for current player label
	var font: DynamicFont = DynamicFont.new()
	font.set_size(18)
	font.set_font_data(preload("res://assets/fonts/octavius.ttf"))
	label.add_font_override("font", font)
	label.set("custom_colors/font_color", Color(0.0, 0.0, 0.0, 1.0))
	
	add_child(label)
	
#	set_process(true)


func _on_exit_game_pressed():
	gamestate.end_game()


func _on_board_increased_score(who: int):
	increase_score(who)


func _on_board_decreased_score(who):
	decrease_score(who)
