extends Node

@export var circle_scene : PackedScene
@export var cross_scene: PackedScene

const NUM_CELLS: int = 3
const EMPTY_CELL: int = 0
const PLAYER_CIRCLE: int = 1
const PLAYER_CROSS: int = -1

var current_player: int
var board_size: int
var cell_size: int
var grid_data: Array

func new_game() -> void:
	current_player = PLAYER_CIRCLE
	
	grid_data = [
		[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
		[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL],
		[EMPTY_CELL, EMPTY_CELL, EMPTY_CELL]
		]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	board_size = $Board.texture.get_width()
	print("board_size: ", board_size)
	
	@warning_ignore("integer_division")
	cell_size = board_size/NUM_CELLS
	
	print("cell_size: ", cell_size)	
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
		
func marker_position(position: Vector2i) -> Vector2i:
	return position * cell_size + Vector2i(cell_size/2, cell_size/2)

func take_turn(event: InputEvent) -> void:
	var grid_pos = get_grid_position(event.position)
	
	if grid_data[grid_pos.y][grid_pos.x] == EMPTY_CELL:
		print(grid_pos)	
		print("current player: ", current_player)
		
		grid_data[grid_pos.y][grid_pos.x] = current_player
		print(grid_data)
		
		create_marker(current_player, marker_position(grid_pos))
		next_player()
		print()
		
func _input(event: InputEvent) -> void:
	if is_mouse_click_left(event):
		if is_event_in_board(event):
			take_turn(event)

func create_marker(player: int, position: Vector2i) -> void:
	if player == PLAYER_CIRCLE:
		var circle = circle_scene.instantiate()
		circle.position = position
		
		add_child(circle)
	elif player == PLAYER_CROSS:
		var cross = cross_scene.instantiate()
		cross.position = position
		
		add_child(cross)
