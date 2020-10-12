extends MeshInstance

onready var myScript = get_node("../../../")

export var closedEyes: SpatialMaterial
export var openEyes: SpatialMaterial

var active = true #специально для спящей торговки

func _hitted():
	set_surface_material(0,closedEyes)
	yield(get_tree().create_timer(0.2),"timeout")
	set_surface_material(0,openEyes)

func _updateEyes():
	var wr = weakref(myScript)
	while(self && wr.get_ref() && myScript.Health > 0 && active):
		yield(get_tree().create_timer(randi() % 2 + 2),"timeout")
		
		if G.paused:
			yield(get_tree(),"idle_frame")
			return
		set_surface_material(0,closedEyes)
		
		yield(get_tree().create_timer(0.1),"timeout")
		
		if G.paused:
			yield(get_tree(),"idle_frame")
			return
		set_surface_material(0,openEyes)
	
	set_surface_material(0,closedEyes)

func _ready():
	_updateEyes()
