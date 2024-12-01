extends Node3D


class_name doors

func open():
	print("DOOR OPENED")
	$Area3D2.queue_free()
	$Sprite3D.texture = load("res://assets/doors2.png")
