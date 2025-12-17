extends CharacterBody2D

@onready var animationPlayer = $AnimationPlayer
@onready var collisionShape = $AttackDirection/AttackRange/CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var attackDirection = $AttackDirection

enum {
	IDLE,
	ATTACK,
	CHASE
}

var player
var direction
var _state: int = IDLE
var damage: int = 20

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
				chase_state
	get:
		return _state
	
func _ready() -> void:
	if Signals.has_signal("player_position_update"):
		Signals.connect("player_position_update", Callable (self, "_on_player_position_update"))
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state == CHASE:
		chase_state()
	move_and_slide()
		

func _on_attack_range_body_entered(body: Node2D) -> void:
	state = ATTACK
	
func _on_player_position_update(player_pos) -> void:
		player = player_pos
		
func idle_state() -> void:
	animationPlayer.play("Idle")
	await get_tree().create_timer(1).timeout
	collisionShape.disabled = false
	state = CHASE
	
func attack_state() -> void:
	animationPlayer.play("Attack")
	await animationPlayer.animation_finished
	collisionShape.disabled = true
	state = IDLE
	
func chase_state() -> void:
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		attackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		attackDirection.rotation_degrees = 0


func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("enemy_attack", damage)
