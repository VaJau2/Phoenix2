extends RigidBody

func _ready():
	yield(get_tree(),"idle_frame")
	var side_x = randf() - 0.5 * 8
	var side_z = randf() - 0.5 * 8
	set_linear_velocity(Vector3(side_x, 5, side_z))
	set_angular_velocity(Vector3(side_x, 5, side_z))
	
	yield(get_tree().create_timer(9), "timeout")
	queue_free()
