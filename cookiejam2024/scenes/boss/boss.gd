extends Node3D

@onready var sprite_3d = $Sprite3D
@onready var text_label = $CanvasLayer/Control/TextLabel
@onready var text_timer = $TextTimer
@export var dialog_lines = [
	"1,2,3 OTCHŁAN PATRZY!",
	"Twoje oczy sa co raz bardziej zmęczone",
	"Jesli mrugniesz zginiesz",
]
@export var full_text: String
@export var char_delay: float = 0.1 # Opóźnienie między literami

var current_text: String = "" # Tekst aktualnie wyświetlany
var index: int = 0 # Aktualny indeks litery
var i = 0
var j = 0
var is_fighting:bool = false

signal text_end
signal ready_to_hide

func _ready():
	text_label.text = ""
	
func boss_talk():
	is_fighting = true
	if i == len(dialog_lines):
		i = 0
		reset()
		return
	text_label.text = ""
	index = 0
	current_text = ""
	if j == 0:
		full_text = "Wyzywam cię na pojedynek w gapieniu się!"
	elif j == 1:
		full_text = dialog_lines.pick_random()
	i += 1
	text_timer.start()
	
func get_hit():
	#var tween = get_tree().create_tween()
	#tween.tween_property($Sprite3D, "scale", Vector3.ONE, 1)
	is_fighting = false
	#$AnimationPlayer.play("get_hit")
	sprite_3d.play("cry")
	await sprite_3d.animation_finished
	sprite_3d.play("idle")
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite3D, "scale", Vector3.ONE, 1)
	await tween.finished
	text_label.text = ""
	index = 0
	current_text = ""
	full_text = "AAAłłłAAA!"
	i += 1
	#is_fighting = false
	text_timer.start()
	ready_to_hide.emit()

func reset():
	$AnimationPlayer.play("out")
	text_label.text = ""
	i = 0
	j = 1
	await $AnimationPlayer.animation_finished
	get_tree().get_first_node_in_group("player").can_move = true
	is_fighting = false

func _on_text_timer_timeout():
	if index < full_text.length():
		current_text += full_text[index] # Dodaj kolejną literę
		text_label.text = current_text # Zaktualizuj tekst w Label
		index += 1
	else:
		text_timer.stop() # Zatrzymaj timer po wyświetleniu całego tekstu
		#if i == len(dialog_lines):
			#i = 0
			#reset()
		#await get_tree().create_timer(1).timeout
		#boss_talk()
