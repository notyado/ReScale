extends StaticBody2D

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detector: Area2D = $Detector

func _ready() -> void:
	$Detector/CollisionShape2D.shape = $Detector/CollisionShape2D.shape.duplicate()

func _physics_process(_delta: float) -> void:
	for body in detector.get_overlapping_bodies():
		if body.is_in_group("player"):
			if body.current_data == body.large_data:
				shatter()

func shatter() -> void:
	set_physics_process(false) 
	collision_shape.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
