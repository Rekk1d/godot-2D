extends Node2D

@onready var light = $Light/DirectionalLight2D
@onready var lamp = $Light/PointLight2D
@onready var dayCount = $CanvasLayer/DayCount
@onready var animationPlayer = $CanvasLayer/AnimationPlayer
@onready var healthBar = $CanvasLayer/HealthBar
@onready var player = $Player/Player

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var currentDay: int = 1

func _ready(): 
	healthBar.max_value = player.max_health
	healthBar.value = healthBar.max_value
	light.enabled = true
	setDayCount()
	setDayAnimation()
	
func change_time(energy: float, time: int) -> void:
	var dayTween = get_tree().create_tween(); 
	dayTween.tween_property(light, "energy", energy, time)
	
func change_pointLight(energy: int) -> void:
	var pointLight = get_tree().create_tween(); 
	pointLight.tween_property(lamp, "energy", energy, 20)

func _on_change_time_of_day_timeout() -> void:
	match state:
		MORNING:
			change_time(0.2, 20)
			change_pointLight(0)
		#DAY:
			#change_time(0.4, 60)
		EVENING:
			change_time(0.75, 20)
			change_pointLight(1)
		#NIGHT:
			#change_time(0.9, 20)
			
	if state < 3:
		state += 1
	else:
		state = 0
		currentDay += 1
		setDayCount()
		setDayAnimation()
		
func setDayCount() -> void:
	dayCount.text = "Day: " + str(currentDay)
	
func setDayAnimation(): 
	animationPlayer.play("day_count_fadeIn")
	await get_tree().create_timer(3).timeout
	animationPlayer.play("day_count_fadeOut")


func _on_player_health_change(new_health: Variant) -> void:
	healthBar.value = new_health
