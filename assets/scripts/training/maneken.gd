extends StaticBody

export var changeSound: AudioStream
export var cost: int

export var equpName = ""
export var equpNameEng = ""
export var equipNameTerminal = ""
var haveEquip = true

var maneken_material

onready var manager = get_parent()


func _ready():
	maneken_material = $Body.get_surface_material(0)


func changeEquip():
	var reserved = true
	if haveEquip:
		reserved = manager.addReservedEqip(self)
	else:
		manager.removeReservedEqip(self)
	if reserved:
		haveEquip = !haveEquip
		G.player.audi_hitted.stream = changeSound
		G.player.audi_hitted.play()
		match equpName:
			"бронежилет":
				$armor.visible = haveEquip
				G.player.get_node("player_body/Armature/Skeleton/armor").visible = !haveEquip
				G.player.equipment.have_armor = !haveEquip
			
			"стелс-носки":
				var playerBodyMesh = G.player.get_node("player_body/Armature/Skeleton/Body")
				if haveEquip:
					$Body.set_surface_material(0, maneken_material)
					playerBodyMesh.set_surface_material(0, G.player.not_socks_material)
					G.player.audi.set_unit_size(1)
				else:
					$Body.set_surface_material(0, null)
					playerBodyMesh.set_surface_material(0, G.player.socks_material)
					G.player.audi.set_unit_size(0.15)
				G.player.equipment.have_socks = !haveEquip
			
			"повязку":
				$bandage.visible = haveEquip
				G.player.get_node("player_body/Armature/Skeleton/BoneAttachment/bandage").visible = !haveEquip
				G.player.equipment.have_bandage = !haveEquip
			
			"бандану":
				$headrope.visible = haveEquip
				G.player.get_node("player_body/Armature/Skeleton/BoneAttachment/headrope").visible = !haveEquip
				G.player.equipment.have_headrope = !haveEquip
		return 0
	return 0.5
