extends AudioStreamPlayer


func play_sound(sound):
	#stream = load(sound)
	#play()
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	new_player.stream = load(sound)
	new_player.pitch_scale = randf_range(0.8,1.2)
	new_player.play()
	new_player.finished.connect(new_player.queue_free.bind())
