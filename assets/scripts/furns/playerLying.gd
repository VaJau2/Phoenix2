extends Spatial

onready var faintListener = get_node("/root/Main/faintListener")
onready var playerListener = get_node("/root/Main/Player/Rotation_Helper/Camera/Listener")

onready var prisonDoor = get_node("../../bars-door")
onready var checkLoc = get_node("../../../../../changeLocs")

onready var enemy_manager = get_node("/root/Main/enemies")
onready var faintScreen = get_node("/root/Main/canvas/faintScreen")
var faints_count = 0

onready var collarOwnerPos = get_node("../../trader_idle")
onready var noteThreat = get_node("../../threatNote")

var weapons = {
	"pistol": preload("res://objects/items/pistol.tscn"),
	"revolver": preload("res://objects/items/revolver.tscn"),
	"sniper": preload("res://objects/items/rifle.tscn"),
	"shotgun": preload("res://objects/items/shotgun.tscn")
}
var key = preload("res://objects/items/key.tscn")


func dropItem(item_prefab, item_height, position):
	var item = item_prefab.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = position
	
	item.global_transform.origin.y += item_height


func dropKey():
	var item = key.instance()
	get_node("/root/Main/items").add_child(item)
	item.global_transform.origin = G.player.global_transform.origin
	item.key_name = "prison_key"
	item.key_pick_text = "Подобран ключ от решетки"
	item.global_transform.origin.y += 1


func Faint():
	#делаем врагов спокойными
	if G.race == 1 && G.player.stats.shieldMesh.visible && G.player.stats.Health > 30:
		return
	
	faints_count += 1
	G.player.mayMove = false
	G.player.body.playback.travel("Die1")
	G.player.collar.set_process(false)
	G.player.teleport_inside = false
	
	var black_screen = G.player.stats.black_screen
	black_screen.visible = true
	while black_screen.color.a < 1:
		black_screen.color.a += 0.1
		yield(get_tree(),"idle_frame")
	
	faintListener.current = true
	
	var slaves = get_node("/root/Main/slaves").get_children()
	var slaves_alive = true
	for temp_slave in slaves:
		if temp_slave.Health > 0:
			temp_slave.moveToPrison()
		else:
			slaves_alive = false
	
	if faints_count > 2 && slaves_alive:
		if !noteThreat.is_visible():
			noteThreat.set_visible(true)
		else:
			var slaveI = 0
			if slaves.size() > 1:
				slaveI = randi() % 1
			slaves[slaveI].TakeDamage(50, 0, true)
			slaves[slaveI].audi.stop()
	
	
	enemy_manager.CheckDead()
	enemy_manager.MakeEveryoneCalm(true)
	if prisonDoor.open:
		prisonDoor.clickFurn("key_all")
		prisonDoor.my_key = "prison_key"
	
	
	if checkLoc.current_location.name == "bunker":
		get_node("../../../../../bunker").visible = false
		var land = get_node("../../../..")
		land.visible = true
		checkLoc.current_location = land
	
	if "prison_key" in G.player.stats.my_keys:
		G.player.stats.my_keys.erase("prison_key")
		dropKey()
	
	for wName in G.player.weapons.weapons:
		if G.player.weapons.weaponStats[wName+"_have"]:
			G.player.weapons.weaponStats[wName+"_have"] = false
			dropItem(weapons[wName], 0.5, G.player.global_transform.origin)
	if G.player.weapons.gunOn:
		G.player.weapons._setGunOn(false)
	G.player.weapons.disactiveGunModel()
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag").set_visible(false)
	G.player.body_follows_camera = false
	
	black_screen.visible = true
	black_screen.color.a = 1.0
	G.player.camera.eyes_closed = true
	
	yield(get_tree().create_timer(1),"timeout")
	faintScreen.visible = true

	yield(get_tree().create_timer(4),"timeout")
	faintScreen.visible = false
	
	G.player.stats.redScreen.modulate.a = 0
	G.player.global_transform.origin = global_transform.origin
	G.player.global_transform.basis = global_transform.basis
	G.player.rotation = Vector3(0, G.player.rotation.y, 0)
	G.player.scale = Vector3(1.05,1.05,1.05)
	
	G.player.OnStairs = false
	if G.player.crouching:
		G.player._sit(false)
	
	if !G.player.collar.is_visible():
		var trader = enemy_manager._getCloserTrader()
		if trader:
			trader.set_state("idle")
			trader.my_start_pos = collarOwnerPos.global_transform.origin
			trader.global_transform.origin = trader.my_start_pos
			trader.patrolArray.clear()
			trader.collar_key = true
			G.player.collar.set_visible(true)
			G.player.collar.my_owner = trader
	
	G.player.collar.set_process(true)
	G.player.Faint(faints_count > 1)
	playerListener.current = true
	
	while(black_screen.color.a > 0):
		if !G.paused:
			black_screen.color.a -= 0.1
		yield(get_tree(),"idle_frame")
	
	black_screen.visible = false
	G.player.camera.eyes_closed = false
