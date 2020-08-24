extends CollisionShape

export var my_pos_path: NodePath
var my_pos
onready var my_parent = get_parent()


func _ready():
	my_pos = get_node(my_pos_path)


func _process(delta):
	if my_parent.Health > 0:
		global_transform.origin = my_pos.global_transform.origin
		global_transform.basis = my_pos.global_transform.basis
