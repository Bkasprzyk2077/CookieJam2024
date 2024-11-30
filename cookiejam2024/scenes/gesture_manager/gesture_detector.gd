extends Node2D

var is_drawing = false
var start_position = Vector2.ZERO
var points = []

# Konfiguracja
var min_distance = 100 # Minimalna długość gestu
var max_angle_deviation = 20 # Maksymalny kąt odchylenia od osi

signal current_pose(pose)

func _ready():
	# Tworzymy Line2D do wizualizacji
	var line = Line2D.new()
	line.name = "gesture_line"
	line.width = 50
	line.default_color = Color(1, 1, 1)
	#line.gradient = 
	line.texture = load("res://assets/icon.svg")
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	add_child(line)
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Rozpoczynamy rysowanie
				start_drawing(event.position)
			else:
				# Kończymy rysowanie
				end_drawing(event.position)

	elif event is InputEventMouseMotion and is_drawing:
		update_drawing(event.position)

func start_drawing(position):
	is_drawing = true
	start_position = position
	points = [start_position]
	get_node("gesture_line").points = points

func update_drawing(position):
	# Dodajemy nowy punkt do ścieżki
	points.append(position)
	get_node("gesture_line").points = points

func end_drawing(end_position):
	is_drawing = false
	# Sprawdzamy, czy gest jest poprawny
	if is_gesture_valid():
		var pose = get_direction(start_position, end_position)
		emit_signal("current_pose", pose)
	else:
		emit_signal("current_pose", "wrong")
	# Resetujemy linię
	get_node("gesture_line").points = []

func is_gesture_valid() -> bool:
	if points.size() < 2:
		return false

	# Obliczamy różnicę między początkiem a końcem
	var direction = points[-1] - start_position

	# Sprawdzamy długość gestu
	if direction.length() < min_distance:
		return false

	# Sprawdzamy, czy gest jest w miarę prosty
	if not is_straight_path():
		return false

	return true

func is_straight_path() -> bool:
	# Tolerancja odchylenia od linii
	var tolerance = 20.0

	# Wektor wyznaczający linię między początkiem a końcem
	var line_vector = points[-1] - start_position
	var line_length = line_vector.length()
	if line_length == 0:
		return false

	line_vector = line_vector.normalized()

	for point in points:
		# Wektor od początku do danego punktu
		var point_vector = point - start_position
		# Obliczamy rzut punktu na linię
		var projection_length = point_vector.dot(line_vector)
		var closest_point_on_line = start_position + line_vector * projection_length
		var distance_to_line = (point - closest_point_on_line).length()

		# Jeśli punkt jest zbyt daleko od linii, gest nie jest prosty
		if distance_to_line > tolerance:
			return false

	return true

func get_direction(start_position: Vector2, end_position: Vector2) -> String:
	var direction = (end_position - start_position).normalized()

	# Definicje kierunków (wektory odniesienia)
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

	var best_match = ""
	var best_dot = -1.0

	# Porównaj gest z każdym kierunkiem
	for dir_name in directions.keys():
		var dir_vector = directions[dir_name]
		var dot = direction.dot(dir_vector) # Iloczyn skalarny
		if dot > best_dot: # Znajdź kierunek o największym podobieństwie
			best_dot = dot
			best_match = dir_name

	return best_match
