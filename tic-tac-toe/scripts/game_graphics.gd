extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var board_size: int
var cell_size: int
var cell_size_offset: Vector2i

var player_panel_pos: Vector2i
var player_marker_pos: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	board_size = $Board.texture.get_width()
	
	@warning_ignore("integer_division")
	cell_size = board_size/Constants.NUM_CELLS
	
	@warning_ignore("integer_division")
	cell_size_offset = Vector2i(cell_size/2, cell_size/2)
	
	player_panel_pos = $PlayerPanel.get_screen_position()
	player_marker_pos = player_panel_pos + cell_size_offset

## Places a marker for the specified player at the specified position
func create_marker(player: int, position: Vector2i) -> Node:
	var marker: Node
	
	if player == Constants.PLAYER_CIRCLE:
		marker = circle_scene.instantiate()
	else: # player == Constants.PLAYER_CROSS
		marker = cross_scene.instantiate()
		
	marker.position = position
	
	return marker

func get_grid_position(mouse_position: Vector2) -> Vector2i:
	return Vector2i(mouse_position / cell_size)

func is_event_in_board(event: InputEvent) -> bool:
	if event.position.x < board_size:
		return true
	
	return false

func get_game_marker_position(position: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	var pos_calc: Vector2i = position * cell_size + cell_size_offset
	print(pos_calc)
	
	return pos_calc
