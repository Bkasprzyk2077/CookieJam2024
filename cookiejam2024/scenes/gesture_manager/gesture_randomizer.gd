extends Node

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
	
	
func get_random_pose():
		var pose = []
		for i in range(5):
			pose.append(directions.keys().pick_random())
		return pose
