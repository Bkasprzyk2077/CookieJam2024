extends Node3D

class_name Trap

func kill():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", 6, .5)
	await tween.finished
	print("TeST")
	queue_free()
