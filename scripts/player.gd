extends CharacterBody2D

@export var small_data: PlayerSizeData
@export var large_data: PlayerSizeData

@export var speed: float = 400.0
@export var jump_velocity: float = -1200.0
@export var gravity_multiplier: float = 1.5
@export var dash_speed: int = 600
@export var dash_duration: float = 0.4
@export var dash_cooldown: float = 1.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_ghost_timer: Timer = $DashGhostTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var growth_check: ShapeCast2D = $GrowthCheck
@onready var ghost_marker: Marker2D = $ghost_marker
@onready var hp1: TextureRect = $UI/HBoxContainer/hp1
@onready var hp2: TextureRect = $UI/HBoxContainer/hp2
@onready var hp3: TextureRect = $UI/HBoxContainer/hp3

var hp: int = 3
var current_data: PlayerSizeData
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_multiplier
var coyote_time: float = 0.15
var coyote_timer: float = 0.0
var jump_buffer_time: float = 0.15
var jump_buffer_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var can_dash: bool = true
var cooldown_timer: float = 0.0
var is_attack: bool = false
var is_invulnerable: bool = false
var is_stunned: bool = false

func _ready() -> void:
	current_data = large_data
	apply_size(current_data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_size"):
		toggle_size()

func toggle_size():
	var target_data = small_data if current_data == large_data else large_data
	
	if target_data == large_data:
		growth_check.enabled = true
		growth_check.force_shapecast_update()
		if growth_check.is_colliding():
			play_denied_effect()
			growth_check.enabled = false
			return
		growth_check.enabled = false
	
	apply_size(target_data)

func apply_size(data: PlayerSizeData):
	current_data = data
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(anim, "scale", Vector2(data.scale_factor, data.scale_factor), 0.2)
	
	tween.tween_property(collision_shape.shape, "radius", data.collision_radius, 0.2)
	tween.tween_property(collision_shape.shape, "height", data.collision_height, 0.2)
	tween.tween_property(collision_shape, "position", data.position, 0.2)
	
	speed = 400.0 * data.speed_modifer
	jump_velocity = -1000 * data.jump_modifer

func play_denied_effect():
	var tween = create_tween()
	
	var shake_amount = 5.0
	tween.tween_property(anim, "position:x", shake_amount, 0.05)
	tween.tween_property(anim, "position:x", -shake_amount, 0.05)
	tween.tween_property(anim, "position:x", shake_amount, 0.05)
	tween.tween_property(anim, "position:x", 0, 0.05)
	
	var color_tween = create_tween()
	color_tween.tween_property(anim, "modulate", Color.RED, 0.1)
	color_tween.tween_property(anim, "modulate", Color.WHITE, 0.1)

func _physics_process(delta: float) -> void:
	if is_stunned:
		move_and_slide()
		return
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
		can_dash = false
	else:
		can_dash = true
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = move_toward(velocity.x, dir * speed, 50)
		anim.flip_h = (dir < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
	
	update_animation(dir)
	move_and_slide()

func start_dash():
	is_dashing = true
	dash_timer = dash_duration * current_data.dash_duration_modifier
	cooldown_timer = dash_cooldown
	
	dash_ghost_timer.start()
	
	var dir = Input.get_axis("left", "right")
	if dir == 0: dir = -1 if anim.flip_h else 1
	
	velocity.x = dir * (dash_speed * current_data.dash_speed_modifier)
	velocity.y = 0
	update_animation(dir)

func spawn_dash_ghost():
	ghost_marker.position = current_data.ghost_pos
	var ghost = Sprite2D.new()
	ghost.texture = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	ghost.global_position = ghost_marker.global_position
	ghost.scale = Vector2(current_data.scale_factor, current_data.scale_factor)
	ghost.flip_h = anim.flip_h
	get_tree().root.add_child(ghost)
	
	dash_ghost_timer.start()
	
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(ghost.queue_free)

func _on_dash_ghost_timer_timeout() -> void:
	if is_dashing:
		spawn_dash_ghost()
	else:
		dash_ghost_timer.stop()

func take_damage(pos: Vector2):
	if is_invulnerable: return
	
	hp -= 1
	is_invulnerable = true
	var knockback_dir = (global_position - pos).normalized()
	velocity = knockback_dir * 600
	anim.play("hurt")
	modulate = Color.RED
	await get_tree().create_timer(0.4).timeout
	modulate = Color.WHITE
	is_invulnerable = false
	
	if hp == 2:
		hp1.hide()
	elif hp == 1:
		hp2.hide()
	elif hp <= 0:
		hp3.hide()
		die()

func apply_stun(duration: float):
	if is_stunned: return
	
	is_stunned = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(duration).timeout
	is_stunned = false
	anim.play("idle")

func die():
	get_tree().reload_current_scene()

func update_animation(dir: float) -> void:
	if is_dashing:
		anim.play("dash")
		return
	
	if is_on_floor():
		anim.play("run" if dir != 0 else "idle")
	else:
		anim.play("jump" if velocity.y < 0 else "fall")
