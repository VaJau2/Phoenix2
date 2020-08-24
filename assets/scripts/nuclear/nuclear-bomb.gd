extends Spatial

var explosion_sounds = [
	preload("res://assets/audio/background/nuclear/nuclear_explosion.wav"),
	preload("res://assets/audio/background/nuclear/nuclear_explosion1.wav"),
	preload("res://assets/audio/background/nuclear/nuclear_explosion2.wav"),
]

export var timer: float
var exploding = false

onready var rocket = get_node("rocket")
var rocketCame = false
var speedY = 0

func _updateRocket():
	var rocket_temp_place = rocket.global_transform.origin
	rocket_temp_place.y = global_transform.origin.y
	var dist2D = rocket_temp_place.distance_to(global_transform.origin)
	if dist2D > 310:
		rocket.translation.x -= 0.6
	elif dist2D > 4:
		if speedY < 0.21:
			speedY += 0.004
			
		rocket.translation.x -= (0.6 - speedY)
		rocket.translation.y -= speedY
		rocket.rotation_degrees.x = speedY * -150
	else:
		rocket.queue_free()
		rocketCame = true


func explode():
	yield(get_tree().create_timer(timer),"timeout")
	exploding = true
	rocket.visible = true
	rocket.get_node("audi").play()


func _process(delta):
	if exploding:
		if !rocketCame:
			_updateRocket()
		else:
			$light.visible = true
			$sprite.visible = true
			$anim.play("fire")
			$audi.stream = explosion_sounds[randi() % explosion_sounds.size()]
			$audi.play()
			exploding = false
