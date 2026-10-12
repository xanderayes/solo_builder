extends ColorRect

signal tile_pressed

var column: int = 0
var is_clicked: bool = false

func _ready():
	gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_clicked:
			is_clicked = true
			tile_pressed.emit()
