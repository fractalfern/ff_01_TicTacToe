extends Node

@onready var gameGraphics: Node = $GameGraphics
@onready var gameLogic: Node = $GameLogic
@onready var gameOverMenu: CanvasLayer = $GameOverMenu

var current_player: int
var player_marker: Node
var num_moves: int

func new_game() -> void:
	gameLogic.new_game()
	
	current_player = Constants.PLAYER_CIRCLE
	num_moves = 0
	
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	
	player_marker = gameGraphics.create_marker(current_player, gameGraphics.player_marker_pos)
	add_child(player_marker)
	
	$GameOverMenu.hide()
	get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

# Convenience. Returns true if and only if the event is a left mouse click
func is_mouse_click_left(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			return true
			
	return false

# Advances to the next player
func next_player() -> void:
	if current_player == Constants.PLAYER_CROSS:
		current_player = Constants.PLAYER_CIRCLE
	else: #player == Constants.PLAYER_CIRCLE
		current_player = Constants.PLAYER_CROSS

func end_game(winner: int) -> void:
	get_tree().paused = true
	gameOverMenu.show()
	
	var GameOverLabel: Node = gameOverMenu.get_node("ResultLabel")
	
	if winner == Constants.PLAYER_CIRCLE:
		GameOverLabel.text = "Circle Wins!"
	elif winner == Constants.PLAYER_CROSS:
		GameOverLabel.text = "Cross Wins!"
	else:
		GameOverLabel.text = "It's a tie!"

## Implements one turn of the game. This is more complex than I would like
## Given a user click
##   - Updates the underlying grid data
##   - places a marker at the correct screen location and updates current player indicator
##   - If there's a winner or a tie, ends the game
func take_turn(event: InputEvent) -> void:
	var grid_pos: Vector2i = gameGraphics.get_grid_position(event.position)
	
	var grid_data: Array = gameLogic.grid_data
	
	if grid_data[grid_pos.y][grid_pos.x] == Constants.EMPTY_CELL:
		num_moves += 1
		
		grid_data[grid_pos.y][grid_pos.x] = current_player
		
		var marker: Node = gameGraphics.create_marker(current_player, gameGraphics.get_game_marker_position(grid_pos))
		add_child(marker)
		
		next_player()
		
		player_marker.queue_free()
		player_marker = gameGraphics.create_marker(current_player, gameGraphics.player_marker_pos)
		add_child(player_marker)
		
		var winner: int = gameLogic.get_winner()
		if winner || num_moves == 9:
			end_game(winner)

func _input(event: InputEvent) -> void:
	if is_mouse_click_left(event):
		if gameGraphics.is_event_in_board(event):
			take_turn(event)

## TODO: Should be able to drop this now, and just put the signal on new_game()
func _on_game_over_menu_restart() -> void:
	new_game()
