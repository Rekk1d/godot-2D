extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

@onready var animation = $AnimatedSprite2D
@onready var animationPlayer = $AnimationPlayer

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var state = MOVE
var health = 100
var gold = 0

var run_speed = 1
var is_slide_available = true
var slide_cooldown = 1
var is_sliding = false
var combo = false
var attack_cooldown = false

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3: 
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
			
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.y > 0: 
		play_anim('Fall')
		
	if health <= 0:
		die()

	move_and_slide()

func play_anim(name: String): 
	animationPlayer.play(name)

func move_state():
	var direction:= Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0: 
			if(run_speed == 1):
				animationPlayer.play("Walk")
			else: 
				animationPlayer.play('Run')
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0: 
			play_anim('Idle')
	if Input.is_action_pressed('run'):
		run_speed = 2
	else:
		run_speed = 1
			
	if direction == -1:
		animation.flip_h = true
	elif direction == 1:
		animation.flip_h = false
		
	if Input.is_action_just_pressed("block"):
		if(velocity.x == 0):
			state = BLOCK
		else:
			if is_slide_available:
				state = SLIDE
				is_slide_available = false
	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		state = ATTACK
	
		
func block_state():
	velocity.x = 0
	play_anim('Block')
	if Input.is_action_just_released("block"):
		state = MOVE
		
func slide_state():
	play_anim('Slide')
	await get_tree().create_timer(slide_cooldown).timeout
	is_slide_available = true
	state = MOVE

func attack_state():
	if Input.is_action_just_pressed("attack") and combo:
		state = ATTACK2
	velocity.x = 0
	play_anim('Attack')
	await animationPlayer.animation_finished
	attack_freeze()
	state = MOVE
	
func attack2_state():
	if Input.is_action_just_pressed("attack") and combo:
		state = ATTACK3
	play_anim('Attack2')
	await animationPlayer.animation_finished
	state = MOVE
	
func attack3_state():
	play_anim('Attack3')
	await animationPlayer.animation_finished
	state = MOVE
	
func combo_attack():
	combo = true
	await animation.animation_finished
	combo = false
	
func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func die():
	health = 0
	play_anim("Death")
	await animationPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file("res://menu.tscn")
	
