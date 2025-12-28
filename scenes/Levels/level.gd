extends Node2D

@onready var light = $Light/DirectionalLight2D
@onready var lamp = $Light/PointLight2D
@onready var dayCount = $CanvasLayer/DayCount
@onready var animationPlayer = $Light/LightAnimation
@onready var player = $Player/Player
@onready var fireflies: GPUParticles2D = $Fireflies

var mushroom_preload = preload("res://scenes/Mobs/mushroom.tscn")

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var currentDay: int = 1
const TIME_PER_STATE = 10

func _ready(): 
	light.enabled = true
	Global.player_gold = 0
	setDayCount()
	setDayAnimation()
	
func change_time(energy: float, time: int) -> void:
	var dayTween = get_tree().create_tween(); 
	dayTween.tween_property(light, "energy", energy, time)
	
func change_pointLight(energy: int) -> void:
	var pointLight = get_tree().create_tween(); 
	pointLight.tween_property(lamp, "energy", energy, 20)

func next_state():
	match state:
		MORNING:
			state = DAY
			setDayCount()
			setDayAnimation()
		DAY:
			state = EVENING
		EVENING:
			state = NIGHT
		NIGHT:
			state = MORNING
			currentDay += 1
	Signals.emit_signal("day_time", state)
			
func _on_change_time_of_day_timeout() -> void:
	match state:
		MORNING:
			switch_fireflies(false)
			change_time(0.2, TIME_PER_STATE)
			change_pointLight(0)
		DAY:
			change_time(0.4, TIME_PER_STATE)
		EVENING:
			switch_fireflies(true)
			change_time(0.75, TIME_PER_STATE)
			change_pointLight(1)
		NIGHT:
			change_time(0.9, TIME_PER_STATE)
			
	next_state()
		
func setDayCount() -> void:
	dayCount.text = "Day: " + str(currentDay)
	
func setDayAnimation(): 
	animationPlayer.play("day_count_fadeIn")
	await get_tree().create_timer(3).timeout
	animationPlayer.play("day_count_fadeOut")

func _on_mobs_spawner_timeout() -> void:
	mushrooms_spawn()

func mushrooms_spawn() -> void:
	var mushroom_instance = mushroom_preload.instantiate()
	mushroom_instance.position = Vector2(randi_range(-500, -200) ,488)
	$Mobs.add_child(mushroom_instance)
	
func switch_fireflies(active: bool) -> void:
	fireflies.emitting = active
