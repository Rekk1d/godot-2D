extends Node2D

signal on_death()
signal on_take_damage()

@export var max_health: int = 200

@onready var health_bar = $HealthBar
@onready var damage_text = $DamageText
@onready var animationPlayer = $AnimationPlayer

var player_damage 

var health = max_health:
	set(value):
		health = value
		health_bar.value = health
		health_bar.visible = true

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.visible = false
	damage_text.modulate = 0
	print(health)
	
	
func _on_hurt_box_area_entered(area: Area2D) -> void:
	await get_tree().create_timer(0.05).timeout
	health -= Global.player_damage
	animationPlayer.stop()
	animationPlayer.play("damage_text")
	damage_text.text = str(Global.player_damage)
	if health <= 0:
		emit_signal("on_death")
		health_bar.visible = false
	else:
		emit_signal("on_take_damage")
