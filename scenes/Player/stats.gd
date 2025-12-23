extends CanvasLayer

signal no_stamina ()

@onready var health_bar = $HealthBar
@onready var stamina_bar = $Stamina

var stamina_cost
const attack_cost = 10
const block_cost = 0.5
const slide_cost = 20
const run_cost = 0.3
			
var max_health: int = 100
var health: 
	set(value):
		health = value
		health_bar.value = health	
var stamina = 50:
	set(value):
		stamina = value
		if stamina < 1:
			emit_signal("no_stamina")
			
func _ready() -> void:
	health = max_health
	health_bar.max_value = health
	health_bar.value = health

func _process(delta: float) -> void:
	stamina = min(stamina + 10 * delta, 100)
	stamina_bar.value = stamina
	update_stamina_color()
	
func stamina_consumption():
	stamina -= stamina_cost

func update_stamina_color() -> void:
	if stamina > 60:
		stamina_bar.tint_progress = Color(0, 1, 0)
	elif stamina > 30:
		stamina_bar.tint_progress = Color(1, 1, 0)
	else:
		stamina_bar.tint_progress = Color(1, 0, 0)
