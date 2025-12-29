extends Node2D

@onready var buttons: AudioStreamPlayer = $Buttons

func _on_quit_button_pressed() -> void:
	buttons.play()
	await buttons.finished
	get_tree().quit()


func _on_play_button_pressed() -> void:
	buttons.play()
	await buttons.finished
	get_tree().change_scene_to_file("res://scenes/Levels/level.tscn")
