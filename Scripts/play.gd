extends Button

func _on_pressed_play() -> void:
	get_tree().change_scene_to_file("res://Cenas/fase1.tscn")
