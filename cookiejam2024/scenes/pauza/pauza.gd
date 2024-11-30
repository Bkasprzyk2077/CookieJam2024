extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func wznow():
	visible = false
	get_tree().paused = false

func pause():
	visible = true
	get_tree().paused = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()
