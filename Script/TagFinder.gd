extends Control

var version = "v2.2.2"
var dir = OS.get_system_dir(2) # Får adressen til dokumenter. Brukes til lagring
var time
var totalTime

# Text match søk. https://regex101.com/ for mer info
var rex = RegEx.new()
var manuell = "(?:190\\d-)?[ABDLR]{1}-[A-Z]{2,4}[0-9]{2}-[0-9]+[A-F]?" # Finner tag med format 1904-B-VG23-0489B med og uten prefix
var vanlig = "(?:190\\d-)?[ABDLR]{1}-[0-9]{2}[A-Z]{2,4}[0-9]{3,4}[A-F]?" # Finner 1900-A-23PSV2671B med og uten prefix

var TAG =  []   # Liste for alle tagnummer
var TAGL = []   # Liste for LQ tagnummer
var TAGA = []   # Liste for P1 tagnummer
var TAGD = []   # Liste for DP tagnummer
var TAGR = []   # Liste for RP tagnummer
var TAGB = []   # Liste for P2 tagnummer

var TAGlabel = preload("res://Tagbutton.tscn") # Label som viser funnede tag i scrollboxen


func _ready():
	$Version.text = version
	search() # Kjører et søk ved oppstart av programmet


#Søker gjennom text fra utklipsstavlen og skjekker dem opp mot RegEx
#Alle matcher blir lagt i en liste, sortert, telt, og plassert i scrollboxen
func search():
	time = OS.get_ticks_msec()
	$MC/VBC/EchoAll.selected = 5
	var charct = 0
	var text = OS.get_clipboard() # Får teksten fra clipboardet til PCen
	charct = text.length()
	rex.compile(vanlig)
	for result in rex.search_all(text):
		var t = result.get_string()
		t = t.lstrip("0123456789-")
		if TAG.has(t):
			pass
		else:
			TAG.append(t)
	rex.compile(manuell)
	for result in rex.search_all(text):
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
	refresh_echo_all()
	totalTime = (OS.get_ticks_msec() - time) / 1000.0 # Registrer tiden søke tok i sekunder
	$MC/VBC/Label.text = "Søkte gjennom " + str(charct) + " tegn på " + str(totalTime) + " sek"


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
			elif t.begins_with('B'):
				t = "1904-" + t
			TAG[tag] = t


# Teller antall tagnummer i listene
func count_tag():
	var lq = len(TAGL)
	var p1 = len(TAGA)
	var dp = len(TAGD)
	var rp = len(TAGR)
	var p2 = len(TAGB)
	var tot = len(TAG)
	$MC/VBC/TAG.text = 'Fant ' + str(tot) + ' tag. LQ: ' + str(lq) + ' P1: ' + str(p1) + ' DP: ' + str(dp) + ' RP: ' + str(rp) + ' P2: ' + str(rp)


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
		a.connect("open_echo", self, "_on_Open_Echo")
		$MC/VBC/TagListe/VBC.add_child(a)


# Separerer tag per platform
func separate_tag():
	TAGL = []
	TAGA = []
	TAGD = []
	TAGR = []
	TAGB = []
	
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
			if tag.begins_with('B') and not TAGB.has(tag):
				TAGB.append(tag)
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
			if tag[5].begins_with('B') and not TAGB.has(tag):
				TAGB.append(tag)


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


# Funkjson for å åpne et søk på valgt tag i Echo
func _on_Open_Echo(index):
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


func _on_Open_Echo_all(platform):
	var tag : PoolStringArray = []
	var echoTag
	var plant
	
	if platform == 0:
		plant = "JSL"
		for t in TAGL:
			t = t.lstrip("0123456789.-")
			tag.append(t)
	elif platform == 1:
		plant = "JSA"
		for t in TAGA:
			t = t.lstrip("0123456789.-")
			tag.append(t)
	elif platform == 2:
		plant = "JSD"
		for t in TAGD:
			t = t.lstrip("0123456789.-")
			tag.append(t)
	elif platform == 3:
		plant = "JSR"
		for t in TAGR:
			t = t.lstrip("0123456789.-")
			tag.append(t)
	elif platform == 4:
		plant = "JSB"
		for t in TAGB:
			t = t.lstrip("0123456789.-")
			tag.append(t)
	
	echoTag = tag.join(",")
	OS.shell_open("echo://tag/?tag=" + str(echoTag) + "&plant=" + str(plant))
	$MC/VBC/EchoAll.selected = 5


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
		save(TAGB, 'JSB')
	
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
	TAGB = []
	TAG = []
	search()


# TODO: lage funksjon for å velge hvor filene skal opprettes
func new_dir(path):
	dir = Directory.new()


func refresh_echo_all():
	if TAGL.size() <= 0:
		$MC/VBC/EchoAll.set_item_disabled(0, true)
	else:
		$MC/VBC/EchoAll.set_item_disabled(0, false)
	if TAGA.size() <= 0:
		$MC/VBC/EchoAll.set_item_disabled(1, true)
	else:
		$MC/VBC/EchoAll.set_item_disabled(1, false)
	if TAGD.size() <= 0:
		$MC/VBC/EchoAll.set_item_disabled(2, true)
	else:
		$MC/VBC/EchoAll.set_item_disabled(2, false)
	if TAGR.size() <= 0:
		$MC/VBC/EchoAll.set_item_disabled(3, true)
	else:
		$MC/VBC/EchoAll.set_item_disabled(3, false)
	if TAGB.size() <= 0:
		$MC/VBC/EchoAll.set_item_disabled(4, true)
	else:
		$MC/VBC/EchoAll.set_item_disabled(4, false)
