extends Control

signal delte_tag
var index = -1
var indexP = -1


func _ready():
	var a = StyleBoxFlat.new()
	var b = StyleBoxFlat.new()
	a.set_bg_color(Color(1.0, 1.0, 1.0))
	a.set_border_width_all(3)
	a.set_corner_radius_all(8)
	b.set_bg_color(Color(0.870588, 0.929412, 0.933333))
	b.set_border_width_all(3)
	b.set_corner_radius_all(8)
	if index[0].is_valid_integer():
		index = index.lstrip("0123456789-.")
	
	if index.begins_with("L"):
		a.set_border_color(Color(0, 0.435294, 0.47451))
		b.set_border_color(Color(0, 0.435294, 0.47451))
		$Button.set("custom_styles/normal", a)
		$Button.set("custom_styles/hover", b)
	if index.begins_with("A"):
		a.set_border_color(Color(0.137255, 0.215686, 0.27451))
		b.set_border_color(Color(0.137255, 0.215686, 0.27451))
		$Button.set("custom_styles/normal", a)
		$Button.set("custom_styles/hover", b)
	if index.begins_with("D"):
		a.set_border_color(Color(1, 0.070588, 0.203922))
		b.set_border_color(Color(1, 0.070588, 0.203922))
		$Button.set("custom_styles/normal", a)
		$Button.set("custom_styles/hover", b)
	if index.begins_with("R"):
		#a.set_bg_color(Color(0.556863, 0.529412, 0.113725))
		a.set_border_color(Color(0.984314, 0.792157, 0.211765))
		b.set_border_color(Color(0.984314, 0.792157, 0.211765))
		$Button.set("custom_styles/normal", a)
		$Button.set("custom_styles/hover", b)
	if index.begins_with("B"):
		#a.set_bg_color(Color(1.0, 1.0, 1.0))
		a.set_border_color(Color(0.529412, 0.572549, 0.603922))
		b.set_border_color(Color(0.529412, 0.572549, 0.603922))
		$Button.set("custom_styles/normal", a)
		$Button.set("custom_styles/hover", b)


func _on_Delete_pressed():
	emit_signal("delte_tag", indexP)


func _on_STID_pressed():
	OS.shell_open("https://stid.equinor.com/JSV/tag/" + str(index))


func _on_Echo_pressed():
	var plant
	if index.begins_with("L"):
		plant = "JSL"
	if index.begins_with("A"):
		plant = "JSA"
	elif index.begins_with("D"):
		plant = "JSD"
	elif index.begins_with("R"):
		plant = "JSR"
	else:
		plant = "JSB"
	OS.shell_open("echo://tag/?tag=" + str(index) + "&plant=" + str(plant))


func _on_Button_pressed():
	#rect_min_size.y = 60
	get_parent().queue_sort()


func _on_SAP_pressed():
	var plant
	if index.begins_with("L"):
		plant = "1900-"
	if index.begins_with("A"):
		plant = "1901-"
	elif index.begins_with("D"):
		plant = "1902-"
	elif index.begins_with("R"):
		plant = "1903-"
	else:
		plant = "1904-"
	OS.shell_open("https://p03web.statoil.no/sap/bc/webdynpro/sap/zompm_lookup_eq_info?run=x&tplnr=" + plant + str(index))


func _on_Hub_pressed():
	OS.shell_open("https://echo.equinor.com/tags?instCode=JSV&tagNo=" + str(index))
