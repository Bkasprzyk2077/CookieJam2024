extends Node

@onready var gesture_detector = $GestureDetector
@onready var gesture_randomizer = $GestureRandomizer
var current_pose = ""

func _ready():
	gesture_detector.current_pose.connect(check_pose.bind())

func check_pose(pose):
	current_pose = pose

func _on_enemy_timer_timeout():
	var poses = gesture_randomizer.get_random_pose()
	for pose in poses:
		print("Zrob: ", pose)
		await gesture_detector.current_pose
		if pose == current_pose:
			print("DOBRZE")
		else:
			print("ZLE")
