extends Node

@export var circle_scene : PackedScene
@export var cross_scene: PackedScene

const NUM_CELLS: int = 3
const EMPTY_CELL: int = 0
const PLAYER_CIRCLE: int = 1
const PLAYER_CROSS: int = -1

var board_size: int
var cell_size: int
var cell_size_offset: Vector2i

var current_player: int
var player_marker: Node
var player_panel_pos: Vector2i
var player_marker_pos: Vector2i
var num_moves: int

var grid_data: Array

func new_game() -> void:
	current_player = PLAYER_CIRCLE
	num_moves = 0
	
	grid_data = [
		[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
		[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
		[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]
		]
	
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	
	player_marker = create_marker(current_player, player_marker_pos)
	
	$GameOverMenu.hide()
	get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	board_size = $Board.texture.get_width()
		
	@warning_ignore("integer_division")
	cell_size = board_size/NUM_CELLS
	
	@warning_ignore("integer_division")
	cell_size_offset = Vector2i(cell_size/2, cell_size/2)
	
	player_panel_pos = $PlayerPanel.get_screen_position()
	player_marker_pos = player_panel_pos + cell_size_offset
	
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func is_mouse_click_left(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			return true
			
	return false
	
func is_event_in_board(event: InputEvent) -> bool:
	if event.position.x < board_size:
		return true
	
	return false
	
func get_grid_position(mouse_position: Vector2) -> Vector2i:		
	return Vector2i(mouse_position / cell_size)
		
func next_player() -> void:
	if current_player == PLAYER_CROSS:
		current_player = PLAYER_CIRCLE
	else: #player == PLAYER_CIRCLE
		current_player = PLAYER_CROSS

func get_game_marker_position(position: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var pos_calc: Vector2i = position * cell_size + cell_size_offset
	print(pos_calc)
	
	return pos_calc

func take_turn(event: InputEvent) -> void:
	var grid_pos: Vector2i = get_grid_position(event.position)
	
	if grid_data[grid_pos.y][grid_pos.x] == EMPTY_CELL:
		num_moves += 1
		
		print(grid_pos)	
		print("current player: ", current_player)
		
		grid_data[grid_pos.y][grid_pos.x] = current_player
		print(grid_data)
		
		create_marker(current_player, get_game_marker_position(grid_pos))
		next_player()
		print()
		
		player_marker.queue_free()
		player_marker = create_marker(current_player, player_marker_pos)
		
		var winner: int = get_winner()
		if winner || num_moves == 9:
			get_tree().paused = true
			$GameOverMenu.show()
			
			var GameOverLabel: Node = $GameOverMenu.get_node("ResultLabel")
			
			if winner == PLAYER_CIRCLE:
				GameOverLabel.text = "Circle Wins!"
			elif winner == PLAYER_CROSS:
				GameOverLabel.text = "Cross Wins!"
			else:
				GameOverLabel.text = "It's a tie!"
		
func _input(event: InputEvent) -> void:
	if is_mouse_click_left(event):
		if is_event_in_board(event):
			take_turn(event)

## Places a marker for the specified player at the specified position
func create_marker(player: int, position: Vector2i) -> Node:	
	var marker: Node
	
	if player == PLAYER_CIRCLE:
		marker = circle_scene.instantiate()
	else: # player == PLAYER_CROSS
		marker = cross_scene.instantiate()
		
	marker.position = position
	add_child(marker)
	
	return marker

func get_winner() -> int:
	# Check rows
	for row: int in range(3):
		var sum: int = grid_data[row][0] + grid_data[row][1] + grid_data[row][2]
		if sum == 3:
			return 1
		elif sum == -3:
			return -1

	# Check columns
	for col: int in range(3):
		var sum: int = grid_data[0][col] + grid_data[1][col] + grid_data[2][col]
		if sum == 3:
			return 1
		elif sum == -3:
			return -1

	# Check diagonals
	var diag1: int = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
	if diag1 == 3:
		return 1
	elif diag1 == -3:
		return -1

	var diag2: int = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
	if diag2 == 3:
		return 1
	elif diag2 == -3:
		return -1

	return 0

func _on_game_over_menu_restart() -> void:
	new_game()
