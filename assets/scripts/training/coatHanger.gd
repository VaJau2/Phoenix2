extends Spatial

var coat_change = preload("res://assets/audio/item/coatChange.wav")

var have_coat = false


func changeCoat():
	have_coat = !have_coat
	G.player.have_coat = !have_coat
	G.player.get_node("player_body/Armature/Skeleton/BoneAttachment/hat").visible = !have_coat
	G.player.get_node("player_body/Armature/Skeleton/coat").visible = !have_coat
	get_node("coat").visible = have_coat
	get_node("hat").visible = have_coat
	G.player.audi_hitted.stream = coat_change
	G.player.audi_hitted.play()
