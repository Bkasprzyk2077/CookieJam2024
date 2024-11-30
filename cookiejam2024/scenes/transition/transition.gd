extends CanvasLayer


func _ready():
	$AnimationPlayer.play("out")

func fade_in():
	$AnimationPlayer.play("out")
	get_tree().paused = false

func fade_out(scene):
	$AnimationPlayer.play("in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(scene)
	fade_in()
