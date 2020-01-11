extends Node2D

export var cols : int = 5
export var rows : int = 5

var stones : Dictionary

func last_empty_row(col : int) -> int:
	assert(col >= 0 && col < cols)
	
	for row in range(rows).invert():
		if stones[row][col] == null:
			return row
	
	return -1


func move(col : int, by_who : int) -> bool:
	var row = last_empty_row(col)
	
	if row == -1:
		return false
	
	stones[row][col] = by_who
	return true


func _ready():
	for row in range(0, rows):
		if not stones.has(row):
			stones[row] = {}
		
		for col in range(0, cols):
			stones[row][col] = null