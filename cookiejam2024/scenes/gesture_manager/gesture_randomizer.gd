extends Node

var directions = [
	"up",
	"down",
	"left",
	"right",
	"up_right",
	"up_left",
	"down_right",
	"down_left"
]
	
	
func get_random_pose():
		var poses_copy = directions.duplicate()
		poses_copy.shuffle()
		var pose = []
		for i in range(5):
			pose.append(poses_copy.pop_front())
		return pose
