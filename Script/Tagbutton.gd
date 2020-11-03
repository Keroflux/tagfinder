extends Control

signal delte_tag
signal open_stid
signal open_echo
var index = -1
var indexP = -1


func _ready():
	var a = StyleBoxFlat.new()
	if index[0].is_valid_integer():
		index = index.lstrip("0123456789-.")
	
	if index.begins_with("L"):
		a.set_bg_color(Color(0.098039, 0.447059, 0.298039))
		$Button.set("custom_styles/normal", a)
	if index.begins_with("A"):
		a.set_bg_color(Color(0.098039, 0.364706, 0.447059))
		$Button.set("custom_styles/normal", a)
	if index.begins_with("D"):
		a.set_bg_color(Color(0.807843, 0.235294, 0.235294))
		$Button.set("custom_styles/normal", a)
	if index.begins_with("R"):
		a.set_bg_color(Color(0.556863, 0.529412, 0.113725))
		$Button.set("custom_styles/normal", a)


func _on_Delete_pressed():
	emit_signal("delte_tag", indexP)


func _on_STID_pressed():
	emit_signal("open_stid", index)


func _on_Echo_pressed():
	emit_signal("open_echo", index)
