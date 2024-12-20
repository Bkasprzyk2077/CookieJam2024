extends Node

@onready var gesture_detector = $GestureDetector
@onready var gesture_randomizer = $GestureRandomizer
@onready var pose_timer = $PoseTimer
@onready var arrow_rect = $Arrows/Control/ArrowRect
@onready var animation_player = $AnimationPlayer
@onready var enemy_timer = $EnemyTimer

var can_boss_attack = true
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

var directions_sounds = {
	"up": "res://sounds/pose4.wav",
	"down": "res://sounds/pose2.wav",
	"left": "res://sounds/pose3.wav",
	"right": "res://sounds/pose4.wav",
	"up_right": "res://sounds/pose5chyba.wav",
	"up_left": "res://sounds/pose2.wav",
	"down_right": "res://sounds/pose3.wav",
	"down_left": "res://sounds/pose4.wav"
}

var directions_poses = {
	"up": "res://assets/jojohands-test.png",
	"down": "res://assets/poses/jojohands-2.png",
	"left": "res://assets/poses/jojohands-3.png",
	"right": "res://assets/poses/jojohands-4.png",
	"up_right": "res://assets/poses/jojohands-5.png",
	"up_left": "res://assets/poses/jojohands-6.png",
	"down_right": "res://assets/poses/jojohands-7.png",
	"down_left": "res://assets/poses/jojohands-8.png"
}

var current_pose = ""
var still_has_time = true
var material

func _ready():
	material = $Arrows/Vignette.material
	enemy_timer.wait_time = randf_range(8, 20)
	playerr = get_tree().get_first_node_in_group("player")
	boss = get_tree().get_first_node_in_group("boss")
	arrow_rect.visible = false
	gesture_detector.current_pose.connect(check_pose.bind())
	playerr.heal.connect(heal.bind())
	playerr.hit.connect(take_damage.bind())

func _process(delta):
	if material.get_shader_parameter("outer_radius") < .1:
		death()
	elif material.get_shader_parameter("outer_radius") < .5:
		can_boss_attack = false
	else:
		can_boss_attack = true
	material.set_shader_parameter("outer_radius", material.get_shader_parameter("outer_radius") - delta/20)

func check_pose(pose):
	current_pose = pose
	if !boss.is_fighting:
		free_poke()

func _on_enemy_timer_timeout():
	if !can_boss_attack:
		enemy_timer.wait_time = randf_range(3, 6)
		enemy_timer.start()
		return
	var pose_player = playerr.get_node("PosePlayer")
	enemy_timer.wait_time = randf_range(8, 20)
	boss.get_node("AnimationPlayer").play("in")
	await boss.get_node("AnimationPlayer").animation_finished
	boss.get_node("AnimationPlayer").play("move_to_player")
	boss.boss_talk()
	arrow_rect.visible = true
	var poses = gesture_randomizer.get_random_pose()
	enemy_timer.stop()
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
				$Finisher.play()
				get_tree().get_first_node_in_group("player_animation").play("good")
				animation_player.play("good_pose")
				boss.get_hit()
				arrow_rect.visible = false
				await boss.ready_to_hide
				#print("KONIEC DIALOGU")
				enemy_timer.start()
				boss.reset()
				return
				
			playerr.get_node("Camera3D/Hands").texture = load(directions_poses[pose])
			#print("DOBRZE")
			if pose_player.is_playing():
				pose_player.play("out")
				#await pose_player.animatiot_finished
			pose_player.play("in")
			GlobalAudio.play_sound(directions_sounds[pose])
			get_tree().get_first_node_in_group("player_animation").play("good")
			animation_player.play("good_pose")
		else:
			playerr.use_knife()
			take_damage()
			GlobalAudio.play_sound("res://sounds/beartrap.wav")
			await playerr.knife.animation_finished
			break
		still_has_time = true
	arrow_rect.visible = false
	#print("KONIEC DIALOGU")
	playerr.get_node("PosePlayer").play("out")
	await pose_player.animation_finished
	$EnemyTimer.start()
	boss.reset()
	
func take_damage():
	animation_player.play("bad_pose")
	get_tree().get_first_node_in_group("player_animation").play("bad")
	get_tree().get_first_node_in_group("player_camera").apply_shake()
	if material.get_shader_parameter("outer_radius") < 0.6:
		death()
		return
	material.set_shader_parameter("outer_radius", material.get_shader_parameter("outer_radius") - 0.2)

func death():
	playerr.can_move = false
	#print("DEATH")
	Transition.fade_out("res://scenes/end_game_menu/EndGameMenu.tscn")
	material.set_shader_parameter("outer_radius", 1.6)

func heal():
	if material.get_shader_parameter("outer_radius") > 1.6:
		return
	material.set_shader_parameter("outer_radius", 1.6)

func free_poke():
	var collider = playerr.get_node("TrapRayCast3D").get_collider()
	if collider:
		if collider.get_parent() is Trap:
			$poke.play()
			collider.get_parent().kill()
			var pose_player = playerr.get_node("PosePlayer")
			playerr.get_node("Camera3D/Hands").texture = load("res://assets/poses/eyepoke.png")
			if pose_player.is_playing():
				pose_player.play("out")
			pose_player.play("poke")
		elif collider.get_parent() is Torch:
			playerr.torch_count += 1
			print("TORCHES: ", playerr.torch_count)
			if playerr.torch_count >= 3:
				var dor = get_tree().get_first_node_in_group("doors2")
				print(dor)
				if dor:
					dor.open()
				
			$poke.play()
			collider.get_parent().fire()
			var pose_player = playerr.get_node("PosePlayer")
			playerr.get_node("Camera3D/Hands").texture = load("res://assets/poses/eyepoke.png")
			if pose_player.is_playing():
				pose_player.play("out")
			pose_player.play("poke")
			
func update_ui(pose):
	arrow_rect.rotation_degrees = directions[pose]

func _on_pose_timer_timeout():
	still_has_time = false
