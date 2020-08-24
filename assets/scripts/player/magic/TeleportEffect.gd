extends Spatial


func _ready():
	$anim.play("idle")
	yield(get_tree().create_timer(1),"timeout")
	queue_free()
