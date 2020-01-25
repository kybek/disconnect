extends Panel

# Player label dictionary
#	"name":		Name of the player
#	"label":	Label assigned to the player
#	"score":	Score of the player
#	"power":	Power of player
#	"uses":		Numer of remaining power uses
var player_labels = {}

onready var score_label_scene = preload("res://src/score_label.tscn")

# Increases score for specified player
func increase_score(player_id: int) -> void:
	assert(player_id in player_labels)
	# Find the player_entry using player_id
	var player_entry : Dictionary = player_labels[player_id]
	# Increase the score of the entry
	player_entry.score += 1
	# Update the text on the entry's label
	player_entry.label.set_score(str(player_entry.score))

# Decreases score for specified player
func decrease_score(player_id: int) -> void:
	assert(player_id in player_labels)
	# Find the player_entry using player_id
	var player_entry : Dictionary = player_labels[player_id]
	# Increase the score of the entry
	player_entry.score -= 1
	# Update the text on the entry's label
	player_entry.label.set_score(str(player_entry.score))

# Decreases power uses on all peers for specified player
sync func decrease_power_uses(player_id: int) -> void:
	assert(player_id in player_labels)
	# Find the player_entry using player_id
	var player_entry : Dictionary = player_labels[player_id]
	# Increase the score of the entry
	player_entry.uses -= 1
	# Update the text on the entry's label
	player_entry.label.set_power_uses(str(player_entry.uses))

# Add a new player to score table
func add_player(player_id: int, player_name: String, power_name: String) -> void:
	assert(not player_id in player_labels)
	
	# Create a new label to assign to the new player
	var label: Label = score_label_scene.instance()
	label.set_align(Label.ALIGN_CENTER)
	label.set_player_name(player_name)
	label.set_score("0")
	label.set_power(power_name)
	label.set_power_uses(str(powers.cap[power_name]))
	
	get_node("container").add_child(label)
	# Add the player to the player label dictionary
	player_labels[player_id] = {
		"name": player_name,
		"label": label,
		"score": 0,
		"power": power_name,
		"uses": powers.cap[power_name]
	}

# Update current player label
func update_current_player() -> void:
	var current_turn: int = gamestate.current_turn
	var current_player_id: int = gamestate.player_turns[current_turn]
	var current_player_name: String = gamestate.player_names[current_player_id]
	get_node("container").get_node("current_player").set_text("Current player is " + current_player_name)


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
#	label.set("custom_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
	
	get_node("container").add_child(label)
	
	# Create scoreboard infos
	var info_label: Label = score_label_scene.instance()
	info_label.set_align(Label.ALIGN_CENTER)
	info_label.set_player_name("player name")
	info_label.set_score("score")
	info_label.set_power("power name")
	info_label.set_power_uses("power uses")
	
	get_node("container").add_child(info_label)


func _on_exit_game_pressed():
	gamestate.end_game()


func _on_board_increased_score(who: int):
	increase_score(who)


func _on_board_decreased_score(who):
	decrease_score(who)
