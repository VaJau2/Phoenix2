extends Area

onready var parent = get_parent()
var hitSound = preload("res://assets/audio/flying/PegasusHit.wav")

func _on_smasharea_body_entered(body):
	if parent.flying_fast && parent.flySpeed > 31:
		var audi = get_node("../audi_hitted")
		audi.stream = hitSound
		audi.play()
		if body is Character:
			body.TakeDamage(parent.flySpeed * 3)
		else:
			parent.stats.TakeDamage(parent.flySpeed - 20, Vector3.ZERO)
			parent.get_node("shield/audi").stop()
			parent.flying = false
