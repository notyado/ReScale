extends Area2D

var player: CharacterBody2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func _process(_delta: float) -> void:
	if player:
		player.take_damage(global_position, 800)
		await get_tree().create_timer(0.5).timeout
