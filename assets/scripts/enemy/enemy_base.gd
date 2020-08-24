extends KinematicBody

#Базовый скрипт для неписей
class_name Enemy

const COME_DIST = 1.6
var GRAVITY = 6

export var Health: int
export var Damage: int
export var hitDistance: int
export var cooldown: float
export var Speed: int

var active = true

var vel = Vector3(0,0,0)
var impulse = Vector3(0,0,0)
var rotation_speed = 0.45
var temp_cooldown = 0.0
var close_to_point = false

onready var anim = get_node("anim")
onready var audi = get_node("audi2")

var scores #очки есть у зебр

#передвигаемся к точке
func moveTo(place:Vector3, distance: float, speed = Speed):
	var pos = global_transform.origin
	place.y = pos.y #чтоб непись не вращался вверх-вниз
	
	var a = Quat(transform.basis)
	var b = Quat(transform.looking_at(place, Vector3.UP).basis)
	var temp_rotation = a.slerp(b, rotation_speed)
	transform.basis = Basis(temp_rotation)
	
	rotation.x = 0
	rotation.z = 0
	vel = Vector3(0,-GRAVITY,-speed).rotated(Vector3.UP, rotation.y)
	
	var point_distance = pos.distance_to(place)
	close_to_point = point_distance <= distance


func MakeDamage(temp_damage):
	if temp_damage > 0 && G.player.stats.Health > 0:
		var player_z = -G.player.global_transform.basis.z
		var angle_front = player_z.angle_to(global_transform.basis.z)
		var angle_side = player_z.dot(global_transform.basis.z)
		var angles = Vector2(angle_front,angle_side)
		
		G.player.stats.TakeDamage(temp_damage, angles)


func TakeDamage(damage: int, shapeID = 0):
	if Health > damage:
		Health -= damage
	else:
		Health = 0


func handleImpulse():
	if impulse.length() > 0:
		vel = impulse
		impulse.x /= 1.5
		impulse.y = 0
		impulse.z /= 1.5
		return true
	return false


func _process(delta):
	if vel.length() > 0:
		move_and_slide(vel)
