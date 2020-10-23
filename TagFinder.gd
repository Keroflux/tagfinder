extends Control

var version = "v2.1"
var dir = OS.get_system_dir(2) # Får adressen til dokumenter. Brukes til lagring

var re = RegEx.new()
var manuell = "[0-9]{0,4}-?[A-Z]-[A-Z]\\w+-[0-9]\\d+" # Finner tag med format 1903-A-VG23-0489B med og uten prefix
var vanlig = "[0-9]{0,4}-?[A-Z]{1}-[0-9]{2}[A-Z]{2,4}[0-9]{3,4}[A-D]?" # Finner 1900-A-23PSV2671B med og uten prefix

var TAG =  []   # Liste for alle tagnummer
var TAGL = []   # Liste for LQ tagnummer
var TAGA = []   # Liste for P1 tagnummer
var TAGD = []   # Liste for DP tagnummer
var TAGR = []   # Liste for RP tagnummer

var TAGlabel = preload("res://Tagbutton.tscn") # Label som viser funnede tag i scrollboxen


func _ready():
	search() # Kjører et søk ved oppstart av programmet


#Søker gjennom text fra utklipsstavlen og skjekker dem opp mot RegEx
#Alle matcher blir lagt i en liste, sortert, telt, og plassert i scrollboxen
func search():
	var charct = 0
	var text = OS.get_clipboard() # Får teksten fra clipboardet til PCen
	charct = text.length()
	re.compile(vanlig)
	for result in re.search_all(text):
		var t = result.get_string()
		t = t.lstrip("0123456789-")
		if TAG.has(t):
			pass
		else:
			TAG.append(t)
	re.compile(manuell)
	for result in re.search_all(text):
		var t = result.get_string()
		t = t.lstrip("0123456789-")
		if TAG.has(t):
			pass
		else:
			TAG.append(t)
	TAG.sort()
	
	add_prefix()
	separate_tag()
	count_tag()
	fill_scrollbox()
	$MC/VBC/Label.text = 'Søkte gjennom ' + str(charct) + ' tegn'


# Legger til prefix på tag om det er valgt
func add_prefix():
	if not $MC/VBC/Prefix.pressed:
		for tag in TAG.size():
			var t = TAG[tag]
			if t.begins_with('L'):
				t = "1900-" + t
			elif t.begins_with('A'):
				t = "1901-" + t
			elif t.begins_with('D'):
				t = "1902-" + t
			elif t.begins_with('R'):
				t = "1903-" + t
			TAG[tag] = t


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
		a.indexP = tag
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
func _on_Delete_tag(indexP):
	var a = TAG.find(indexP)
	TAG.remove(a)
	fill_scrollbox()
	separate_tag()
	count_tag()


# Funksjon for å åpne et STID søk med valgt TAG
func _on_Open_STID(index):
	OS.shell_open("https://stid.equinor.com/JSV/tag/" + str(index))

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
		OS.shell_open("https://echohub.equinor.com/")


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
