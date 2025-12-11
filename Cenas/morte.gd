extends Node

func _ready():
	$MorteMenu.visible = false

func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_sair_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
