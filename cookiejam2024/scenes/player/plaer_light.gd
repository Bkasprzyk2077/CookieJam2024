extends OmniLight3D

@export var noise: NoiseTexture3D
var time_passed := 0.0
var offset
var can_start = false

func _ready():
	randomize()
	offset = randf_range(1, 3)
	if get_parent().get_parent() is player:
		offset = 0
	await get_tree().create_timer(offset)
	can_start = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !can_start:
		return
	time_passed += delta
	#print(time_passed)
	
	var sampled_noise = noise.noise.get_noise_1d(time_passed * 2)
	#sampled_noise = abs(sampled_noise) * 100
	sampled_noise = sin(time_passed)*2.5 + 15
	
	#print(sin(time_passed)*2.5 + 15)
	light_energy = sampled_noise
	pass
