extends Node

@onready var gesture_detector = $GestureDetector
@onready var gesture_randomizer = $GestureRandomizer
@onready var pose_timer = $PoseTimer
@onready var arrow_rect = $Arrows/Control/ArrowRect
@onready var animation_player = $AnimationPlayer
@onready var enemy_timer = $EnemyTimer

var boss
var playerr
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

var directions_poses = {
	"up": "res://assets/jojohands-test.png",
	"down": "res://assets/poses/jojohands-2.png",
	"left": "res://assets/poses/jojohands-3.png",
	"right": "res://assets/poses/jojohands-4.png",
	"up_right": "res://assets/poses/jojohands-5.png",
	"up_left": "res://assets/poses/jojohands-6.png",
	"down_right": "res://assets/poses/jojohands-7.png",
	"down_left": "res://assets/jojohands-test.png"
}

var current_pose = ""
var still_has_time = true

func _ready():
	enemy_timer.wait_time = randf_range(8, 20)
	playerr = get_tree().get_first_node_in_group("player")
	boss = get_tree().get_first_node_in_group("boss")
	arrow_rect.visible = false
	gesture_detector.current_pose.connect(check_pose.bind())
	playerr.heal.connect(heal.bind())

func check_pose(pose):
	current_pose = pose
	
#func teaser():
	#boss.boss_tease()

func _on_enemy_timer_timeout():
	var pose_player = playerr.get_node("PosePlayer")
	enemy_timer.wait_time = randf_range(8, 20)
	boss.get_node("AnimationPlayer").play("in")
	await boss.get_node("AnimationPlayer").animation_finished
	boss.get_node("AnimationPlayer").play("move_to_player")
	boss.boss_talk()
	arrow_rect.visible = true
	var poses = gesture_randomizer.get_random_pose()
	$EnemyTimer.stop()
	for pose in poses:
		update_ui(pose)
		#pose_timer.start()
		await gesture_detector.current_pose
		if pose == current_pose:
			if pose == poses.back():
				playerr.get_node("Camera3D/Hands").texture = load("res://assets/poses/eyepoke.png")
				if pose_player.is_playing():
					pose_player.play("out")
				pose_player.play("poke")
				get_tree().get_first_node_in_group("player_animation").play("good")
				animation_player.play("good_pose")
				await pose_player.animation_finished
				break
			playerr.get_node("Camera3D/Hands").texture = load(directions_poses[pose])
			print("DOBRZE")
			if pose_player.is_playing():
				pose_player.play("out")
				#await pose_player.animatiot_finished
			pose_player.play("in")
			get_tree().get_first_node_in_group("player_animation").play("good")
			animation_player.play("good_pose")
		else:
			print("ZLE")
			#pose_player.play("out")
			take_damage()
			animation_player.play("bad_pose")
			get_tree().get_first_node_in_group("player_animation").play("bad")
			get_tree().get_first_node_in_group("player_camera").apply_shake()
		still_has_time = true
	arrow_rect.visible = false
	print("KONIEC DIALOGU")
	playerr.get_node("PosePlayer").play("out")
	await pose_player.animation_finished
	#await boss.text_end
	$EnemyTimer.start()
	boss.reset()
	
func take_damage():
	var material = $Arrows/Vignette.material
	if material.get_shader_parameter("outer_radius") < 0.6:
		death()
		return
	material.set_shader_parameter("outer_radius", material.get_shader_parameter("outer_radius") - 0.2)

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
