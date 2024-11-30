extends Node3D

@onready var front_ray_cast_3d = $FrontRayCast3D
@onready var back_ray_cast_3d = $BackRayCast3D

const MOVE_DISTANCE = 5
const MOVE_TIME = .2
var can_move:bool = true

signal heal

func _process(delta):
	if can_move:
		if Input.is_action_just_pressed("move_forward"):
			if front_ray_cast_3d.is_colliding():
				return
			move(1)
		elif Input.is_action_just_pressed("move_backward"):
			if back_ray_cast_3d.is_colliding():
				return
			move(-1)
		elif Input.is_action_just_pressed("turn_left"):
			turn(1)
		elif Input.is_action_just_pressed("turn_right"):
			turn(-1)
	
func move(direction):
	can_move = false
	var forward_direction = -transform.basis.z.normalized()
	var target_position = global_position + forward_direction * MOVE_DISTANCE * direction
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_position, MOVE_TIME)
	await tween.finished
	can_move = true


func turn(direction):
	can_move = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y + 90 * direction, MOVE_TIME)
	await tween.finished
	can_move = true


func _on_area_3d_area_entered(area):
	if area.get_parent() is Krople:
		print("TEST")
		heal.emit()
