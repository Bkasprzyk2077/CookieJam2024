extends CanvasLayer

@onready var control = $root/Control
@onready var control_2 = $root/Control2
@onready var control_3 = $root/Control3
var i = 0
var controls = [control, control_2, control_3]
# Called when the node enters the scene tree for the first time.
func _ready():
	controls = [control, control_2, control_3]
	control.visible = true
	control_2.visible = false
	control_3.visible = false

func _on_next_pressed():
	if i == len(controls):
		Transition.fade_out("res://scenes/levels/main.tscn")
	else:
		controls[i].visible = false
		i+=1
		controls[i].visible = true
