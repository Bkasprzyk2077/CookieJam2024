extends GridMap
class_name MazeGen2

# Rozmiary labiryntu
@export var z_dim = 10  # Zamiast y_dim (dla osi Z w poziomie)
@export var x_dim = 10  # Długość labiryntu w osi X
@export var y_dim = 1   # Opcjonalna wysokość (dla osi Y)
@export var starting_coords = Vector3i(0, 0, 0)
@export var allow_loops: bool = true
@export var key_scene: PackedScene
@export var krople_scene: PackedScene
@export var doors_scene: PackedScene
@export var eye_scene: PackedScene
@export var trap_scene: PackedScene
@export var torch_scene: PackedScene
# Definicja kafelków
const normal_wall_mesh = "WallMesh"
const walkable_mesh = "FloorMesh"

var floor_tiles_with_one_neighbour = []
var floor_tiles_with_many_neighbours = []

# Sąsiednie kafelki (dla poruszania się po X-Z)
var adj4 = [
	Vector3i(-1, 0, 0),  # W lewo
	Vector3i(1, 0, 0),   # W prawo
	Vector3i(0, 0, -1),  # W dół
	Vector3i(0, 0, 1),   # W górę
]

# Funkcja uruchamiana po dodaniu węzła do sceny
func _ready() -> void:
	randomize()
	place_border()
	dfs(starting_coords)
	count_floor_neighbors()
	generate_items()

# Tworzenie granicy labiryntu
func place_border():
	for z in range(-1, z_dim + 1):  # Iteracja po osi Z
		for y in range(0, y_dim):  # Iteracja po wysokości (Y)
			place_wall(Vector3i(-1, y, z))  # Lewa ściana
			place_wall(Vector3i(x_dim, y, z))  # Prawa ściana
	for x in range(-1, x_dim + 1):  # Iteracja po osi X
		for y in range(0, y_dim):  # Iteracja po wysokości (Y)
			place_wall(Vector3i(x, y, -1))  # Dolna ściana
			place_wall(Vector3i(x, y, z_dim))  # Górna ściana

# Usuwanie kafelka (resetowanie pozycji)
func delete_cell_at(pos: Vector3i):
	set_cell_item(pos, -1)

# Umieszczanie ściany
func place_wall(pos: Vector3i):
	set_cell_item(pos, mesh_library.find_item_by_name(normal_wall_mesh))

# Umieszczanie podłogi
func place_floor(pos: Vector3i):
	set_cell_item(pos, mesh_library.find_item_by_name(walkable_mesh))

# Sprawdzanie, czy kafelek jest ścianą
func is_wall(pos: Vector3i) -> bool:
	return get_cell_item(pos) == mesh_library.find_item_by_name(normal_wall_mesh)

# Sprawdzanie, czy można poruszyć się na daną pozycję
func can_move_to(pos: Vector3i) -> bool:
	return pos.x >= 0 and pos.z >= 0 and pos.y >= 0 and \
		pos.x < x_dim and pos.z < z_dim and pos.y < y_dim and \
		not is_wall(pos)

# Algorytm generowania labiryntu (DFS)
func dfs(start: Vector3i):
	var fringe: Array[Vector3i] = [start]  # Stos
	var seen = {}  # Zbiór odwiedzonych pozycji

	while fringe.size() > 0:
		var current = fringe.pop_back()

		# Pomijanie już odwiedzonych lub niedostępnych pozycji
		if current in seen or not can_move_to(current):
			continue

		seen[current] = true

		# Tworzenie ścian w odpowiednich miejscach
		if current.x % 2 == 1 and current.z % 2 == 1:
			place_wall(current)
			continue

		# Tworzenie podłogi
		place_floor(current)

		# Przetasowanie sąsiednich pozycji (aby urozmaicić kształt labiryntu)
		var found_new_path = false
		adj4.shuffle()
		for offset in adj4:
			var new_pos = current + offset
			if new_pos not in seen and can_move_to(new_pos):
				# Szansa na utworzenie ściany zamiast ścieżki
				var chance_of_no_loop = randi_range(1, 1)
				if allow_loops:
					chance_of_no_loop = randi_range(1, 5)
				if (new_pos.x % 2 == 1 and new_pos.z % 2 == 1) and chance_of_no_loop == 1:
					place_wall(new_pos)
				else:
					found_new_path = true
					fringe.append(new_pos)

		# Jeśli nie znaleziono nowych ścieżek, oznacz miejsce jako ścianę
		if not found_new_path:
			place_wall(current)

