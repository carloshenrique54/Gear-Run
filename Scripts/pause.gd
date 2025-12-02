extends Node

func _ready():
	$PauseMenu.visible = false

func _input(event):
	if event.is_action_pressed("esc_menu"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused == false:
		get_tree().paused = true
		$PauseMenu.visible = true
	else:
		get_tree().paused = false
		$PauseMenu.visible = false

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$PauseMenu.visible = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
