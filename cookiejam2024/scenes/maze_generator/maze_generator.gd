extends GridMap
class_name MazeGen

# Rozmiary labiryntu
@export var z_dim = 10  # Zamiast y_dim (dla osi Z w poziomie)
@export var x_dim = 10  # Długość labiryntu w osi X
@export var y_dim = 1   # Opcjonalna wysokość (dla osi Y)
@export var starting_coords = Vector3i(0, 0, 0)
@export var allow_loops: bool = true

# Definicja kafelków
const normal_wall_mesh = "WallMesh"
const walkable_mesh = "FloorMesh"


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
