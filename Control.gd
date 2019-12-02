extends Control

var words =   0
var charcnt = 0

var lq =  0
var p1 =  0
var dp =  0
var rp =  0
var tot = 0

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
	
	#p1 = len(TAGA) # Test av ny telle funksjon!
#	if not $Multifile.pressed:
#		TAG = TAGL + TAGA + TAGD + TAGR
	$Label.text = 'Søkte gjennom ' + str(words) + ' ord og ' + str(charcnt) + ' tegn'
	$TAG.text = 'Fant følgende TAG: \n LQ: ' + str(lq) + '\n P1: ' + str(p1) + '\n DP: ' + str(dp) + '\n RP: ' + str(rp) + '\n Total: ' + str(tot)


# Funksjon som søker etter tag nummer, ord for ord og plasserer dem i lister
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
		text = text.lstrip('123456790-.')
		if $Multifile.pressed:
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
				TAG.append(text)
				lq += 1
			if text.begins_with('A') and not TAG.has(text):
				TAG.append(text)
				p1 += 1
			if text.begins_with('D') and not TAG.has(text):
				TAG.append(text)
				dp += 1
			if text.begins_with('R') and not TAG.has(text):
				TAG.append(text)
				rp += 1
	else:
		if $Multifile.pressed:
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
				TAG.append(text)
				lq += 1
			if text[5] == 'A' and not TAG.has(text):
				TAG.append(text)
				p1 += 1
			if text[5] == 'D' and not TAG.has(text):
				TAG.append(text)
				dp += 1
			if text[5] == 'R' and not TAG.has(text):
				TAG.append(text)
				rp += 1
	
	tot = lq + p1 + dp + rp
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
	if $Taghub.pressed:
		OS.shell_open('https://taghub.equinor.com/')


# Knapp for last/søk på nytt
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


# TODO: lage funksjon for å velge hvor filene skal opprettes
func new_dir(path):
	var dir = Directory.new()
