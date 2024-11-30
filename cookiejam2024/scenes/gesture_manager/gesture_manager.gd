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
	arrow_rect.visible = false
	gesture_detector.current_pose.connect(check_pose.bind())

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
			animation_player.play("good_pose")
		else:
			print("ZLE")
			animation_player.play("bad_pose")
		still_has_time = true
	arrow_rect.visible = false
	$EnemyTimer.start()

func update_ui(pose):
	arrow_rect.rotation_degrees = directions[pose]

func _on_pose_timer_timeout():
	still_has_time = false
