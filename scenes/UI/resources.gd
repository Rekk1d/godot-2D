extends CanvasLayer

@onready var gold_text = $Control/PanelContainer/HBoxContainer/GoldText

func _process(_delta) -> void:
	gold_text.text = str(Global.player_gold)
