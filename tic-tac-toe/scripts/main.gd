extends Node

@onready var gameGraphics: Node = $GameGraphics
@onready var gameLogic: Node = $GameLogic
@onready var gameOverMenu: CanvasLayer = $GameOverMenu

var current_player: int
var player_marker: Node
var num_moves: int

var opponent: int = Constants.OPPONENT_HUMAN
var is_human_turn: bool = false
var is_game_over: bool = false

func new_game() -> void:	
	is_game_over = false
	is_human_turn = false
	gameLogic.new_game()
	is_human_turn = true
	
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
	is_game_over = true
	get_tree().paused = true
	gameOverMenu.show()
	
	var GameOverLabel: Node = gameOverMenu.get_node("ResultLabel")
	
	if winner == Constants.PLAYER_CIRCLE:
		GameOverLabel.text = "Circle Wins!"
	elif winner == Constants.PLAYER_CROSS:
		GameOverLabel.text = "Cross Wins!"
	else:
		GameOverLabel.text = "It's a tie!"

func take_turn(grid_pos: Vector2i) -> void:
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
			
	print(grid_data)

## Implements one turn of the game.
## Given a user click
##   - Updates the underlying grid data
##   - places a marker at the correct screen location and updates current player indicator
##   - If there's a winner or a tie, ends the game
func take_human_turn(grid_pos: Vector2i) -> void:
	print("Human turn")	
		
	take_turn(grid_pos)
	print()

func is_valid_click(event: InputEvent) -> bool:
	if is_human_turn && \
	   is_mouse_click_left(event) && \
	   gameGraphics.is_event_in_board(event):
		return true
	return false

func take_computer_turn() -> void:
	print("Computer turn:")
	
	var comp_move: Vector2i = gameLogic.get_computer_move()
	print("Comp Move: ", comp_move)
	
	take_turn(comp_move)
	print()

# user clicks
#   if is valid click
#     proccess human turn
#
#     if opponent is computer, take computer turn
#     else if opponent is human, wait for next click
func _input(event: InputEvent) -> void:
	if is_valid_click(event):
		var grid_pos: Vector2i = gameGraphics.get_grid_position(event.position)
		if gameLogic.grid_data[grid_pos.y][grid_pos.x] == Constants.EMPTY_CELL:
			is_human_turn = false
			take_human_turn(grid_pos)
			
			if opponent == Constants.OPPONENT_COMPUTER && !is_game_over:
				# TODO wait briefly (maybe this should be in computer turn function)
				take_computer_turn()
				
			is_human_turn = true

func _on_game_over_menu_restart() -> void:
	new_game()

func _on_opponent_selector_item_selected(index: int) -> void:
	opponent = index
	
	new_game()
