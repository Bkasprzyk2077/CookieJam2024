extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
	environment.sky.sky_material.panorama = load(["res://assets/sjyboxes/skybox3.png", "res://assets/sjyboxes/skyboxnieb.png"].pick_random())
