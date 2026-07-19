extends CanvasLayer

@onready var play_button = $Background/MarginContainer/VBoxContainer/PlayButton
@onready var title_label = $Background/GameLabel
@onready var fade_overlay = $FadeOverlay
@onready var ui_root = $Background
@onready var far_clouds = $Parallax2D_Far
@onready var near_clouds = $Parallax2D_Near

@export var magnet_strength: float = 0.35
@export var button_smoothness: float = 8.0
@export var title_smoothness: float = 3.0

@export var intro_zoom_start: Vector2 = Vector2(1.5, 1.5)
@export var outro_zoom_target: Vector2 = Vector2(3.0, 3.0)

var far_normal_speed: Vector2
var near_normal_speed: Vector2
var is_hovering_button: bool = false
var button_initial_pos: Vector2
var target_title_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	button_initial_pos = play_button.global_position
	
	play_button.mouse_entered.connect(_on_button_entered)
	play_button.mouse_exited.connect(_on_button_exited)
	title_label.mouse_entered.connect(_on_title_entered)
	title_label.mouse_exited.connect(_on_title_exited)
	
	title_label.pivot_offset = title_label.size / 2
	
	var center_screen = get_viewport().get_visible_rect().size / 2
	ui_root.pivot_offset = center_screen
	
	far_normal_speed = far_clouds.autoscroll
	near_normal_speed = near_clouds.autoscroll
	
	fade_overlay.modulate.a = 1.0
	ui_root.scale = intro_zoom_start
	
	far_clouds.scale = intro_zoom_start
	near_clouds.scale = intro_zoom_start
	
	far_clouds.autoscroll = far_normal_speed * 12.0
	near_clouds.autoscroll = near_normal_speed * 12.0
	
	var intro_tween = create_tween().set_parallel(true)
	intro_tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE)
	intro_tween.tween_property(ui_root, "scale", Vector2.ONE, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	intro_tween.tween_property(far_clouds, "scale", Vector2.ONE, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(near_clouds, "scale", Vector2.ONE, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	intro_tween.tween_property(far_clouds, "autoscroll", far_normal_speed, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(near_clouds, "autoscroll", near_normal_speed, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	
	if is_hovering_button:
		var button_center = play_button.global_position + (play_button.size / 2)
		var target_offset = (mouse_pos - button_center) * magnet_strength
		play_button.global_position = play_button.global_position.lerp(button_initial_pos + target_offset, button_smoothness * delta)
		play_button.scale = play_button.scale.lerp(Vector2(1.15, 1.15), button_smoothness * delta)
	else:
		play_button.global_position = play_button.global_position.lerp(button_initial_pos, button_smoothness * delta)
		play_button.scale = play_button.scale.lerp(Vector2(1.0, 1.0), button_smoothness * delta)
	
	title_label.scale = title_label.scale.lerp(target_title_scale, title_smoothness * delta)

func _on_title_entered() -> void:
	if randf() > 0.5: target_title_scale = Vector2(1.2, 1.2)
	else: target_title_scale = Vector2(0.7, 0.7)
	var tween = create_tween()
	tween.tween_property(title_label, "modulate", Color(0.0, 0.603, 0.91, 1.0), 0.2)

func _on_title_exited() -> void:
	target_title_scale = Vector2.ONE
	var tween = create_tween()
	tween.tween_property(title_label, "modulate", Color(1, 1, 1, 1), 0.2)

func _on_button_entered() -> void: is_hovering_button = true
func _on_button_exited() -> void: is_hovering_button = false

func _on_play_button_pressed() -> void:
	play_button.disabled = true 
	fade_overlay.color = Color.WHITE
	
	var center_screen = get_viewport().get_visible_rect().size / 2
	var outro_offset = center_screen * (Vector2.ONE - outro_zoom_target)
	
	var outro_tween = create_tween().set_parallel(true)
	outro_tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	outro_tween.tween_property(ui_root, "scale", outro_zoom_target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	outro_tween.tween_property(far_clouds, "autoscroll", far_normal_speed * 15.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	outro_tween.tween_property(near_clouds, "autoscroll", near_normal_speed * 15.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	outro_tween.tween_property(far_clouds, "scale", outro_zoom_target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	outro_tween.tween_property(far_clouds, "position", outro_offset, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	outro_tween.tween_property(near_clouds, "scale", outro_zoom_target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	outro_tween.tween_property(near_clouds, "position", outro_offset, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	outro_tween.chain().tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/lvl_menu.tscn")
	)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
