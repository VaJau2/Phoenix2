extends Spatial

onready var light = get_parent()

func _on_offArea_body_entered(body):
	if body.name == "Player":
		light.visible = true


func _on_offArea_body_exited(body):
	if body.name == "Player":
		light.visible = false
