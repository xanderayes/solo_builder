extends Node2D

@export var tile_scene: PackedScene

const COLUMN_COUNT = 4
const TILE_WIDTH = 100
const TILE_HEIGHT = 150
const INITIAL_SPEED = 200.0
const SPEED_INCREMENT = 10.0

@onready var game_area = $GameArea
@onready var score_label = $ScoreLabel
@onready var game_over_label = $GameOverLabel
@onready var start_label = $StartLabel

var tiles = []  # Array of active tiles
var score = 0
var speed = INITIAL_SPEED
var game_running = false
var game_over = false
var spawn_timer = 0.0
var spawn_interval = 0.6

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

func _process(delta):
	if not game_running or game_over:
		return
	
	# Move tiles down
	for tile in tiles:
		tile.position.y += speed * delta
	
	# Remove tiles that have gone off screen
	tiles = tiles.filter(func(t): return t.position.y < 700)
	
	# Check for missed tiles (tiles that passed the bottom without being clicked)
	for tile in tiles:
		if tile.position.y >= 700 - TILE_HEIGHT and not tile.is_clicked:
			end_game()
			return
	
	# Spawn new tiles
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_tile()
		spawn_timer = 0.0

func start_game():
	game_running = true
	game_over = false
	score = 0
	speed = INITIAL_SPEED
	spawn_interval = 0.6
	score_label.text = "Score: 0"
	start_label.visible = false
	game_over_label.visible = false
	
	# Clear existing tiles
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
	
	# Spawn initial tiles
	for i in range(4):
		spawn_tile()
		await get_tree().process_frame

func reset_game():
	game_over = false
	start_game()

func spawn_tile():
	var column = randi() % COLUMN_COUNT
	var tile = tile_scene.instantiate()
	
	tile.column = column
	tile.position = Vector2(column * TILE_WIDTH, -TILE_HEIGHT)
	tile.size = Vector2(TILE_WIDTH, TILE_HEIGHT)
	
	game_area.add_child(tile)
	tiles.append(tile)

func _on_column_pressed(column):
	if not game_running or game_over:
		return
	
	# Find the bottom-most tile in this column that hasn't been clicked
	var target_tile = null
	var lowest_y = -INF
	
	for tile in tiles:
		if tile.column == column and not tile.is_clicked:
			if tile.position.y > lowest_y:
				lowest_y = tile.position.y
				target_tile = tile
	
	if target_tile:
		_on_tile_pressed(target_tile)
	else:
		# Missed - no tile in this column or already clicked
		end_game()

func _on_tile_pressed(tile):
	if not game_running or game_over:
		return
	
	if tile.is_clicked:
		return
	
	tile.is_clicked = true
	tile.color = Color(0.5, 0.5, 0.5, 1)  # Gray out clicked tile
	
	score += 1
	score_label.text = "Score: " + str(score)
	
	# Increase speed every 10 points
	if score % 10 == 0:
		speed += SPEED_INCREMENT
		# Decrease spawn interval slightly
		spawn_interval = max(0.3, spawn_interval - 0.02)
	
	# Remove tile after a short delay
	var tween = tile.create_tween()
	tween.tween_property(tile, "modulate:a", 0.0, 0.1)
	tween.finished.connect(func(): 
		if tile in tiles:
			tiles.erase(tile)
		tile.queue_free()
	)

func end_game():
	game_over = true
	game_running = false
	game_over_label.visible = true
	
	# Clear all tiles
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
