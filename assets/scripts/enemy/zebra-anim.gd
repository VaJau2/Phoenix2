extends KinematicBody

export(String) var anim_name = "Idle1"

func _ready():
	var anim = $anim
	anim.play(anim_name)
