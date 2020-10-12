extends Node

class_name WordFilter


static func parse_text(text):
	if G.filter:
		var json_file = File.new()
		var lang = ""
		if G.english:
			lang = "_en"
		json_file.open("res://assets/dialogues/json/filter/filter" + lang + ".json", File.READ)
		var json_data = json_file.get_as_text()
		json_file.close()
		json_data = parse_json(json_data)
		
		for keyword in json_data.keys():
			text = text.replacen(keyword, json_data[keyword])
	
	return text
