extends CanvasLayer

var pausable: bool = true

func _ready() -> void:
	get_tree().paused = false
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and pausable:
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

func _on_resume_button_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
