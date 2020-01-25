extends HBoxContainer

class_name ScoreLabel

func set_player_name(player_name: String) -> void:
	get_node("player_name").set_text(player_name)


func set_score(score: String) -> void:
	get_node("score").set_text(score)


func set_power(power_name: String) -> void:
	get_node("power").set_text(power_name)


func set_power_uses(power_uses: String) -> void:
	get_node("power_uses").set_text(power_uses)


func set_align(align_mode: int) -> void:
	for child in get_children():
		if child is Label:
			child.set_align(align_mode)


func _ready():
	for child in get_children():
		if child is Label:
			# Create a new dynamic font and set it as the label's font
			var font: DynamicFont = DynamicFont.new()
			font.set_size(18)
			font.set_font_data(preload("res://assets/fonts/octavius.ttf"))
			child.add_font_override("font", font)
			child.set("custom_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
