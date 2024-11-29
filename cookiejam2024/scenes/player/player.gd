extends Node3D

const MOVE_DISTANCE = 5
const MOVE_TIME = .2
	
func _process(delta):
	if Input.is_action_just_pressed("move_forward"):
		move_forward()
	elif Input.is_action_just_pressed("move_backward"):
		move_backward()
	elif Input.is_action_just_pressed("turn_left"):
		turn_left()
	elif Input.is_action_just_pressed("turn_right"):
		turn_right()
	
func move_forward():
	var forward_direction = -transform.basis.z.normalized()
	var target_position = global_position + forward_direction * MOVE_DISTANCE
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_position, MOVE_TIME)

func move_backward():
	var forward_direction = -transform.basis.z.normalized()
	var target_position = global_position + forward_direction * -MOVE_DISTANCE
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_position, MOVE_TIME)
	
func turn_left():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y+90, MOVE_TIME)
	
func turn_right():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y-90, MOVE_TIME)
