extends Area2D

@export var close: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D

func _process(_delta: float) -> void:
	if close:
		anim.play("close")
	else:
		anim.play("open")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not close:
		player = body
		win()
	elif body.is_in_group("player") and body.key == true:
		player = body
		close = false
		await get_tree().create_timer(0.3).timeout
		win()
	else: return

func win():
	player.win()
