extends Spatial

onready var third_camera = get_node("CameraThird")
onready var first_camera = get_node("../Rotation_Helper/Camera")
onready var parent = get_parent()

onready var eyeParts = get_node("/root/Main/canvas/eyesParts")

var third = Vector3(2.5, 0.4, 4.2)
var thirdMin = Vector3(1.75, 0.35, 3.5)
var thirdMax = Vector3(2.75, 0.45, 5.2)
var tempThird = Vector3(2.5, 0.4, 4.2)

var ray
var seePlayer = true
var oldThird

var mayChange = true


func _setThirdView(on):
	first_camera.current = !on
	first_camera.fov_closing = false
	third_camera.current = on
	parent.thirdView = on
	ray.enabled = on
	parent.weapons.checkThirdView(on)
	eyeParts.visible = !on


func _updateSide(delta, side, key_up, key_down, max_value, min_value, usual_value):
	if Input.is_action_pressed(key_up):
		if side < max_value:
			side += delta * 1.5
	elif Input.is_action_pressed(key_down):
		if side > min_value:
			side -= delta * 1.5
	else:
		if side > usual_value + 0.04:
			side -= delta * 1.5
		elif side < usual_value - 0.04:
			side += delta * 1.5
		else:
			side = usual_value
	return side


func _updateThirdCameraPos(delta):
	tempThird.x = _updateSide(delta, tempThird.x, "ui_left", "ui_right", third.x + 0.7, third.x - 0.7, third.x)
	tempThird.z = _updateSide(delta, tempThird.z, "ui_up", "ui_down", third.z + 0.5, third.z - 0.5, third.z)
	if parent.flying:
		tempThird.y = _updateSide(delta, tempThird.y, "jump", "ui_shift", third.y + 0.7, third.y - 0.7, third.y)
	else:
		tempThird.y = third.y
	
	third_camera.translation = tempThird


func _checkCameraSee():
	ray.enabled = true
	var dir = parent.global_transform.origin - ray.global_transform.origin
	ray.set_cast_to(dir)
	ray.global_transform.basis = Basis(Vector3.ZERO)
	if ray.is_colliding():
		if ray.get_collider().name == "Player":
			seePlayer = true
		else:
			oldThird = third
			seePlayer = false


func _closeCamera():
	if third.x > thirdMin.x:
		third.x -= 0.05
	if third.y > thirdMin.y:
		third.y -= 0.01
	if third.z > thirdMin.z:
		third.z -= 0.1
	
	if third.x <= thirdMin.x && third.y <= thirdMin.y && third.z <= thirdMin.z:
		if parent.thirdView:
			_setThirdView(false)


func _farCamera():
	if !parent.thirdView:
		_setThirdView(true)
		third = thirdMin
		tempThird = third
	
	if third.x < thirdMax.x:
		third.x += 0.05
	if third.y < thirdMax.y:
		third.y += 0.01
	if third.z < thirdMax.z:
		third.z += 0.1


func _ready():
	ray = third_camera.get_node("RayCast")


func _process(delta):
	if mayChange && Input.is_action_just_pressed("changeView"):
		if oldThird:
			oldThird = null
		else:
			_setThirdView(!parent.thirdView)
	
	if parent.thirdView:
		_updateThirdCameraPos(delta)
		_checkCameraSee()
		
		if !seePlayer:
			_closeCamera()
		elif oldThird != null:
			if oldThird.x > third.x:
				_farCamera()
			else:
				oldThird = null
	else:
		if oldThird:
			_checkCameraSee()
			if seePlayer:
				_farCamera()
				oldThird = null


func _input(event):
	if mayChange && event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_closeCamera()
				oldThird = null
			if event.button_index == BUTTON_WHEEL_DOWN:
				_farCamera()
