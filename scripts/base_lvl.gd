extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var lvl_lbl: Label = $lbl/Label

var current_num_level: int

func _ready() -> void:
	setup_fade_in()
	var current_scene_name = get_tree().current_scene.name
	var current_num = current_scene_name.replace("lvl_", "")
	lvl_lbl.text += current_num
	anim.play("start")

func _on_lose_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()

func setup_fade_in() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 99
	add_child(canvas_layer)
	
	var fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(canvas_layer.queue_free)
