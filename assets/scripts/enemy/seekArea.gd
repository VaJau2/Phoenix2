extends Area

const SEE_TIMER = 2 #время, через которое непись перейдет в режим атаки
const LIGHT_MULTIPLY = 4 #модификатор изменения, если игрок на свету
const CROUCH_MULTIPLY = 0.5 #модификатор изменения, если игрок крадется
const WALK_MULTIPLY = 4 #модификатор изменения, если игрок не стоит на месте

onready var my_script = get_parent()
onready var raycast = get_node("playerRay")
var see_obj = null

var temp_player = null
var seeTimer = SEE_TIMER

func _losePlayer(delta):
	if G.player.stats.Health > 0 && temp_player:
		my_script.set_state("seek")
		my_script.player_last_pos = temp_player.global_transform.origin
		
		if seeTimer < SEE_TIMER:
			seeTimer += delta
	else:
		my_script.set_state("idle")
		seeTimer = 0


func _on_seekArea_body_entered(body):
	if body.name == "Player":
		temp_player = body
	elif "zebra" in body.name || "trader" in body.name:
		if "collared" in my_script:
			return
		if !("trader" in body.name) || my_script.other_zebras.size() == 0:
			my_script.other_zebras.append(body)

		if my_script.state == 1: #заставляем других зебр атаковать вместе с нам
			if my_script.get_parent().attacking_count < 3:
				body.set_state("attack")


func _on_seekArea_body_exited(body):
	if body.name == "Player":
		_losePlayer(0.1)
		temp_player = null
	elif "zebra" in body.name || "trader" in body.name:
		if "collared" in my_script:
			return
		
		if body in my_script.other_zebras:
			my_script.other_zebras.erase(body)


func _ready():
	raycast.add_exception(my_script)


func _process(delta):
	if my_script.Health > 0:
		if temp_player && G.player.stats.Health > 0:
			raycast.rotation_degrees.y = -my_script.rotation_degrees.y
			var dir = temp_player.global_transform.origin - raycast.global_transform.origin
			raycast.set_cast_to(dir)
			see_obj = raycast.get_collider()
			if see_obj && see_obj == G.player && G.player.stats.Health > 0 && (G.player.mayMove || G.player.hitting):
				if my_script.state != 1:
					if seeTimer > 0:
						var temp_dist = raycast.global_transform.origin.distance_to(temp_player.global_transform.origin)
						if temp_dist < 5:
							seeTimer = 0
						else:
							var speed = delta
							if temp_player.get_node("lightsCheck").on_light:
								speed *= LIGHT_MULTIPLY
							if temp_player.crouching:
								speed *= CROUCH_MULTIPLY
							if temp_player.vel.length() > 7:
								speed *= WALK_MULTIPLY
							seeTimer -= speed
					else:
						my_script.set_state("attack")
			else:
				if my_script.state == 1:
					_losePlayer(delta)
		else:
			if my_script.state != 0 && G.player.stats.Health <= 0:
				_losePlayer(delta)
		
		raycast.enabled = temp_player != null
	else:
		raycast.enabled = false
		see_obj = null
		if !"roboEye" in my_script.name:
			queue_free()
