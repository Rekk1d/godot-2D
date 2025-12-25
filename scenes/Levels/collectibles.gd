extends Node2D

var coin_preload = preload("res://scenes/Collectibles/coin.tscn")

func _ready() -> void:
	Signals.connect("enemy_died", Callable(self, "_on_enemy_died"))
	
func _on_enemy_died(enemy_position) -> void:
	for i in randi_range(1, 3):
		coin_spawn(enemy_position)

func coin_spawn(spawn_position: Vector2) -> void:
	var coin = coin_preload.instantiate()
	coin.position = spawn_position
	call_deferred("add_child", coin)
