extends Area

var enemies_inside = []

func _on_shotgunArea_body_entered(body):
	if body is Character:
		enemies_inside.append(body)
	elif "broken" in body:
		enemies_inside.append(body)


func _on_shotgunArea_body_exited(body):
	if body in enemies_inside:
		enemies_inside.erase(body)
