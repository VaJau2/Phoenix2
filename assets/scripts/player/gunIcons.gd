extends Control

onready var icons = {
	"pistol": get_node("pistol"),
	"shotgun": get_node("shotgun"),
	"revolver": get_node("revolver"),
	"sniper": get_node("sniper"),
}

var show_timer = 0

func changeWeapon(new_weapon):
	var weapons = G.player.weapons.weaponStats
	for icon_name in icons.keys():
		if weapons[icon_name+"_have"]:
			icons[icon_name].visible = true
			icons[icon_name].modulate = Color.white
		else:
			icons[icon_name].visible = false
	icons[new_weapon].modulate = Color.yellow
	show_timer += 2


func _process(delta):
	if show_timer > 0:
		show_timer -= delta
		if rect_position.y < 0:
			rect_position.y += delta * 120
	else:
		if rect_position.y > -36:
			rect_position.y -= delta * 120
