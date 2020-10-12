extends Node

const SHAKE_SPEED = 4
const SHAKE_DIFF = 0.5

#--статистика-----
var temp_weapon = "pistol"
var temp_weapon_num = 0

var weapons = ["pistol", "shotgun", "revolver", "sniper"]

var weaponStats = {
	"pistol_have": false,
	"shotgun_have": false,
	"revolver_have": false,
	"sniper_have": false,
	
	"pistol_ammo": 50,
	"shotgun_ammo": 5,
	"revolver_ammo": 20,
	"sniper_ammo": 5,
	
	"pistol_ammoMax": 100,
	"shotgun_ammoMax": 60,
	"revolver_ammoMax": 100,
	"sniper_ammoMax": 15,
	
	"pistol_damage": 20,
	"shotgun_damage": 110,
	"revolver_damage": 20,
	"sniper_damage": 70,
	
	"pistol_distance": 80,
	"shotgun_distance": 40,
	"revolver_distance": 80,
	"sniper_distance": 200,
	
	"pistol_cooldown": 0.7,
	"shotgun_cooldown": 2,
	"revolver_cooldown": 0.5,
	"sniper_cooldown": 1.6,
	
	"pistol_recoil": 4.0,
	"shotgun_recoil": 2.5,
	"revolver_recoil": 3.0,
	"sniper_recoil": 1.5,
	
	"pistol_icon": 40,
	"shotgun_icon": 80,
	"revolver_icon": 40,
	"sniper_icon": 120,
}

#-- Камера и тело для проверки угла поворота + коллизия
onready var body = get_node("../player_body")
onready var camera = get_node("../Rotation_Helper")
onready var head = get_node("../player_body/Armature/Skeleton/Head")
onready var collision = get_node("../gun_shape")

onready var rayHead = get_node("../Rotation_Helper/Camera/ray")
onready var rayThird = get_node("../Rotation_Helper_Third/CameraThird/ray")
onready var rayShotgun = get_node("../player_body/ray")
onready var shotgunArea = get_node("../player_body/shotgunArea")
var camera_script

#-- Интерфейс
onready var stats = get_node("../stats")
onready var askGet = get_node("../../canvas/openBack")
var label 
onready var shootInterface = get_node("../../canvas/shootInterface")
var ammoLabel
var ammoIcon
var weaponIcons

#-- Модельки
onready var weaponModels = {
	"pistol_on": get_node("../Rotation_Helper/Camera/weapons/pistol"),
	"pistol_off": get_node("../player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag/pistol"),
	
	"shotgun_on": get_node("../player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag/shotgun"),
	
	"revolver_on": get_node("../Rotation_Helper/Camera/weapons/revolver"),
	"revolver_off": get_node("../player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag/revolver"),
	
	"sniper_on": get_node("../player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag/rifle"),
}

onready var weaponThirdModels = {
	"pistol_on": get_node("../player_body/Armature/Skeleton/BoneAttachment/weapons/pistol"),
	"revolver_on": get_node("../player_body/Armature/Skeleton/BoneAttachment/weapons/revolver"),
}

# -- Эффекты и анимация выстрела
var gunAnim
var gunLight
var gunFire
var gunSmoke
var gunParticlesPrefab = preload("res://objects/guns/gunParticles.tscn")
onready var particlesParent = get_node("../../")

var temp_shake = 0
var shake_up = false
var cooldown = 0.6
var change_weapon_cooldown = 0.0

#-- Звуки
onready var audi = get_node("../audi_guns")
onready var audiShoot = get_node("../audi_shoot")
var sounds = {
	"GunOn": preload("res://assets/audio/guns/GunOn.wav"),
	"GunOff": preload("res://assets/audio/guns/GunOff.wav"),
	"TryShoot": preload("res://assets/audio/guns/TryShoot.wav"),
	
	"pistol_shoot": preload("res://assets/audio/guns/PistolShoot.wav"),
	"shotgun_shoot": preload("res://assets/audio/guns/ShotgunShoot.wav"),
	"revolver_shoot": preload("res://assets/audio/guns/RevolverShoot.wav"),
	"sniper_shoot": preload("res://assets/audio/guns/SniperShoot.wav"),
}

