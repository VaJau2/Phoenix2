extends Spatial

export var enemy: Resource
var playerSee = false

func spawn():
	var new_enemy = enemy.instance()
	get_node("../../").add_child(new_enemy)
	new_enemy.global_transform.origin = global_transform.origin
	new_enemy.set_state("attack")
	queue_free()


func _on_VisibilityNotifier_screen_entered():
	playerSee = true


func _on_VisibilityNotifier_screen_exited():
	playerSee = false
