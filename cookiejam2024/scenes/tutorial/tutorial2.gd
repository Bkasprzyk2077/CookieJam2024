extends CanvasLayer

@onready var control = $root/Control1
@onready var control_2 = $root/Control2


var i = 0
var controls = [control, control_2]
# Called when the node enters the scene tree for the first time.
func _ready():
	controls = [control, control_2]
	control.visible = true

func _on_next_pressed():
	if i == len(controls)-1:
		Transition.fade_out("res://scenes/levels/main2.tscn")
	else:
		controls[i].visible = false
		i+=1
		controls[i].visible = true