#-- сирен
onready var enemiesManager = get_node("../../enemies")
onready var parent = get_parent()

var gunOn = false
var onetimeShoot = false
var onetimeVisible = false


func _loadGunEffects():
	var tempWeaponDict = weaponModels
	if parent.thirdView && temp_weapon + "_on" in weaponThirdModels:
		tempWeaponDict = weaponThirdModels
	gunAnim = tempWeaponDict[temp_weapon + "_on"].get_node("anim")
	gunLight = tempWeaponDict[temp_weapon + "_on"].get_node("light")
	gunFire = tempWeaponDict[temp_weapon + "_on"].get_node("fire")
	gunSmoke = tempWeaponDict[temp_weapon + "_on"].get_node("smoke")


func _isPistol():
	return temp_weapon == "pistol" || temp_weapon == "revolver"


func _setGunOn(new_gunOn: bool, collision_on = true):
	gunOn = new_gunOn
	if collision_on:
		collision.disabled = !new_gunOn
		collision.rotation_degrees = Vector3.ZERO
	else:
		collision.disabled = true
	shootInterface.visible = new_gunOn
	
	if gunOn:
		if _isPistol():
			G.player.body_follows_camera = false
		else:
			G.player.body_follows_camera = true
			shotgunArea.rotation_degrees.x = camera.rotation_degrees.x
	else:
		G.player.body_follows_camera = false


func _shakeCameraUp():
	var shaking_process = true
	while(shaking_process):
		if shake_up:
			if temp_shake < weaponStats[temp_weapon + "_recoil"]:
				temp_shake += SHAKE_SPEED
				camera.rotation_degrees.x += SHAKE_SPEED
			else:
				shake_up = false
		else:
			if temp_shake > 0:
				var diff = SHAKE_SPEED * SHAKE_DIFF
				temp_shake -= diff
				camera.rotation_degrees.x -= SHAKE_SPEED * SHAKE_DIFF
			else:
				shake_up = true
				shaking_process = false
		yield(get_tree(),"idle_frame")


func _checkVisible(victims):
	for victim in victims:
		var wr = weakref(victim)
		if wr.get_ref():
			var vict_pos = victim.global_transform.origin
			if victim is Character:
				vict_pos.y += 1
			var dir = vict_pos - rayShotgun.global_transform.origin
			rayShotgun.global_transform.basis = Basis(Vector3.ZERO)
			rayShotgun.set_cast_to(dir)
			yield(get_tree(),"idle_frame")
			if rayShotgun.get_collider() == victim:
				handleVictim(victim)
				if victim is Character:
					_spawnBlood(victim, G.player.impulse * -4, dir)
			else: #костыль, тк некоторые окна он почему-то не видит
				if !rayShotgun.is_colliding() && ("broken" in victim):
					handleVictim(victim)


func _spawnBlood(victim, impulse, dir):
	var gunParticles = gunParticlesPrefab.instance()
	particlesParent.add_child(gunParticles)
	gunParticles.global_transform.origin = rayShotgun.get_collision_point()
	gunParticles._startEmitting(rayShotgun.get_collision_normal(), "blood")
	
	dir = dir.normalized()
	dir.y = 0
	victim.impulse = impulse


func handleVictim(victim, shapeID = 0):
	var _name = null
	if victim is KinematicBody:
		
		if "target" in victim.name || "roboEye" in victim.name || "MrHandy" in victim.name:
			_name = "black"
		else:
			_name = "blood"
		
		if victim is Character:
			stats.MakeDamage(victim, weaponStats[temp_weapon + "_damage"], shapeID)
	elif victim.physics_material_override:
		var material = victim.physics_material_override as NamedPhysicsMaterial
		_name = material.name
		if _name == "glass" || "box" in victim.name:
			victim.brake(weaponStats[temp_weapon + "_damage"])
	return _name


