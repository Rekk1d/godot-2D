extends CharacterBody2D

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, 'velocity', Vector2(randi_range(50, -50), -100), 0.2)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.x = 0
		
	move_and_slide()

func _on_detector_body_entered(_body: Node2D) -> void:
	print(Global.player_gold)
	if is_on_floor():
		var tween = get_tree().create_tween() 
		tween.parallel().tween_property(self, 'velocity', Vector2(0, -150), 0.3)
		tween.parallel().tween_property(self, 'modulate:a', 0, 0.5)
		await get_tree().create_timer(0.5).timeout
		queue_free()
