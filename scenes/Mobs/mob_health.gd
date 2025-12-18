extends Node2D

signal on_death()
signal on_take_damage()

@export var max_health: int = 200

@onready var health_bar = $HealthBar
@onready var damage_text = $DamageText
@onready var animationPlayer = $AnimationPlayer

var health = max_health:
	set(value):
		health = value
		health_bar.value = health
		health_bar.visible = true

func _ready() -> void:
	Signals.connect("player_attack", Callable(self, "_on_take_damage"))
	health = max_health
	health_bar.max_value = max_health
	health_bar.visible = false
	damage_text.modulate = 0
	print(health)
	
func _on_take_damage(player_damage: int) -> void:
	health -= player_damage
	print(health)
	animationPlayer.stop()
	animationPlayer.play("damage_text")
	damage_text.text = str(player_damage)
	if health <= 0:
		emit_signal("on_death")
		health_bar.visible = false
	else:
		emit_signal("on_take_damage")
	
