extends StaticBody2D

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.current_data == body.large_data:
			shatter()

func shatter() -> void:
	collision_shape.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.15)
	
	tween.tween_callback(queue_free)
