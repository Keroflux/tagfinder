extends Control

var dir = OS.get_system_dir(2) # Får adressen til dokumenter. Brukes til lagring

var TAG =  []   # Liste for alle tagnummer
var TAGL = []   # Liste for LQ tagnummer
var TAGA = []   # Liste for P1 tagnummer
var TAGD = []   # Liste for DP tagnummer
var TAGR = []   # Liste for RP tagnummer

var TAGlabel = preload("res://Tagbutton.tscn") # Label som viser funnede tag i scrollboxen


func _ready():
	search() # Kjører et søk ved oppstart av programmet


# Søker gjennom teksten fra utklippstaveln. Deler den opp i ord som sendes
# ett og ett til is_tag funksjonen
func search():
	var words = 0
	var charcnt = 0
	var message = OS.get_clipboard() # Får teksten fra clipboardet til PCen
	var textList = message.split('\n')
	var jointList = textList.join(' ')
	textList = jointList.split(' ')
	
	for i in range(len(textList)):
		words += 1
		charcnt += len(textList[i])
		is_tag(textList[i])
	
	separate_tag()
	count_tag()
	fill_scrollbox()
	$MC/VBC/Label.text = 'Søkte gjennom ' + str(words) + ' ord og ' + str(charcnt) + ' tegn'


# Får ett og ett ord fra search funksjonen og ser om det matcher tag formatet til JSF
# Alle matcher blir puttet i lister
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
	
	if $MC/VBC/Prefix.pressed: # Fjerner 1900 prefix
		text = text.lstrip('123456790-.')
		if not TAG.has(text):
			TAG.append(text)
	else: # Lagrer TAG med 1900 prefix
		if not TAG.has(text):
			TAG.append(text)
	
	TAG.sort()


# Teller antall tagnummer i listene
func count_tag():
	var lq = len(TAGL)
	var p1 = len(TAGA)
	var dp = len(TAGD)
	var rp = len(TAGR)
	var tot = len(TAG)
	$MC/VBC/TAG.text = 'Fant ' + str(tot) + ' TAG. LQ: ' + str(lq) + ' P1: ' + str(p1) + ' DP: ' + str(dp) + ' RP: ' + str(rp)


# Fyller scrollboxen med tagene som er funnet
func fill_scrollbox():
	for child in $MC/VBC/TagListe/VBC.get_children():
		child.queue_free()
	for tag in TAG:
		var a = TAGlabel.instance()
		a.get_child(0).text = tag
		a.index = tag
		a.connect("delte_tag", self, "_on_Delete_tag")
		a.connect("open_stid", self, "_on_Open_STID")
		$MC/VBC/TagListe/VBC.add_child(a)


# Separerer tag per platform
func separate_tag():
	TAGL = []
	TAGA = []
	TAGD = []
	TAGR = []
	
	if $MC/VBC/Prefix.pressed: 
		for tag in TAG:
			if tag.begins_with('L') and not TAGL.has(tag):
				TAGL.append(tag)
			if tag.begins_with('A') and not TAGA.has(tag):
				TAGA.append(tag)
			if tag.begins_with('D') and not TAGD.has(tag):
				TAGD.append(tag)
			if tag.begins_with('R') and not TAGR.has(tag):
				TAGR.append(tag)
	else:
		for tag in TAG:
			if tag[5].begins_with('L') and not TAGL.has(tag):
				TAGL.append(tag)
			if tag[5].begins_with('A') and not TAGA.has(tag):
				TAGA.append(tag)
			if tag[5].begins_with('D') and not TAGD.has(tag):
				TAGD.append(tag)
			if tag[5].begins_with('R') and not TAGR.has(tag):
				TAGR.append(tag)


# Funkjson for å slette TAG før lagring
func _on_Delete_tag(index):
	var a = TAG.find(index)
	TAG.remove(a)
	fill_scrollbox()
	separate_tag()
	count_tag()


# Funksjon for å åpne et STID søk med valgt TAG
func _on_Open_STID(index):
	OS.shell_open('http://tips.statoil.no/TagDetails.aspx?inst_code=JSV&tag_no=' + str(index) + '&search=tag')


# Funksjon for å lagre tag i .txt filer
func save(text, id):
	if len(text) > 0:
		var tag = PoolStringArray(text)
		var tagsort = tag.join('\n')
		var save = File.new()
		save.open(dir + '\\tagListe' + id + '.txt', File.WRITE)
		save.store_line(tagsort)
		save.close()


# Knapp for generering av lister
func _on_GenererLister_pressed():
	if $MC/VBC/Multifile.pressed: # Lagrer separate lister
		save(TAGL, 'JSL')
		save(TAGA, 'JSA')
		save(TAGD, 'JSD')
		save(TAGR, 'JSR')
	
	if not $MC/VBC/Multifile.pressed: # Lagrer felles liste
		save(TAG, 'JSF')
	
	$MC/VBC/Label.text = 'Lister opprettet i ' + dir
	OS.shell_open(dir)
	
	if $MC/VBC/Taghub.pressed: # Åpner TagHub
		OS.shell_open('https://taghub.equinor.com/')


# Knapp for last/søk på nytt
func _on_Reload_pressed():
	TAGL = []
	TAGA = []
	TAGD = []
	TAGR = []
	TAG = []
	search()


# TODO: lage funksjon for å velge hvor filene skal opprettes
func new_dir(path):
	dir = Directory.new()
