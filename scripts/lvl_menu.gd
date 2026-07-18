extends Control

const LEVELS_PATH = "res://scenes/levels/lvl"

@onready var fade_overlay = $FadeOverlay
@onready var ui_root = $UiRoot
@onready var menu_title = $UiRoot/CenterContainer/VBoxContainer/MenuTitle

@export var intro_zoom_start: Vector2 = Vector2(2.0, 2.0)
@export var outro_zoom_target: Vector2 = Vector2(3.5, 3.5)

var title_initial_pos: Vector2
var time_passed: float = 0.0
var target_title_offset: Vector2 = Vector2.ZERO
var target_title_color: Color = Color.WHITE

func _ready():
	var center_screen = get_viewport().get_visible_rect().size / 2
	ui_root.pivot_offset = center_screen
	
	fade_overlay.color = Color.WHITE
	fade_overlay.modulate.a = 1.0
	ui_root.scale = intro_zoom_start
	
	var intro_tween = create_tween().set_parallel(true)
	intro_tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	intro_tween.tween_property(ui_root, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	title_initial_pos = menu_title.position
	menu_title.pivot_offset = menu_title.size / 2

	menu_title.mouse_entered.connect(func():
		target_title_offset = Vector2(0, -15)
		target_title_color = Color(0.0, 0.603, 0.91, 1.0)
	)
	menu_title.mouse_exited.connect(func():
		target_title_offset = Vector2.ZERO
		target_title_color = Color.WHITE
	)
	
	var img_normal = load("res://assets/ui/buttons/grey/button_round_depth_border.svg")
	var img_pressed = load("res://assets/ui/buttons/grey/button_round_depth_flat.svg")
	
	for i in range(1, 16):
		var button = TextureButton.new()
		button.texture_normal = img_normal
		button.texture_pressed = img_pressed
		button.pivot_offset = img_normal.get_size() / 2
		
		button.mouse_entered.connect(func():
			var tween = create_tween()
			tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
		)
		button.mouse_exited.connect(func():
			var tween = create_tween()
			tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
		)
		button.button_down.connect(func():
			var tween = create_tween()
			tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_SINE)
		)
		button.button_up.connect(func():
			var tween = create_tween()
			tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.05).set_trans(Tween.TRANS_SINE)
		)
		
		var label = Label.new()
		
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.add_child(label)
		button.pressed.connect(func(): load_level(i))
		$UiRoot/CenterContainer/VBoxContainer/GridContainer.add_child(button)

func _process(delta: float) -> void:
	time_passed += delta
	var float_y = sin(time_passed * 3.0) * 5.0
	var final_target_pos = title_initial_pos + target_title_offset + Vector2(0, float_y)
	menu_title.position = menu_title.position.lerp(final_target_pos, 6.0 * delta)
	menu_title.modulate = menu_title.modulate.lerp(target_title_color, 6.0 * delta)

func load_level(level_num: int):
	var full_path = LEVELS_PATH + str(level_num) + ".tscn"
	
	if ResourceLoader.exists(full_path):
		fade_overlay.color = Color.WHITE
		fade_overlay.modulate.a = 0.0
		
		var outro_tween = create_tween().set_parallel(true)
		outro_tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
		outro_tween.tween_property(ui_root, "scale", outro_zoom_target, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		outro_tween.chain().tween_callback(func():
			fade_overlay.color = Color.BLACK
			get_tree().call_deferred("change_scene_to_file", full_path)
		)
	else:
		print("Файл уровня не найден по пути: ", full_path)

func _on_back_button_pressed() -> void:
	fade_overlay.color = Color.WHITE
	var outro_tween = create_tween().set_parallel(true)
	outro_tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	outro_tween.chain().tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
