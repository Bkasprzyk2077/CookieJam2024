extends Node

var directions = {
	"up": Vector2(0, -1),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0),
	"right": Vector2(1, 0),
	"up_right": Vector2(1, -1).normalized(),
	"up_left": Vector2(-1, -1).normalized(),
	"down_right": Vector2(1, 1).normalized(),
	"down_left": Vector2(-1, 1).normalized()
}
	
	
func get_random_pose():
		var pose = []
		for i in range(5):
			pose.append(directions.keys().pick_random())
		return pose
