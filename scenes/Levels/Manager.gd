extends Node
@onready var player: CharacterBody2D = $"../Player/Player"
@onready var pause_menu: Control = $"../CanvasLayer/PauseMenu"
@onready var options: Panel = $"../CanvasLayer/PauseMenu/Options"

var is_game_on_pause: bool = false
var save_path = "user://savegame.save"

func _ready() -> void:
	options.visible = false
	
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
	is_game_on_pause = !is_game_on_pause

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu/menu.tscn")

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(Global.player_gold)
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	
func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	Global.player_gold = file.get_var(Global.player_gold)
	player.position.x = file.get_var(player.position.x)
	player.position.y = file.get_var(player.position.y)

func _on_save_pressed() -> void:
	save_game()
	is_game_on_pause = !is_game_on_pause


func _on_load_pressed() -> void:
	load_game()
	is_game_on_pause = !is_game_on_pause


func _on_settings_pressed() -> void:
	pause_menu.hide()
	options.show()


func _on_back_button_pressed() -> void:
	pause_menu.show()
	options.hide()