func _activeGunOnModel(on):
	if parent.thirdView && temp_weapon + "_on" in weaponThirdModels:
		weaponThirdModels[temp_weapon + "_on"].visible = on
		collision.disabled = on
	else:
		weaponModels[temp_weapon + "_on"].visible = on
		if _isPistol():
			collision.disabled = !on
	if on:
		_loadGunEffects()


func checkThirdView(thirdOn):
	if gunOn && temp_weapon + "_on" in weaponThirdModels:
		weaponThirdModels[temp_weapon + "_on"].visible = thirdOn
		weaponModels[temp_weapon + "_on"].visible = !thirdOn
		collision.disabled = thirdOn
		_loadGunEffects()


func disactiveGunModel():
	_activeGunOnModel(false)
	if _isPistol():
		weaponModels[temp_weapon + "_off"].visible = false


func changeGun(number: int):
	#если у игрока до этого не было оружия
	var bar = get_node("../player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag")
	if !bar.is_visible():
		bar.set_visible(true)
	
	#вырубаем предыдущую модельку
	disactiveGunModel()
	
	temp_weapon = weapons[number]
	temp_weapon_num = number
	
	#врубаем новые модельки
	if _isPistol():
		weaponModels[temp_weapon + "_off"].visible = !gunOn
		_activeGunOnModel(gunOn)
		G.player.body_follows_camera = false
	else:
		_activeGunOnModel(true)
		_setGunOn(true, false)
	
	if temp_weapon == "shotgun":
		shotgunArea.monitoring = true
	else:
		shotgunArea.monitoring = false
	
	ammoLabel.text = str(weaponStats[temp_weapon + "_ammo"])
	ammoIcon.region_rect = Rect2(weaponStats[temp_weapon + "_icon"], 0, 40, 40)
	_loadGunEffects()
	audi.stream = sounds.GunOn
	audi.play()
	
	weaponIcons.changeWeapon(temp_weapon)


func enableHeadRay(distance): #используется также в Player во время телепортации
	var tempRay = rayHead
	if parent.thirdView:
		tempRay = rayThird
	tempRay.set_cast_to(Vector3(0,0,-distance))
	tempRay.enabled = true
	return tempRay


func _ready():
	label = askGet.get_node("label")
	ammoIcon = shootInterface.get_node("ammoBack/Sprite2")
	ammoLabel = shootInterface.get_node("ammoBack/label")
	ammoLabel.text = str(weaponStats[temp_weapon + "_ammo"])
	weaponIcons = shootInterface.get_node("gunIcons")
	_loadGunEffects()
	
	rayHead.add_exception(parent)
	rayShotgun.add_exception(parent)
	rayThird.add_exception(parent)
	camera_script = camera.get_node("Camera")
	#первый раз почему-то не срабатывает
	_shakeCameraUp()
	
	if parent.have_pistol:
		weaponStats["pistol_have"] = true
		get_node("../player_body/Armature/Skeleton/BoneAttachment 3/shotgunBag").visible = true
		weaponModels["pistol_off"].visible = true
	
	if parent.check_clone_flask:
		collision.disabled = true


