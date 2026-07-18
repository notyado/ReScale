extends CanvasLayer

func _ready() -> void:
	get_tree().paused = false
	visible = false

func _on_continue_button_pressed() -> void:
	# 1. Получаем имя текущей сцены (например, "level_1")
	var current_scene_name = get_tree().current_scene.name
	
	# 2. Вытаскиваем из имени цифру (заменяем текст "level_" на пустоту)
	var current_num = int(current_scene_name.replace("lvl_", ""))
	var next_num = current_num + 1
	
	# 3. Собираем путь к следующему уровню
	var next_level_path = "res://scenes/lvl_" + str(next_num) + ".tscn"
	
	# Снимаем игру с паузы перед переходом!
	get_tree().paused = false
	
	# 4. Проверяем, есть ли такой уровень. Если да — запускаем.
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		# Если уровней больше нет, возвращаем в меню выбора
		get_tree().change_scene_to_file("res://scenes/lvl_menu.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
