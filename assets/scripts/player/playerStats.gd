extends Node

#скрипт управляет принятием и нанесением урона
#а также эффектами при принятии урона (покачивание камеры в противоположную от врага сторону)
#и маной для единорогов

const RED_SPEED = 0.05
const DASH_BLOCK = 0.6

export var Health = 150
var HealthMax = 150

var mana = 100.0
var manaMax = 100.0

const MANA_SPEED = 20
const TELEPORT_COST = 50
const TELEPORT_DISTANCE = 150
const SHIELD_COST = 21

var dash_block = false

onready var manaBar = get_node("/root/Main/canvas/manaBar")
onready var redScreen = get_node("/root/Main/canvas/redScreen")
onready var black_screen = get_node("/root/Main/canvas/black")
onready var dealthScreen = get_node("/root/Main/canvas/DealthMenu")
onready var camera = get_node("../Rotation_Helper")
onready var head = get_node("../player_body/Armature/Skeleton/Head")
onready var cross = get_node("/root/Main/canvas/shootInterface/cross")
onready var shieldMesh = get_node("../shield/first")
onready var parent = get_parent()

var my_keys = []

var headless = false

var effecting = false

func dashBlock():
	dash_block = true
	yield(get_tree().create_timer(0.6), "timeout")
	dash_block = false


func _set_side(angles):
	var angle_front = rad2deg(angles.x)
		#< 130 - игрок смотрит на зебру
		#> 55 - игрок смотрит не на зебру
	var angle_side = angles.y
		#от 0 до 0.5 - игрок смотрит налево
		#от -0.5 до 0 - игрок смотрит направо
	
	var side = Vector2(0,0)
	if angle_front > 130:
		side.x = -1
	elif angle_front < 55:
		side.x = 1
	
	if angle_side > -0.5 && angle_side < 0:
		side.y = 1
	elif angle_side < 0.5 && angle_side > 0:
		side.y = -1
	
	return side


func _hitEffects(angles):
	head.closeEyes()
	var dir = _set_side(angles)
	if effecting:
		return
	effecting = true
	
	while(redScreen.modulate.a < 1):
		camera.rotation_degrees.x += dir.x * 0.8
		camera.rotation_degrees.z += dir.y * 0.8
		
		redScreen.modulate.a += RED_SPEED * 4
		yield(get_tree(),"idle_frame")

	while(redScreen.modulate.a > 0):
		camera.rotation_degrees.x -= dir.x * 0.4
		camera.rotation_degrees.z -= dir.y * 0.4
		
		redScreen.modulate.a -= RED_SPEED * 2
		yield(get_tree(),"idle_frame")
	
	effecting = false


func MakeDamage(victim, damage, shapeID = 0):
	if victim.Health > 0:
		victim.TakeDamage(damage, shapeID)
		cross.setRed()


func TakeDamage(damage, angle):
	if Health > 0 && parent.mayMove:
		_hitEffects(angle)
		
		if parent.equipment.have_armor:
			damage = damage * 0.7
		
		if dash_block:
			damage = damage * 0.6
		
		if shieldMesh.visible:
			var decrease = round((((mana+5) / manaMax) * damage))
			damage = damage - decrease
			mana = mana - decrease
			if mana < 0:
				mana = 0
			if damage < 0:
				damage = 0
		
		if Health > damage:
			Health -= int(damage)
		else:
			parent.mayMove = false
			Health = 0
			black_screen.visible = true
			if parent.check_clone_flask:
				yield(get_tree().create_timer(2),"timeout")
				get_node("/root/Main/props/bunker/laboratory/flasks").checkNewFlask()


func _process(delta):
	if Health > 0:
		if G.race == 1: #если ГГ единорог
			if mana < manaMax:
				mana += delta * MANA_SPEED
				manaBar.set_visible(true)
				manaBar.value = mana
			else:
				if manaBar.is_visible():
					manaBar.set_visible(false)
	else:
		if black_screen.color.a < 1:
			black_screen.color.a += delta * 1.5
		else:
			if !parent.check_clone_flask:
				G.game_over = true
				dealthScreen.visible = true
				dealthScreen._update_down_label()
				G.setPause(self, true)
