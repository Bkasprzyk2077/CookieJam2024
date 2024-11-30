extends CanvasLayer


func _on_menu_pressed():
	Transition.fade_out("res://scenes/ui/mainmenu.tscn")


func _on_exit_pressed():
	get_tree().quit()
