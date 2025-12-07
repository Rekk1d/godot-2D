extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var state = MOVE
var health = 100
var gold = 0

var run_speed = 1
var is_slide_available = true
var slide_cooldown = 1
var is_sliding = false
@onready var animationPlayer = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state()
		ATTACK:
			pass
		ATTACK2:
			pass
		ATTACK3: 
			pass
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("attack") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#animation.play('Jump')

		
	if velocity.y > 0: 
		animationPlayer.play("Fall")
		
	if health <= 0:
		health = 0
		animationPlayer.play("Death")
		await animationPlayer.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")

	move_and_slide()


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
			animationPlayer.play('Idle')
	if Input.is_action_pressed('run'):
		run_speed = 2
	else:
		run_speed = 1
			
	if direction == -1:
		animationPlayer.flip_h = true
	elif direction == 1:
		animationPlayer.flip_h = false
		
	if Input.is_action_just_pressed("block"):
		if(velocity.x == 0):
			state = BLOCK
		else:
			if is_slide_available:
				state = SLIDE
				is_slide_available = false
	
		
func block_state():
	velocity.x = 0
	animationPlayer.play("Block")
	if Input.is_action_just_released("block"):
		state = MOVE
		
func slide_state():
	animationPlayer.play("Slide")
	#await animationPlayer.animation_finished
	await get_tree().create_timer(slide_cooldown).timeout
	is_slide_available = true
	state = MOVE
