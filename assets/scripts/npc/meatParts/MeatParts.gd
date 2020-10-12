extends Spatial

var meats = [
	preload("res://objects/npc/meat/meat1.tscn"),
	preload("res://objects/npc/meat/meat2.tscn")
]

func _ready():
	$Particles.set_emitting(true)
	$Particles2.set_emitting(true)
	yield(get_tree(),"idle_frame")
	
	var meat_pony = get_node("meat-pony")
	var meat_pony_pos = meat_pony.global_transform.origin
	remove_child(meat_pony)
	get_parent().add_child(meat_pony)
	meat_pony.global_transform.origin = meat_pony_pos
	
	yield(get_tree().create_timer(1.5),"timeout")
	queue_free()