# Sprawdzanie, z iloma podłogami sąsiaduje każde pole podłogi
func count_floor_neighbors():
	for x in range(x_dim):
		for z in range(z_dim):
			var current_pos = Vector3i(x, 0, z)  # Pozycja w płaszczyźnie X-Z

			# Sprawdź, czy aktualne pole jest podłogą
			if not is_floor(current_pos):
				continue

			# Licznik sąsiadów będących podłogą
			var floor_neighbors = 0

			# Iteruj po sąsiadach
			for offset in adj4:
				var neighbor_pos = current_pos + offset

				# Sprawdź, czy sąsiad jest w granicach i jest podłogą
				if is_within_bounds(neighbor_pos) and is_floor(neighbor_pos):
					floor_neighbors += 1
			# Wynik dla tego pola
			if floor_neighbors == 1 and current_pos != Vector3i.ZERO:
				floor_tiles_with_one_neighbour.append(current_pos)
			elif floor_neighbors > 1 and current_pos != Vector3i.ZERO:
				floor_tiles_with_many_neighbours.append(current_pos)
	floor_tiles_with_many_neighbours.shuffle()
			
func is_floor(pos: Vector3i) -> bool:
	return get_cell_item(pos) == mesh_library.find_item_by_name("FloorMesh")
	
func is_within_bounds(pos: Vector3i) -> bool:
	return pos.x >= 0 and pos.x < x_dim and \
		   pos.z >= 0 and pos.z < z_dim

func get_single_floor_neighbor(pos: Vector3i) -> Vector3i:
	# Lista możliwych przesunięć (kierunków sąsiadów)
	var directions = [
		Vector3i(-1, 0, 0),  # Lewo
		Vector3i(1, 0, 0),   # Prawo
		Vector3i(0, 0, -1),  # Dół
		Vector3i(0, 0, 1)    # Góra
	]
	
	var floor_neighbor: Vector3i = Vector3i.ZERO
	var neighbor_count = 0
	
	# Sprawdzamy każdego sąsiada
	for direction in directions:
		var neighbor_pos = pos + direction
		if is_within_bounds(neighbor_pos) and is_floor(neighbor_pos):
			floor_neighbor = neighbor_pos  # Przypisujemy współrzędne sąsiada
			neighbor_count += 1
			
			# Jeśli jest więcej niż jeden sąsiad, przerywamy
			if neighbor_count > 1:
				return Vector3i.ZERO
	
	# Jeśli znaleźliśmy dokładnie jednego sąsiada, zwracamy jego współrzędne
	return floor_neighbor if neighbor_count == 1 else Vector3i.ZERO


func generate_items():
	floor_tiles_with_one_neighbour.shuffle()

	var dooors = doors_scene.instantiate()
	var dor_loc = floor_tiles_with_one_neighbour.pop_front()
	add_child(dooors)

	var j = 0
	while floor_tiles_with_one_neighbour and j < 4:
		var torch = torch_scene.instantiate()
		add_child(torch)
		torch.global_position = map_to_local(floor_tiles_with_one_neighbour.pop_front())
		j+=1
	while len(get_tree().get_nodes_in_group("torch")) < 4:
		var torch = torch_scene.instantiate()
		add_child(torch)
		torch.global_position = map_to_local(floor_tiles_with_many_neighbours.pick_random())
		
	dooors.global_position = map_to_local(dor_loc)
	var somsiad = get_single_floor_neighbor(dor_loc)
	print(somsiad)
	dooors.look_at(map_to_local(somsiad))
	print("pole drzwi: ", dooors.global_position)
	print("pole somsiada: ", map_to_local(somsiad))
	
	for tile in floor_tiles_with_one_neighbour:
		var krople = krople_scene.instantiate()
		add_child(krople)
		krople.global_position = map_to_local(tile)
		
	for i in range(6):
		var trap = trap_scene.instantiate()
		add_child(trap)
		trap.global_position = map_to_local(floor_tiles_with_many_neighbours.pop_front())
	
	while len(get_tree().get_nodes_in_group("kropla")) < 5:
		var krople = krople_scene.instantiate()
		add_child(krople)
		krople.global_position = map_to_local(floor_tiles_with_many_neighbours.pop_front())
	print(len(get_tree().get_nodes_in_group("kropla")))
	
	
func random_point_between(vec_a: Vector3, vec_b: Vector3) -> Vector3:
	var t = randf() # Losowy współczynnik w zakresie [0, 1]
	return vec_a + (vec_b - vec_a) * t


func spawn_eye(scene: PackedScene):
	var start = map_to_local(Vector3i(-1, 0, z_dim))
	var end =  map_to_local(Vector3i(-1, 0, -1))
	var point = random_point_between(start, end)
	var eye = eye_scene.instantiate()
	add_child(eye)
	eye.global_position = point + Vector3(0,5,0)


func _on_eye_timer_timeout():
	spawn_eye(eye_scene)
