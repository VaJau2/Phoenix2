extends Spatial

#как только игрок попадает в нужную зону
#идет в нужную сторону и прыгает
#скрипт вырубает его коллизию
#перемещает его на global_transform.origin
#а затем на нужный climb (In или Out)

onready var jumpHint = get_node("/root/Main/canvas/jumpHint")

export var windowPath: NodePath
var window
var playerIn
var playerOut

var checkOutPos
var checkInPos


func _on_climbIn_body_entered(body):
	if body.name == "Player" && body.collision_layer == 1:
		playerIn = true
		playerOut = false


func _on_climbIn_body_exited(body):
	if body.name == "Player" && body.collision_layer == 1:
		playerIn = false
		jumpHint.visible = false


func _on_climbOut_body_entered(body):
	if body.name == "Player" && body.collision_layer == 1:
		playerOut = true
		playerIn = false


func _on_climbOut_body_exited(body):
	if body.name == "Player" && body.collision_layer == 1:
		playerOut = false
		jumpHint.visible = false


func _movePlayer(place):
	var player_pos = G.player.global_transform.origin
	var dir = (place - player_pos).normalized()
	G.player.move_and_collide(dir / 2)
	G.player.flying = false
	var temp_dist = place.distance_to(player_pos)
	return temp_dist


func _jump(out):
	G.player.mayMove = false
	var player_pos = G.player.global_transform.origin
	var temp_dist = global_transform.origin.distance_to(player_pos)
	G.player.set_collision_layer(0)
	G.player.set_collision_mask(0)
	while(temp_dist > 1):
		temp_dist = _movePlayer(global_transform.origin)
		yield(get_tree(),"idle_frame")
	player_pos = G.player.global_transform.origin
	
	if out:
		temp_dist = checkOutPos.distance_to(player_pos)
		while(temp_dist > 1):
			temp_dist = _movePlayer(checkOutPos)
			yield(get_tree(),"idle_frame")
	
	else:
		temp_dist = checkInPos.distance_to(player_pos)
		while(temp_dist > 1):
			temp_dist = _movePlayer(checkInPos)
			yield(get_tree(),"idle_frame")
	
	playerOut = false
	playerIn = false
	jumpHint.visible = false
	G.player.set_collision_layer(1)
	G.player.set_collision_mask(1)
	G.player.mayMove = true


func _windowDeleted():
	var wr = weakref(window)
	if !wr.get_ref():
		return true
	if !window.get_node("window").visible:
		return true
	return false


func _checkKey():
	var actions = InputMap.get_action_list("jump")
	var key = OS.get_scancode_string(actions[0].get_scancode())
	
	jumpHint.get_node("label").text = key + " - перепрыгнуть"


func _ready():
	window = get_node(windowPath)
	checkOutPos = get_node("climbOut").global_transform.origin
	checkInPos = get_node("climbIn").global_transform.origin


func _process(delta):
	if playerIn:
		if _windowDeleted():
			_checkKey()
			jumpHint.visible = true
			if Input.is_action_just_pressed("jump"):
				_jump(true)
	if playerOut:
		if _windowDeleted():
			_checkKey()
			jumpHint.visible = true
			if Input.is_action_just_pressed("jump"):
				_jump(false)

