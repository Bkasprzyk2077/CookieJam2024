extends Node3D

class_name player

@onready var front_ray_cast_3d = $FrontRayCast3D
@onready var back_ray_cast_3d = $BackRayCast3D

const MOVE_DISTANCE = 5
const MOVE_TIME = .2
var can_move:bool = true
var has_key:bool = false
var boss

signal heal

func _ready():
	boss = get_tree().get_first_node_in_group("boss")

func _process(delta):
	#print(has_key)
	if can_move and !boss.is_fighting:
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
		if get_tree().get_first_node_in_group("vintage").material.get_shader_parameter("outer_radius") > 1.5:
			return
		heal.emit()
		$AnimationPlayer.play("krople")
		area.get_parent().queue_free()
	elif area.get_parent() is Key:
		has_key = true
		get_tree().get_first_node_in_group("doors").open()
		get_tree().get_first_node_in_group("doors").get_node("PlaerLight").visible = true
		area.get_parent().queue_free()
	elif area.get_parent() is doors and has_key:
		print("WYGRAŁEŚ")
