extends Control

var TAG =  []   # Liste for alle tagnummer
var TAGL = []   # Liste for LQ tagnummer
var TAGA = []   # Liste for P1 tagnummer
var TAGD = []   # Liste for DP tagnummer
var TAGR = []   # Liste for RP tagnummer


# Kjøres ved oppstart av programmet
func _ready():
	search()


# Søker gjennom teksten fra utklippstaveln. Deler den opp i ord som sendes
# ett og ett til is_tag funksjonen
func search():
	
	var words = 0
	var charcnt = 0
	var message = OS.get_clipboard()
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
	
	if not $Multifile.pressed: # Lagrer tag i felles liste
		TAG = TAGL + TAGA + TAGD + TAGR
		TAGL = []
		TAGA = []
		TAGD = []
		TAGR = []
	
	$Label.text = 'Søkte gjennom ' + str(words) + ' ord og ' + str(charcnt) + ' tegn'
	$TAG.text = 'Fant følgende TAG: \n LQ: ' + str(lq) + '\n P1: ' + str(p1) + '\n DP: ' + str(dp) + '\n RP: ' + str(rp) + '\n Total: ' + str(tot)


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
	
	if $Prefix.pressed: 
		text = text.lstrip('123456790-.') # Fjernet 1900 prefix
		if text.begins_with('L') and not TAGL.has(text):
			TAGL.append(text)
		if text.begins_with('A') and not TAGA.has(text):
			TAGA.append(text)
		if text.begins_with('D') and not TAGD.has(text):
			TAGD.append(text)
		if text.begins_with('R') and not TAGR.has(text):
			TAGR.append(text)
	else:
		if text[5] == 'L' and not TAGL.has(text):
			TAGL.append(text)
		if text[5] == 'A' and not TAGA.has(text):
			TAGA.append(text)
		if text[5] == 'D' and not TAGD.has(text):
			TAGD.append(text)
		if text[5] == 'R' and not TAGR.has(text):
			TAGR.append(text)

	return true # TODO: Return text i stedet?


# Funksjon for å lagre tag i .txt filer
func save(text, id):
	
	if len(text) > 0:
		var tag = PoolStringArray(text)
		var tagsort = tag.join('\n')
		var save = File.new()
		save.open('C:\\Appl\\tagListe' + id + '.txt', File.WRITE)
		save.store_line(tagsort)
		save.close()


# Knapp for generering av lister
func _on_GenererLister_pressed():
	
	save(TAGL, 'JSL')
	save(TAGA, 'JSA')
	save(TAGD, 'JSD')
	save(TAGR, 'JSR')
	save(TAG, 'JSF')
	
	$Label.text = 'Lister opprettet i C:\\APPL'
	
	if $Taghub.pressed: # Åpner TagHub
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
	var dir = Directory.new()
