extends ColorRect

var column: int = 0

func set_key_label(text):
	if has_node("KeyLabel"):
		get_node("KeyLabel").text = text
	else:
		print("KeyLabel not found!")
