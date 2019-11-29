extends Control

var words = 0
var charcnt = 0
var lq = 0
var p1 = 0
var dp = 0
var rp = 0
var tot = 0
var textList
var TAG = []
var TAGL = []
var TAGA = []
var TAGD = []
var TAGR = []


func _ready():
	search()


func search():
	words = 0
	charcnt = 0
	var message = OS.get_clipboard()
	var textList = message.split('\n')
	var jointList = textList.join(' ')
	textList = jointList.split(' ')
	
	for i in range(len(textList)):
		words += 1
		charcnt += len(textList[i])
		is_tag(textList[i])

	$Label.text = 'Søkte gjennom ' + str(words) + ' ord og ' + str(charcnt) + ' tegn'
	$TAG.text = 'Fant følgende TAG: \n LQ: ' + str(lq) + '\n P1: ' + str(p1) + '\n DP: ' + str(dp) + '\n RP: ' + str(rp) + '\n Total: ' + str(tot)


func is_tag(text):
	if len(text) < 9:
		return false
	for x in range(0, 3):
		if not text[x].is_valid_integer():
			return false
	if text[4] != '-':
		return false
	if not text[5].is_valid_identifier():
		return false
	if text[6] != '-':
		return false
	if $Prefix.pressed:
		text = text.lstrip('123456790-')
		if $Onefile.pressed:
			if text.begins_with('L') and not TAGL.has(text):
				TAGL.append(text)
				lq += 1
			if text.begins_with('A') and not TAGA.has(text):
				TAGA.append(text)
				p1 += 1
			if text.begins_with('D') and not TAGD.has(text):
				TAGD.append(text)
				dp += 1
			if text.begins_with('R') and not TAGR.has(text):
				TAGR.append(text)
				rp += 1
		else:
			if text.begins_with('L') and not TAG.has(text):
				lq += 1
				TAG.append(text)
				print(text)
			if text.begins_with('A') and not TAG.has(text):
				p1 += 1
				TAG.append(text)
				print(text)
			if text.begins_with('D') and not TAG.has(text):
				dp += 1
				TAG.append(text)
				print(text)
			if text.begins_with('R') and not TAG.has(text):
				rp += 1
				TAG.append(text)
				print(text)
	else:
		if $Onefile.pressed:
			if text[5] == 'L' and not TAGL.has(text):
				TAGL.append(text)
				lq += 1
			if text[5] == 'A' and not TAGA.has(text):
				TAGA.append(text)
				p1 += 1
			if text[5] == 'D' and not TAGD.has(text):
				TAGD.append(text)
				dp += 1
			if text[5] == 'R' and not TAGR.has(text):
				TAGR.append(text)
				rp += 1
		else:
			if text[5] == 'L' and not TAG.has(text):
				lq += 1
				TAG.append(text)
			if text[5] == 'A' and not TAG.has(text):
				p1 += 1
				TAG.append(text)
			if text[5] == 'D' and not TAG.has(text):
				dp += 1
				TAG.append(text)
			if text[5] == 'R' and not TAG.has(text):
				rp += 1
				TAG.append(text)
	tot = lq + p1 + dp + rp
	return true


func save(text, id):
	if len(text) > 0:
		var tag = PoolStringArray(text)
		var tagsort = tag.join('\n')
		var save = File.new()
		save.open('C:\\Appl\\tagListe' + id + '.txt', File.WRITE)
		save.store_line(tagsort)
		save.close()


# Knapp for generering av lister
func _on_Button_pressed():
	save(TAGL, 'JSL')
	save(TAGA, 'JSA')
	save(TAGD, 'JSD')
	save(TAGR, 'JSR')
	save(TAG, 'JSF')
	$Label.text = 'Lister opprettet i C:\\APPL'
	if $Taghub.pressed:
		OS.shell_open('https://taghub.equinor.com/')


# Knapp for last på nytt
func _on_Reload_pressed():
	TAGL = []
	TAGA = []
	TAGD = []
	TAGR = []
	TAG = []
	lq = 0
	p1 = 0
	dp = 0
	rp = 0
	tot = 0
	search()


func new_dir(path):
	var dir = Directory.new()