extends Node3D

class_name Torch

func fire():
	$Area3D.queue_free()
	$PlaerLight.visible = true
	$Sprite3D.texture = load("res://assets/torch/grzes-pochodnia.png")
