extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed: int = 250
var jump_velocity: int = -600
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var dir = Input.get_axis("left","right")
	if dir != 0:
		velocity.x = dir * speed
		anim.flip_h = (dir < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	update_animation(dir)
	
	move_and_slide()

func update_animation(dir: float) -> void:
	if is_on_floor():
		if dir != 0:
			anim.play("run")
		else:
			anim.play("idle")
	else:
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
