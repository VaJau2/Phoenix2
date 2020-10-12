extends Area

onready var dragon = get_parent()

func _on_smasharea_body_entered(body):
	if dragon.Health <= 0 && dragon.start_falling:
		dragon.falling = false
