extends Area

onready var dragon = get_parent()
var eatSound = preload("res://assets/audio/enemies/dragon/dragon-eat.wav")

func _on_smasharea_body_entered(body):
	if dragon.attacking && dragon.Health > 0:
		if body.name == "Player":
			G.player.mayMove = false
			G.player.flying = false
			G.player.flying_fast = false
			G.player.body.playback.travel("Fly")
			G.player.set_collision_layer(0)
			G.player.set_collision_mask(0)
			G.player.stats.TakeDamage(35, Vector2(0,0))
			G.player.global_transform.origin = dragon.mouthPos.global_transform.origin
			
			dragon.player_in_mouth_timer = 3
			dragon.player_in_mouth = true
			dragon.fire_close = false
			dragon.attacking = false
			dragon.audi.stream = eatSound
			dragon.audi.play()
		elif body.name != "terrain":
			dragon.attacking = false
