extends furn_base

export var drop_side: Vector3
export var item_height = 2.0
export var item_prefab: Resource
export var key_name = ""
export var pick_key_text = ""
export var pick_key_text_eng = ""

var item_dropped = false

func dropItem():
	var item
	if item_prefab == null:
		var itemsManager = get_node("/root/Main/items")
		if itemsManager:
			var rand = randi() % itemsManager.items.size() - 1
			item = itemsManager.items[rand].instance()
	else:
		item = item_prefab.instance()
	
	if item:
		if key_name.length() > 0:
			item.key_name = key_name
			item.key_pick_text = pick_key_text
			item.key_pick_text_eng = pick_key_text_eng
		
		get_node("/root/Main/items").add_child(item)
		item.global_transform.origin = global_transform.origin
		var wr = weakref(item)
		while(item_height > 0 && wr.get_ref()):
			item.global_transform.origin.x += drop_side.x * 0.1
			item.global_transform.origin.z += drop_side.z * 0.1
			item.global_transform.origin.y -= 0.1
			item_height -= 0.1
			yield(get_tree(),"idle_frame")


func clickFurn(sound=null, timer=0, force=null):
	.clickFurn()
	if open:
		if !item_dropped:
			if randf() < 0.65 || item_prefab != null:
				dropItem()
			item_dropped = true
	return 0
