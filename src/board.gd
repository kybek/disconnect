extends Node2D

export var cols : int = 16
export var rows : int = 9

var stones := {}

signal increase_score(who)

func last_empty_row(col : int) -> int:
	if not (col >= 0 && col < cols):
		print("INVALID COLOUMN NUMBER: " + str(col))
		return -1
	
	for row in range(rows - 1, -1, -1):
		if stones[row][col] == null:
			return row
	
	return -1


const dirs = [
	[0, -1],
	[1, -1],
	[1, 0],
	[1, 1],
	[0, 1],
	[-1, 1],
	[-1, 0],
	[-1, -1]
]


func out_of_range(row : int, col : int) -> bool:
	return row < 0 or row >= rows or col < 0 or col >= cols


func four_connect(row : int, col : int, dir : Array, color : Color) -> bool:
	for i in range(0, 4):
		if out_of_range(row, col):
			return false
		
		if stones[row][col] == null or stones[row][col].get_node("sprite").modulate != color:
			return false
		
		row += dir[0]
		col += dir[1]
	
	return true


func how_many(color : Color) -> int:
	var cnt : int = 0
	
	for row in range(0, rows):
		for col in range(0, cols):
			for dir in dirs:
				if four_connect(row, col, dir, color):
					cnt += 1
	
	return cnt / 2

func move(col : int, by_who : String, id : int, color : Color) -> bool:
	print(col, by_who, color)
	print("TRYING TO MAKE A MOVE")
	assert(stones != {})
	
	var row = last_empty_row(col)
	
	if row == -1:
		return false
	
	var score_before = how_many(color)
	
	var stone_scene = load("res://src/stone.tscn")
	var stone = stone_scene.instance()
	
	stone.get_node("by_who").text = str(by_who)
	stone.position = Vector2(col * 64 + 32, row * 64 + 32)
	stone.get_node("sprite").modulate = color
	add_child(stone)
	stones[row][col] = stone
	
	var score_after = how_many(color)
	
	for i in range(score_after - score_before):
		emit_signal("increase_score", id)
	
	return true


func _input(event):
	if event is InputEventMouse:
		var col = floor(get_global_mouse_position().x / 64.0)
		
		if col < cols:
			get_node("../background/highlight").rect_position = Vector2(col * 64.0, 0.0)


func make_board(rows : int, cols : int):
	assert(rows > 0 and rows <= 9)
	assert(cols > 0 and cols <= 16)
	
	self.rows = rows
	self.cols = cols
	
	for row in stones.keys():
		for col in stones[row].keys():
			var stone = stones[row][col]
			
			if stone != null:
				remove_child(stone)
	
	stones = {}
	
	for row in range(0, rows):
		if not stones.has(row):
			stones[row] = {}
		
		for col in range(0, cols):
			stones[row][col] = null
	
	get_node("../background").rect_size = Vector2(cols * 64.0, rows * 64.0)
	get_node("../background/highlight").rect_size = Vector2(64.0, rows * 64.0)


func _ready():
#	make_board(9, 16)
	pass
