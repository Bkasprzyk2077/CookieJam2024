extends CanvasLayer


func _on_startbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
