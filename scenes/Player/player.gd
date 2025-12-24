extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var attackDirection = $AttackDirection
@onready var stats = $stats

enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	HIT,
	DEATH
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var state = MOVE
var gold = 0

var run_speed = 1
var slide_cooldown = 1
var stamina_recovery = false
var stamina_recovery_time = 2

var combo = false
var attack_cooldown = false
var basic_damage = 10
var damage_muliplier = 1

func _ready() -> void:
	Signals.connect("enemy_attack", Callable (self, "_on_take_damage"))
	
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
		HIT:
			hit_state()
		DEATH: 
			death_state()
			
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.y > 0: 
		play_anim('Fall')

	move_and_slide()
	Global.player_pos = self.position
	Global.player_damage = basic_damage * damage_muliplier

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
	if Input.is_action_pressed('run') and !stamina_recovery:
		run_speed = 1.5
		stats.stamina -= stats.run_cost
	else:
		run_speed = 1
			
	if direction == -1:
		animation.flip_h = true
		attackDirection.rotation_degrees = 180
	elif direction == 1:
		animation.flip_h = false
		attackDirection.rotation_degrees = 0
		
	if Input.is_action_just_pressed("block") and !stamina_recovery:
		if velocity.x == 0 and stats.stamina > 1:
			state = BLOCK
		else:
			stats.stamina_cost = stats.slide_cost
			if stats.stamina > stats.stamina_cost:
				state = SLIDE
				
	if Input.is_action_just_pressed("attack") and !stamina_recovery:
		stats.stamina_cost = stats.attack_cost
		if not attack_cooldown and stats.stamina > stats.stamina_cost:
			state = ATTACK
	
		
func block_state():
	stats.stamina -= stats.block_cost
	velocity.x = 0
	play_anim('Block')
	if Input.is_action_just_released("block") or stamina_recovery:
		state = MOVE
		
func slide_state():
	play_anim('Slide')
	await animationPlayer.animation_finished
	state = MOVE

func attack_state():
	stats.stamina_cost = stats.attack_cost
	damage_muliplier = 1
	if Input.is_action_just_pressed("attack") and combo:
		state = ATTACK2
	velocity.x = 0
	play_anim('Attack')
	await animationPlayer.animation_finished
	attack_freeze()
	state = MOVE
	
func attack2_state():
	damage_muliplier = 1.5
	if Input.is_action_just_pressed("attack") and combo and stats.stamina > stats.stamina_cost:
		state = ATTACK3
	play_anim('Attack2')
	await animationPlayer.animation_finished
	state = MOVE
	
func attack3_state():
	damage_muliplier = 2
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
	
func hit_state() -> void:
	velocity.x = 0
	play_anim("Hit")
	await animationPlayer.animation_finished
	state = MOVE
	
func death_state() -> void:
	velocity.x = 0
	play_anim("Death")
	await animationPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://scenes/Menu/menu.tscn").call_deferred()
	
func _on_take_damage(enemy_damage: int) -> void:
	if state == BLOCK:
		enemy_damage /= 2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = HIT
	stats.health -= enemy_damage
	if stats.health  <= 0:
		stats.health  = 0
		state = DEATH
	
	#emit_signal("health_change", Global.player_health)


func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("player_attack", Global.player_damage)


func _on_stats_no_stamina() -> void:
	stamina_recovery = true
	await get_tree().create_timer(stamina_recovery_time).timeout
	stamina_recovery = false
