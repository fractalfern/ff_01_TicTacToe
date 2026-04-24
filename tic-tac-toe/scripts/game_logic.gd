extends Node

var grid_data: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

func new_game() -> void:
	grid_data = [
		[Constants.EMPTY_CELL, Constants.EMPTY_CELL, Constants.EMPTY_CELL],
		[Constants.EMPTY_CELL, Constants.EMPTY_CELL, Constants.EMPTY_CELL],
		[Constants.EMPTY_CELL, Constants.EMPTY_CELL, Constants.EMPTY_CELL]
		]

func get_winner() -> int:
	# Check rows
	for row: int in grid_data.size():
		var sum: int = grid_data[row][0] + grid_data[row][1] + grid_data[row][2]
		if sum == Constants.CIRCLE_WIN:
			return Constants.PLAYER_CIRCLE
		elif sum == Constants.CROSS_WIN:
			return Constants.PLAYER_CROSS

	# Check columns
	for col: int in grid_data.size():
		var sum: int = grid_data[0][col] + grid_data[1][col] + grid_data[2][col]
		if sum == Constants.CIRCLE_WIN:
			return Constants.PLAYER_CIRCLE
		elif sum == Constants.CROSS_WIN:
			return Constants.PLAYER_CROSS

	# Check diagonals
	var diag1: int = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
	if diag1 == Constants.CIRCLE_WIN:
		return Constants.PLAYER_CIRCLE
	elif diag1 == Constants.CROSS_WIN:
		return Constants.PLAYER_CROSS

	var diag2: int = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
	if diag2 == Constants.CIRCLE_WIN:
		return Constants.PLAYER_CIRCLE
	elif diag2 == Constants.CROSS_WIN:
		return Constants.PLAYER_CROSS

	return 0
