extends CanvasLayer

func _ready() -> void:
	get_tree().paused = false
	visible = false

func _on_continue_button_pressed() -> void:
	var current_scene_name = get_tree().current_scene.name
	print(current_scene_name)
	var current_num = int(current_scene_name.replace("lvl_", ""))
	var next_num = current_num + 1
	print(next_num)
	
	var next_level_path = "res://scenes/levels/lvl" + str(next_num) + ".tscn"
	
	get_tree().paused = false
	
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		get_tree().change_scene_to_file("res://scenes/lvl_menu.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
