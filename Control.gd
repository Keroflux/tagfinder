extends Control

var dir = OS.get_system_dir(2) # Får adressen til dokumenter. Brukes til lagring

var TAG =  []   # Liste for alle tagnummer
var TAGL = []   # Liste for LQ tagnummer
var TAGA = []   # Liste for P1 tagnummer
var TAGD = []   # Liste for DP tagnummer
var TAGR = []   # Liste for RP tagnummer

var TAGlabel = preload("res://TAG.tscn") # Label som viser funnede tag i scrollboxen


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
	# Teller antall tagnummer i listene
	var lq = len(TAGL)
	var p1 = len(TAGA)
	var dp = len(TAGD)
	var rp = len(TAGR)
	var tot = lq + p1 + dp + rp
	
	$MC/VBC/Label.text = 'Søkte gjennom ' + str(words) + ' ord og ' + str(charcnt) + ' tegn'
	$MC/VBC/TAG.text = 'Fant følgende TAG: LQ: ' + str(lq) + ' P1: ' + str(p1) + ' DP: ' + str(dp) + ' RP: ' + str(rp) + ' Total: ' + str(tot)
	fill_scrollbox()
	

# Får ett og ett ord fra search funksjonen og ser om det matcher tag formatet til JSF
# Alle matcher blir puttet i lister
func is_tag(text): # TODO: Overkomplisert? Dele opp i flere sorteringsfunksjoner, kanskje.
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
	
	if $MC/VBC/Prefix.pressed: # Fjernet 1900 prefix
		text = text.lstrip('123456790-.') 
		if text.begins_with('L') and not TAGL.has(text):
			TAGL.append(text)
		if text.begins_with('A') and not TAGA.has(text):
			TAGA.append(text)
		if text.begins_with('D') and not TAGD.has(text):
			TAGD.append(text)
		if text.begins_with('R') and not TAGR.has(text):
			TAGR.append(text)
	else: # Lagrer TAG med 1900 prefix
		if text[5] == 'L' and not TAGL.has(text):
			TAGL.append(text)
		if text[5] == 'A' and not TAGA.has(text):
			TAGA.append(text)
		if text[5] == 'D' and not TAGD.has(text):
			TAGD.append(text)
		if text[5] == 'R' and not TAGR.has(text):
			TAGR.append(text)
	
	TAG = TAGL + TAGA + TAGD + TAGR # Lager en felles liste med alle TAG

	return true # TODO: Return text i stedet?


# Fyller scrollboxen med tagene som er funnet
func fill_scrollbox():
	for child in $MC/VBC/TagListe/VBC.get_children():
		child.queue_free()
	for tag in TAG:
		var a = TAGlabel.instance()
		a.text = tag
		$MC/VBC/TagListe/VBC.add_child(a)


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
	if not $MC/VBC/Multifile.pressed: # Lagrer felles lister
		save(TAG, 'JSF')
	
	$MC/VBC/Label.text = 'Lister opprettet i ' + dir
	
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
