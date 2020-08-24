extends RayCast

#скрипт открывает двери, если те попадают в луч
var tempDoor = null
var timer = 0

onready var parent = get_parent()

func _process(delta):
	if parent.Health <= 0:
		set_process(false)
		return
	
	if is_colliding():
		var obj = get_collider()
		if "door" in obj.name && "open" in obj:
			tempDoor = obj
			if !tempDoor.open:
				tempDoor.clickFurn("key_all")
				timer = 2
				if "door_wait" in get_parent():
					get_parent().door_wait = tempDoor.open_timer
	
	if timer > 0:
		timer -= delta
	else:
		if tempDoor:
			if tempDoor.open:
				tempDoor.clickFurn("key_all")
			tempDoor = null
