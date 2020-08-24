extends Enemy

var my_script
var temp_scores = 12


func dropScores(script):
	temp_scores = 12
	my_script = script
	while rotation_degrees.x < 0:
		rotation_degrees.x += 5
		yield(get_tree(),"idle_frame")
	active = true
	Health = 50


func TakeDamage(damage: int, shapeID = 0):
	if active:
		.TakeDamage(damage)
		if Health <= 0:
			var increase = 1
			match shapeID:
				1:
					increase = 2
				2:
					increase = 3
				3:
					increase = 5
			var got_scores = int(temp_scores * increase)
			my_script.hitTarget(got_scores)
			while rotation_degrees.x > -90:
				rotation_degrees.x -= 10
				yield(get_tree(),"idle_frame")


func _process(delta):
	if active:
		temp_scores -= delta
