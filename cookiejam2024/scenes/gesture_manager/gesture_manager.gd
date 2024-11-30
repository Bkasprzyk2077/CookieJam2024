extends Node

@onready var gesture_detector = $GestureDetector
@onready var gesture_randomizer = $GestureRandomizer
@onready var pose_timer = $PoseTimer
@onready var arrow_rect = $Arrows/Control/ArrowRect
@onready var animation_player = $AnimationPlayer

var directions = {
	"up": -90,
	"down": 90,
	"left": 180,
	"right": 0,
	"up_right": -45,
	"up_left": -125,
	"down_right": 45,
	"down_left": 125
}

var current_pose = ""
var still_has_time = true

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	arrow_rect.visible = false
	gesture_detector.current_pose.connect(check_pose.bind())
	player.heal.connect(heal.bind())

func check_pose(pose):
	current_pose = pose

func _on_enemy_timer_timeout():
	arrow_rect.visible = true
	var poses = gesture_randomizer.get_random_pose()
	for pose in poses:
		update_ui(pose)
		#pose_timer.start()
		print("Zrob: ", pose)
		await gesture_detector.current_pose
		if still_has_time == false:
			print("KONIEC CZASU")
		elif pose == current_pose:
			print("DOBRZE")
			get_tree().get_first_node_in_group("player_animation").play("good")
			animation_player.play("good_pose")
		else:
			print("ZLE")
			take_damage()
			animation_player.play("bad_pose")
			get_tree().get_first_node_in_group("player_animation").play("bad")
			get_tree().get_first_node_in_group("player_camera").apply_shake()
		still_has_time = true
	arrow_rect.visible = false
	$EnemyTimer.start()
	
func take_damage():
	var material = $Arrows/Vignette.material
	if material.get_shader_parameter("outer_radius") < 0.6:
		death()
		return
	material.set_shader_parameter("outer_radius", material.get_shader_parameter("outer_radius") - 0.2)
	#ShaderMaterial
	#var tween = get_tree().create_tween()
	#tween.tween_property(material.shader, "outer_radius", material.get_shader_parameter("outer_radius")+1, .1)
	
func death():
	print("DEATH")
	var material = $Arrows/Vignette.material
	material.set_shader_parameter("outer_radius", 1.5)

func heal():
	var material = $Arrows/Vignette.material
	if material.get_shader_parameter("outer_radius") > 1.5:
		return
	material.set_shader_parameter("outer_radius", min(material.get_shader_parameter("outer_radius") + 0.4, 1.5))

func update_ui(pose):
	arrow_rect.rotation_degrees = directions[pose]

func _on_pose_timer_timeout():
	still_has_time = false
