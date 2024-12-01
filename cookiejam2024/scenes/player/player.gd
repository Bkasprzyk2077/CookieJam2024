extends Node3D

class_name player

@onready var front_ray_cast_3d = $FrontRayCast3D
@onready var back_ray_cast_3d = $BackRayCast3D
@onready var knife = $Camera3D/Knife

const MOVE_DISTANCE = 5
const MOVE_TIME = .2
var can_move:bool = true
var has_key:bool = false
var boss

var torch_count = 0

signal heal
signal hit

func _ready():
	heal.emit()
	$Area3D/CollisionShape3D.disabled = true
	boss = get_tree().get_first_node_in_group("boss")
	await get_tree().create_timer(1).timeout
	$Area3D/CollisionShape3D.disabled = false

func _process(delta):
	#print("Can move: ", can_move)
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
	#$AudioStreamPlayer3D.play()
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
		$krople_sound.play()
		get_tree().get_first_node_in_group("gm").can_boss_attack = false
		$AnimationPlayer.play("krople")
		area.get_parent().queue_free()
	elif area.get_parent() is Trap:
		hit.emit()
		$hit_sound.play()
		area.get_parent().kill()
	elif area.get_parent() is Key:
		print(area.get_parent())
		has_key = true
		get_tree().get_first_node_in_group("doors").open()
		get_tree().get_first_node_in_group("doors").get_node("PlaerLight").visible = true
		area.get_parent().queue_free()
	elif area.get_parent() is doors and has_key:
		print("WYGRAŁEŚ")
		Transition.fade_out("res://scenes/levels/main2.tscn")
	elif area.get_parent() is Doors2:
		print("WYGRAŁEŚ")
		Transition.fade_out("res://scenes/end_game_menu/EndGameMenu.tscn")
	
func reset_boss_attack():
		get_tree().get_first_node_in_group("gm").can_boss_attack = true

func use_knife():
	knife.visible = true
	knife.play()
	await knife.animation_finished
	knife.visible = false
