extends CharacterBody2D

@onready var animationPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var attackDirection = $AttackDirection

enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}

var player
var direction
var _state: int = IDLE
var damage: int = 20
var max_health = 100
var health

var state: int:
	set(value):
		if _state == value:
			return
		_state = value
		match _state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			CHASE:
				chase_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()
	get:
		return _state
	
func _ready() -> void:
	health = max_health
		
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state == CHASE:
		chase_state()
	move_and_slide()
	player = Global.player_pos
		

func _on_attack_range_body_entered(body: Node2D) -> void:
	state = ATTACK
	
		
func idle_state() -> void:
	animationPlayer.play("Idle")
	state = CHASE
	
func attack_state() -> void:
	animationPlayer.play("Attack")
	await animationPlayer.animation_finished
	state = RECOVER
	
func chase_state() -> void:
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		attackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		attackDirection.rotation_degrees = 0

func damage_state() -> void:
	animationPlayer.play("TakeHit")
	await animationPlayer.animation_finished
	state = IDLE
	
func death_state() -> void:
	Signals.emit_signal("enemy_died", position)
	animationPlayer.play("Death")
	await animationPlayer.animation_finished
	queue_free()

func recover_state() -> void:
	animationPlayer.play("Recover")
	await animationPlayer.animation_finished
	state = IDLE
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("enemy_attack", damage)


func _on_mob_health_on_death() -> void:
	state = DEATH


func _on_mob_health_on_take_damage() -> void:
	state = IDLE
	state = DAMAGE
