extends CanvasLayer

func _ready():
	await get_tree().create_timer(11).timeout
	get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
	
#func _on_video_stream_player_finished():
	#print("TEST")
	##get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
	##Transition.fade_out("res://scenes/ui/mainmenu.tscn")
