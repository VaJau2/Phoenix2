extends StaticBody

var broken = false
var hearing_zebras = []

export var brake_damage = 50
export var broken_material: SpatialMaterial
export var mirror = false
export var lamp = false
export var item_prefab: Resource
var item_height = 0.4

export var sound = {}
#sound has:
#	brake1
#	brake2

func dropItem():
	var item = item_prefab.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = global_transform.origin
	var side_x = randf() - 0.5
	var side_z = randf() - 0.5
	var wr = weakref(item)
	while(item_height > 0 && wr.get_ref()):
		item.global_transform.origin.x += side_x * 0.1
		item.global_transform.origin.z += side_z * 0.1
		item.global_transform.origin.y -= 0.1
		item_height -= 0.1
		yield(get_tree(),"idle_frame")

func brake(damage):
	for zebra in hearing_zebras:
		if zebra.state != 1:
			zebra.player_last_pos = global_transform.origin
			zebra.set_state("seek")
	
	if !broken && damage <= brake_damage:
		if broken_material:
			$window.set_surface_material(0, broken_material)
		broken = true
		$audi.stream = sound.brake1
		$audi.play()
	else:
		if mirror:
			$Mirror2.mirrorOff()
			$Mirror2.visible = false
		
		if !lamp:
			$audi.stream = sound.brake2
		else:
			$audi.stream = sound.brake1
		
		if item_prefab:
			dropItem()
		
		$window.visible = false
		$shape.disabled = true
		$Particles.set_emitting(true)
		$audi.play()
		yield(get_tree().create_timer(1.5),"timeout")
		queue_free()


func _on_enemyArea_body_entered(body):
	if body is Character && "player_last_pos" in body:
		hearing_zebras.append(body)


func _on_enemyArea_body_exited(body):
	if body is Character && body in hearing_zebras:
		hearing_zebras.erase(body)


func _ready():
	var nuclear = get_node("/root/Main/props/bombs")
	if nuclear:
		nuclear.windows.append(self)
