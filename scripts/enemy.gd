extends CharacterBody2D

@export var speed: float = 400.0
@export var gravity_multiplier: float = 1.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_zone: Area2D = $AttackPivot/AttackZone

var player: CharacterBody2D = null
var hp: int = 3
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_multiplier
var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	if is_attacking:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0 
	
	if player:
		var dir = (player.global_position - global_position).normalized()
		dir.y = 0 
		
		if player.current_data.scale_factor > 1.2:
			velocity.x = -dir.x * speed
			attack_pivot.scale.x = -1 if velocity.x < 0 else 1
			anim.flip_h = velocity.x < 0
		else:
			velocity.x = dir.x * speed * 1.45
			attack_pivot.scale.x = -1 if velocity.x < 0 else 1
			anim.flip_h = velocity.x < 0
			
		anim.play("run")
		SoundManager.play_enemy_step()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		anim.play("idle")
	
	move_and_slide()

func perform_attack(target: Node2D):
	is_attacking = true
	velocity.x = 0
	anim.play("attack")
	
	await anim.animation_finished
	
	target.take_damage(global_position, 600)
	await get_tree().create_timer(0.4).timeout
	is_attacking = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_attacking:
		body.apply_stun(1.0)
		perform_attack(body)
