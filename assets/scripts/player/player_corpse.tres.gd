extends RigidBody

var weapons = {
	"pistol": preload("res://objects/items/pistol.tscn"),
	"revolver": preload("res://objects/items/revolver.tscn"),
	"sniper": preload("res://objects/items/rifle.tscn"),
	"shotgun": preload("res://objects/items/shotgun.tscn")
}
var spawnWeapons = []


func dropItem(item_prefab, item_height, item_down = false):
	var item = item_prefab.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = global_transform.origin
	
	if !item_down:
		item.global_transform.origin.y += item_height
	else:
		var side_x = randf() - 0.5
		var side_z = randf() - 0.5
		var wr = weakref(item)
		while(item_height > 0 && wr.get_ref()):
			item.global_transform.origin.x += side_x * 0.5
			item.global_transform.origin.z += side_z * 0.5
			item.global_transform.origin.y -= 0.4
			item_height -= 0.4
			yield(get_tree(),"idle_frame")


func _ready():
	if G.race != 1:
		$"player_corpse1/horn".visible = false
	if G.race != 2:
		$"player_corpse1/WingL".visible = false
		$"player_corpse1/WingR".visible = false
	
	yield(get_tree().create_timer(0.1),"timeout")
	if spawnWeapons.size() > 0:
		for weapon in spawnWeapons:
			dropItem(weapons[weapon], 0.5, true)
	
	yield(get_tree().create_timer(1),"timeout")
	while(get_angular_velocity().length() > 0 && \
	get_linear_velocity().length() > 0):
		yield(get_tree(),"idle_frame")
	set_mode(1)
