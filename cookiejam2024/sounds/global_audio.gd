extends AudioStreamPlayer


func play_sound(sound):
	stream = load(sound)
	play()
