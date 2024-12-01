extends CanvasLayer


func _on_startbutton_pressed() -> void:
	Transition.fade_out("res://scenes/tutorial/tutorial.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
