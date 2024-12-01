extends Node3D

class_name Key

func _ready():
	await get_tree().create_timer(1).timeout
	$Area3D/CollisionShape3D.disabled = false
