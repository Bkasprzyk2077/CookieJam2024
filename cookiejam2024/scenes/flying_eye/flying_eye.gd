extends Node3D

@export var amplitude: float = .5  # Maksymalna wysokość unoszenia (w jednostkach)
@export var speed: float = .2      # Prędkość unoszenia (w cyklach na sekundę)
var time_passed: float = 0.0        # Zmienna przechowująca upływ czasu

# Początkowa pozycja obiektu
var initial_position: Vector3

func _ready():
	initial_position = global_position
	scale = randf_range(.5, 1.5) * Vector3.ONE

func _process(delta: float) -> void:
	# Aktualizuj czas
	global_position.x += delta * 5
	time_passed += delta
	
	# Oblicz przesunięcie w osi Y na podstawie funkcji sinus
	var y_offset = sin(time_passed * speed * TAU) * amplitude
	
	# Ustaw nową pozycję
	global_position.y = initial_position.y + y_offset + 4


func _on_timer_timeout():
	queue_free()
