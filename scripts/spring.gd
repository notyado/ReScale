extends StaticBody2D

@export var launch_force: float = 1400.0 

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var tex_idle = preload("res://assets/environment/tiles/spring_out.png")
var tex_squished = preload("res://assets/environment/tiles/spring.png")

var is_compressed: bool = false
var player_ref: CharacterBody2D = null

func _physics_process(_delta: float) -> void:
	if player_ref != null:
		if player_ref.current_data == player_ref.large_data and not is_compressed:
			compress_spring()
		elif is_compressed and player_ref.current_data == player_ref.small_data:
			launch_player()

func compress_spring():
	is_compressed = true
	if sprite:
		sprite.texture = tex_squished
	if collision_shape:
		collision_shape.position.y = 20.0 

func release_spring():
	is_compressed = false
	if sprite:
		sprite.texture = tex_idle
	if collision_shape:
		collision_shape.position.y = 0.0

func launch_player():
	var p = player_ref
	player_ref = null
	
	release_spring()
	
	if sfx_player:
		sfx_player.play()
	
	if p:
		p.velocity.y = -launch_force
		p.position.y -= 15

func _on_activation_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body

func _on_activation_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		release_spring()
