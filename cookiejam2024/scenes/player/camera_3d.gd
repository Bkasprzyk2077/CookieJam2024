extends Camera3D

@export var randomStrength: float = 1.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength,0.0,shakeFade * delta)
		randomOffset()

func apply_shake():
	shake_strength = randomStrength

func randomOffset():
	h_offset = rng.randf_range(-shake_strength,shake_strength)
	v_offset = rng.randf_range(-shake_strength,shake_strength)
