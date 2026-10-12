extends Node2D

const COLUMN_COUNT = 4
const TILE_WIDTH = 100
const TILE_HEIGHT = 120
const VISIBLE_TILES = 6

@onready var game_area = $GameArea
@onready var score_label = $ScoreLabel
@onready var game_over_label = $GameOverLabel
@onready var start_label = $StartLabel

var tiles = []  # Array of active tiles
var score = 0
var game_running = false
var game_over = false

func _ready():
	randomize()
	start_label.visible = true

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not game_running and not game_over:
				start_game()
			elif game_over:
				reset_game()
	
	if event is InputEventKey and event.pressed:
		if not game_running or game_over:
			return
		
		var column = -1
		match event.keycode:
			KEY_F:
				column = 0
			KEY_G:
				column = 1
			KEY_H:
				column = 2
			KEY_J:
				column = 3
		
		if column >= 0:
			_on_column_pressed(column)


func start_game():
	game_running = true
	game_over = false
	score = 0
	score_label.text = "Score: 0"
	start_label.visible = false
	game_over_label.visible = false
	
	# Clear existing tiles
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
	
	# Spawn initial tiles
	for i in range(VISIBLE_TILES):
		spawn_tile(i)
	
	# Highlight the bottom tile
	highlight_bottom_tile()

func reset_game():
	game_over = false
	start_game()

func spawn_tile(index = 0):
	var column = randi() % COLUMN_COUNT
	
	# Create tile programmatically
	var tile = ColorRect.new()
	tile.set_meta("column", column)
	tile.position = Vector2(column * TILE_WIDTH, 150 + index * TILE_HEIGHT)
	tile.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	
	# Use different colors for each column
	match column:
		0:
			tile.color = Color(1, 0, 0, 1)  # Red for F
		1:
			tile.color = Color(0, 1, 0, 1)  # Green for G
		2:
			tile.color = Color(0, 0, 1, 1)  # Blue for H
		3:
			tile.color = Color(1, 1, 0, 1)  # Yellow for J
	
	game_area.add_child(tile)
	tiles.append(tile)

func highlight_bottom_tile():
	# Reset all tiles to normal
	for tile in tiles:
		tile.z_index = 0
	
	# Sort tiles by Y position
	tiles.sort_custom(func(a, b): return a.position.y < b.position.y)
	
	# Highlight bottom tile with white border
	var bottom_tile = tiles[tiles.size() - 1]
	bottom_tile.z_index = 10

func _on_column_pressed(column):
	if not game_running or game_over:
		return
	
	# Sort tiles by Y position to ensure correct order
	tiles.sort_custom(func(a, b): return a.position.y < b.position.y)
	
	# Find the bottom-most tile (highest Y value, closest to player)
	var bottom_tile = tiles[tiles.size() - 1]
	
	# Check if the pressed column matches the bottom tile's column
	if bottom_tile.get_meta("column") == column:
		# Correct! Remove bottom tile, slide all tiles down, spawn new one at top
		bottom_tile.queue_free()
		tiles.pop_back()
		
		# Slide all remaining tiles down by one tile height
		for tile in tiles:
			tile.position.y += TILE_HEIGHT
		
		# Spawn new tile at the top (above the current top tile)
		var new_column = randi() % COLUMN_COUNT
		
		# Create tile programmatically
		var new_tile = ColorRect.new()
		new_tile.set_meta("column", new_column)
		new_tile.position = Vector2(new_column * TILE_WIDTH, tiles[0].position.y - TILE_HEIGHT)
		new_tile.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
		
		# Use different colors for each column
		match new_column:
			0:
				new_tile.color = Color(1, 0, 0, 1)  # Red for F
			1:
				new_tile.color = Color(0, 1, 0, 1)  # Green for G
			2:
				new_tile.color = Color(0, 0, 1, 1)  # Blue for H
			3:
				new_tile.color = Color(1, 1, 0, 1)  # Yellow for J
		
		game_area.add_child(new_tile)
		tiles.push_front(new_tile)
		
		# Highlight the new bottom tile
		highlight_bottom_tile()
		
		score += 1
		score_label.text = "Score: " + str(score)
	else:
		# Wrong column - game over
		end_game()

func end_game():
	game_over = true
	game_running = false
	game_over_label.visible = true
	
	# Clear all tiles
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
