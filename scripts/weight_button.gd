extends Area2D

@export var target_gate: StaticBody2D

var normal_texture = preload("res://assets/environment/tiles/switch_blue.png")
var pressed_texture = preload("res://assets/environment/tiles/switch_blue_pressed.png")

@onready var sprite: Sprite2D = $Sprite2D

var bodies_on_button: Array = []

func _ready() -> void:
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	sprite.texture = normal_texture

func _on_body_entered(body: Node2D) -> void:
	var is_large_player = body.is_in_group("player") and body.current_data == body.large_data
	var is_zombie = body.is_in_group("enemy")
	
	if is_large_player or is_zombie:
		if not bodies_on_button.has(body):
			bodies_on_button.append(body)
		
		press_button()

func _on_body_exited(body: Node2D) -> void:
	if bodies_on_button.has(body):
		bodies_on_button.erase(body)
	
	if bodies_on_button.size() == 0:
		release_button()

func press_button():
	sprite.texture = pressed_texture
	if target_gate and target_gate.has_method("open"):
		target_gate.open()

func release_button():
	sprite.texture = normal_texture
	if target_gate and target_gate.has_method("close"):
		target_gate.close()
