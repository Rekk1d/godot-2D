extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var animationTween = get_tree().create_tween()
		var opacityTween = get_tree().create_tween()
		animationTween.tween_property(self, 'position', position - Vector2(0, 25), 0.3)
		opacityTween.tween_property(self, "modulate:a", 0, 0.3)
		animationTween.tween_callback(queue_free)
		body.gold += 1
