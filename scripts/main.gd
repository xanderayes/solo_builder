extends Node2D

@export var tile_scene: PackedScene

const COLUMN_COUNT = 4
const TILE_WIDTH = 100
const TILE_HEIGHT = 150
const VISIBLE_TILES = 10

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

func reset_game():
	game_over = false
	start_game()

func spawn_tile(index = 0):
	var column = randi() % COLUMN_COUNT
	var tile = tile_scene.instantiate()
	
	tile.column = column
	tile.position = Vector2(column * TILE_WIDTH, 100 + index * TILE_HEIGHT)
	tile.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	
	game_area.add_child(tile)
	tiles.append(tile)

func _on_column_pressed(column):
	if not game_running or game_over:
		return
	
	# Find the top-most tile (lowest Y value, furthest from player)
	var top_tile = null
	var lowest_y = INF
	
	for tile in tiles:
		if tile.position.y < lowest_y:
			lowest_y = tile.position.y
			top_tile = tile
	
	print("Pressed column: ", column, ", Top tile column: ", top_tile.column, ", Top tile position: ", top_tile.position)
	
	# Check if the pressed column matches the top tile's column
	if top_tile.column == column:
		# Correct! Remove top tile, slide all tiles down, spawn new one at top
		top_tile.queue_free()
		tiles.erase(top_tile)
		
		# Slide all remaining tiles down by one tile height
		for tile in tiles:
			tile.position.y += TILE_HEIGHT
		
		# Spawn new tile at the top
		spawn_tile(0)
		
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
