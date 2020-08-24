extends MeshInstance

onready var myScript = get_node("../../../")

export var closedEyes: SpatialMaterial
export var openEyes: SpatialMaterial

func _hitted():
	set_surface_material(0,closedEyes)
	yield(get_tree().create_timer(0.2),"timeout")
	set_surface_material(0,openEyes)

func _updateEyes():
	var wr = weakref(myScript)
	while(self && wr.get_ref() && myScript.Health > 0):
		yield(get_tree().create_timer(randi() % 2 + 2),"timeout")
		set_surface_material(0,closedEyes)
		yield(get_tree().create_timer(0.1),"timeout")
		set_surface_material(0,openEyes)
	
	set_surface_material(0,closedEyes)

func _ready():
	_updateEyes()
