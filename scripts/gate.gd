extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func open() -> void:
	collision_shape.set_deferred("disabled", true)
	
	for child in get_children():
		if child is Sprite2D:
			var tween = create_tween()
			tween.tween_property(child, "modulate:a", 0.0, 0.2)

func close() -> void:
	collision_shape.set_deferred("disabled", false)
	
	for child in get_children():
		if child is Sprite2D:
			var tween = create_tween()
			tween.tween_property(child, "modulate:a", 1.0, 0.2)
