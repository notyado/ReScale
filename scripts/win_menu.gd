extends CanvasLayer

func _ready() -> void:
	get_tree().paused = false
	visible = false

func _on_continue_button_pressed() -> void:
	pass # Replace with function body.

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
