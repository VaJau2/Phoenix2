extends TextureRect

func setRed():
	modulate = Color.red
	yield(get_tree().create_timer(0.5),"timeout")
	modulate = Color.white