func _process(delta):
	if !G.paused && parent.stats.Health > 0:
		#---обработка стрельбы---
		if gunOn:
			if _isPistol(): #вращаем коллизию пистолета вместе с пистолетом
				collision.rotation_degrees = camera.rotation_degrees
			else: #иначе вращаем область дробовика за камерой
				shotgunArea.rotation_degrees.x = camera.rotation_degrees.x
			if Input.is_mouse_button_pressed(1) && cooldown <= 0:
				if !onetimeShoot:
					onetimeShoot = true
					if weaponStats[temp_weapon + "_ammo"] == 0:
						audiShoot.stream = sounds.TryShoot
						audiShoot.play()
					else:
						weaponStats[temp_weapon + "_ammo"] -= 1
						ammoLabel.text = str(weaponStats[temp_weapon + "_ammo"])
						cooldown = weaponStats[temp_weapon + "_cooldown"]
						audiShoot.stream = sounds[temp_weapon + "_shoot"]
						audiShoot.play()
						if gunAnim:
							gunAnim.play("shoot")
						
						head.closeEyes()
						var temp_distance = weaponStats[temp_weapon + "_distance"]
						if G.player.equipment.have_bandage:
							temp_distance += 15
						var tempRay = enableHeadRay(temp_distance)
						
						yield(get_tree(),"idle_frame")
						
						#обрабатываем попадания
						if _isPistol() || G.player.mayMove:
							if temp_weapon == "shotgun": #отдача назад с дробовика
								G.player.impulse = camera.global_transform.basis.z / 2
								var objs = shotgunArea.enemies_inside
								_checkVisible(objs)
							else:
								var obj = tempRay.get_collider()
								if obj != null:
									var gunParticles = gunParticlesPrefab.instance()
									particlesParent.add_child(gunParticles)
									gunParticles.global_transform.origin = tempRay.get_collision_point()
									var shapeID = tempRay.get_collider_shape()
									var _name = handleVictim(obj, shapeID)
									gunParticles._startEmitting(tempRay.get_collision_normal(), _name, obj.name)
						
						yield(get_tree().create_timer(0.1),"timeout")
						if temp_weapon == "shotgun": #отдача назад с дробовика
							G.player.impulse = camera.global_transform.basis.z / 2
						gunLight.visible = true
						gunSmoke.restart()
						gunFire.visible = true
						_shakeCameraUp()
						yield(get_tree().create_timer(0.05),"timeout")
						gunFire.visible = false
						yield(get_tree().create_timer(0.1),"timeout")
						gunLight.visible = false
						
						tempRay.enabled = false
						
						if temp_weapon != "pistol" && enemiesManager:
							if enemiesManager.alarm_timer <= 0:
								enemiesManager.startAlarm()
			else:
				onetimeShoot = false
		
		#---обработка доставания оружия--
		if weaponStats[temp_weapon+"_have"]:
			if temp_weapon == "pistol" || temp_weapon == "revolver":
				if body.body_rot > 80 && body.body_rot < 130 && camera.rotation_degrees.x < -40:
					var actions = InputMap.get_action_list("getGun")
					var key = OS.get_scancode_string(actions[0].get_scancode())
					
					if gunOn:
						if G.english:
							label.text = key + " - put gun in"
						else:
							label.text = key + " - сложить оружие"
					else:
						if G.english:
							label.text = key + " - take gun"
						else:
							label.text = key + " - взять оружие"
					askGet.visible = true
					onetimeVisible = true
					if Input.is_action_just_pressed("getGun"):
						_setGunOn(!gunOn)
						
						_activeGunOnModel(gunOn)
						weaponModels[temp_weapon + "_off"].visible = !gunOn
						
						if !gunOn:
							audi.stream = sounds.GunOff
						else:
							audi.stream = sounds.GunOn
						audi.play()
				elif onetimeVisible:
					askGet.visible = false
					onetimeVisible = false
			
		
		if cooldown > 0:
			cooldown -= delta
		
		#--обработка смены оружия
		if Input.is_key_pressed(49): #1key - pistol
			if temp_weapon_num != 0 && weaponStats["pistol_have"]:
				changeGun(0)
		if Input.is_key_pressed(50): #2key - shotgun
			if temp_weapon_num != 1 && weaponStats["shotgun_have"]:
				changeGun(1)
		if Input.is_key_pressed(51): #3key - revolver
			if temp_weapon_num != 2 && weaponStats["revolver_have"]:
				changeGun(2)
		if Input.is_key_pressed(52): #4key - sniper
			if temp_weapon_num != 3 && weaponStats["sniper_have"]:
				changeGun(3)
		
		if change_weapon_cooldown > 0:
			change_weapon_cooldown -= delta


func _incrementValue(value, valueMax):
	if value < valueMax - 1:
		value += 1
	else:
		value = 0
	return value


func _decrementValue(value, valueMax):
	if value > 0:
		value -= 1
	else:
		value = valueMax - 1
	return value


func _tryToChangeGun(num):
	var new_weapon = weapons[num]
	if weaponStats[new_weapon + "_have"]:
		changeGun(num)
		change_weapon_cooldown = 0.5
		return true
	return false
