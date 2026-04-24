extends Node

var current_player: int
var player_marker: Node
var num_moves: int

func new_game() -> void:
	$GameLogic.new_game()
	
	current_player = Constants.PLAYER_CIRCLE
	num_moves = 0
	
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	
	player_marker = $GameGraphics.create_marker(current_player, $GameGraphics.player_marker_pos)
	add_child(player_marker)
	
	$GameOverMenu.hide()
	get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

func is_mouse_click_left(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			return true
			
	return false

func next_player() -> void:
	if current_player == Constants.PLAYER_CROSS:
		current_player = Constants.PLAYER_CIRCLE
	else: #player == Constants.PLAYER_CIRCLE
		current_player = Constants.PLAYER_CROSS

func take_turn(event: InputEvent) -> void:
	var grid_pos: Vector2i = $GameGraphics.get_grid_position(event.position)
	
	var grid_data: Array = $GameLogic.grid_data
	
	if grid_data[grid_pos.y][grid_pos.x] == Constants.EMPTY_CELL:
		num_moves += 1
		
		print(grid_pos)	
		print("current player: ", current_player)
		
		grid_data[grid_pos.y][grid_pos.x] = current_player
		print(grid_data)
		
		var marker: Node = $GameGraphics.create_marker(current_player, $GameGraphics.get_game_marker_position(grid_pos))
		add_child(marker)
		
		next_player()
		print()
		
		player_marker.queue_free()
		player_marker = $GameGraphics.create_marker(current_player, $GameGraphics.player_marker_pos)
		add_child(player_marker)
		
		var winner: int = $GameLogic.get_winner()
		if winner || num_moves == 9:
			get_tree().paused = true
			$GameOverMenu.show()
			
			var GameOverLabel: Node = $GameOverMenu.get_node("ResultLabel")
			
			if winner == Constants.PLAYER_CIRCLE:
				GameOverLabel.text = "Circle Wins!"
			elif winner == Constants.PLAYER_CROSS:
				GameOverLabel.text = "Cross Wins!"
			else:
				GameOverLabel.text = "It's a tie!"

func _input(event: InputEvent) -> void:
	if is_mouse_click_left(event):
		if $GameGraphics.is_event_in_board(event):
			take_turn(event)

func _on_game_over_menu_restart() -> void:
	new_game()
