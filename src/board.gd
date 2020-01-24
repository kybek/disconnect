extends Node2D

export var cols: int = 16
export var rows: int = 9

var stones: Dictionary = {}
var moves: Array = []

signal increased_score(who)
signal decreased_score(who)


func last_empty_row(col: int) -> int:
	if col < 0 or col >= cols:
		return -1
	
	for row in range(rows - 1, -1, -1):
		if stones[row][col] == null:
			return row
	
	return -1


const dirs: Array = [
	[0, -1],
	[1, -1],
	[1, 0],
	[1, 1],
	[0, 1],
	[-1, 1],
	[-1, 0],
	[-1, -1]
]


func out_of_range(row: int, col: int) -> bool:
	return row < 0 or row >= rows or col < 0 or col >= cols


func four_connect(row: int, col: int, dir: Array, color: Color) -> bool:
	for i in range(0, 4):
		if out_of_range(row, col):
			return false
		
		if stones[row][col] == null or stones[row][col].get_node("sprite").modulate != color:
			return false
		
		row += dir[0]
		col += dir[1]
	
	return true


func how_many(color: Color) -> int:
	var cnt : int = 0
	
	for row in range(0, rows):
		for col in range(0, cols):
			for dir in dirs:
				if four_connect(row, col, dir, color):
					cnt += 1
	
	return cnt / 2


func move(col : int, by_who: String, id: int, color: Color) -> bool:
	assert(stones != {})
	
	var row = last_empty_row(col)
	
	if row == -1:
		return false
	
	var score_before = how_many(color)
	
	var stone_scene = load("res://src/stone.tscn")
	var stone = stone_scene.instance()
	
	stone.get_node("by_who").text = by_who
	stone.get_node("id").text = str(id)
	stone.position = Vector2(col * 64 + 32, row * 64 + 32)
	stone.get_node("sprite").modulate = color
	add_child(stone)
	stones[row][col] = stone
	
	var score_after = how_many(color)
	
	for i in range(score_after - score_before):
		emit_signal("increased_score", id)
	
	moves.append([row, col])
	
	return true


func undo_last_move() -> bool:
	if len(moves) == 0:
		return true
	
	var row: int = moves.back()[0]
	var col: int = moves.back()[1]
	moves.pop_back()
	
	assert(stones[row][col] != null)
	
	var stone = stones[row][col]
	var color: Color = stone.get_node("sprite").modulate
	var id: int = int(stone.get_node("id").text)
	var score_before: int = how_many(color)
	
	remove_child(stone)
	stones[row][col] = null
	
	var score_after: int = how_many(color)
	
	for i in range(score_before - score_after):
		emit_signal("decreased_score", id)
	
	return true


func _input(event):
	if event is InputEventMouse:
		var col = floor(get_global_mouse_position().x / 64.0)
		
		if col >= 0 and col < cols:
			get_node("../background/highlight").rect_position = Vector2(col * 64.0, 0.0)


func make_board(rows: int, cols: int):
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
	get_node("../Camera2D").position = Vector2(cols * 64.0 / 2, rows * 64.0 / 2)
	get_node("../score").rect_position = Vector2(cols * 64.0 / 2 - 512, rows * 64.0 / 2 - 300)
	get_node("borders").points = PoolVector2Array()
	get_node("borders").add_point(get_node("../background").rect_global_position)
	get_node("borders").add_point(Vector2(
										get_node("../background").rect_global_position.x
										+ get_node("../background").rect_size.x,
										get_node("../background").rect_global_position.y))
	get_node("borders").add_point(Vector2(
										get_node("../background").rect_global_position.x
										+ get_node("../background").rect_size.x,
										get_node("../background").rect_global_position.y
										+ get_node("../background").rect_size.y))
	get_node("borders").add_point(Vector2(
										get_node("../background").rect_global_position.x,
										get_node("../background").rect_global_position.y
										+ get_node("../background").rect_size.y))
	get_node("borders").add_point(get_node("../background").rect_global_position)
