extends Node

@onready var pause_menu = $"../CanvasLayer/PauseMenu"

var is_game_on_pause: bool = false

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		is_game_on_pause = !is_game_on_pause
	
	if is_game_on_pause:
		get_tree().paused = true
		pause_menu.show()
	else: 
		get_tree().paused = false
		pause_menu.hide()

func _on_resume_pressed() -> void:
	is_game_on_pause = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu/menu.tscn")
