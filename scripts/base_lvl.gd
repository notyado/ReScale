extends Node2D

func _on_lose_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
