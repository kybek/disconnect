extends Node2D

export var cols : int = 15
export var rows : int = 9

var stones : Dictionary

func last_empty_row(col : int) -> int:
	if not (col >= 0 && col < cols):
		print("INVALID COLOUMN NUMBER: " + str(col))
		return -1
	
	for row in range(rows - 1, -1, -1):
		if stones[row][col] == null:
			return row
	
	return -1


func move(col : int, by_who : String, color : Color) -> bool:
	print(col, by_who, color)
	print("TRYING TO MAKE A MOVE")
	var row = last_empty_row(col)
	
	if row == -1:
		return false
	
	var stone_scene = load("res://src/stone.tscn")
	var stone = stone_scene.instance()
	
	stone.get_node("by_who").text = str(by_who)
	stone.position = Vector2(col * 64 + 32, row * 64 + 32)
	stone.modulate = color
	add_child(stone)
	stones[row][col] = stone
	
	return true


func _ready():
	for row in range(0, rows):
		if not stones.has(row):
			stones[row] = {}
		
		for col in range(0, cols):
			stones[row][col] = null
	
	get_node("../background").rect_size = Vector2(cols * 64.0, rows * 64.0)
