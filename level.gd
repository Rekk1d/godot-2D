extends Node2D

@onready var light = $DirectionalLight2D
@onready var lamp = $PointLight2D
enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING

func _ready(): 
	light.enabled = true
	
func _process(delta: float) -> void:
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
			
	
func change_time(energy: int, time: int) -> void:
	var dayTween = get_tree().create_tween(); 
	dayTween.tween_property(light, "energy", energy, time)
	
func change_pointLight(energy: int) -> void:
	var pointLight = get_tree().create_tween(); 
	pointLight.tween_property(lamp, "energy", energy, 20)

func _on_change_time_of_day_timeout() -> void:
	if state < 3:
		state += 1
	else:
		state = 0
