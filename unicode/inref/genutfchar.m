genutfchar(type)
	new i,max,index,subs
	set max=^%genutfchar("count",type)
	set index=$random(max)
	set subs=$order(^%genutfchar(type,""))
	for i=1:1:index  quit:subs=""  set subs=$order(^%genutfchar(type,subs))
	quit $char(subs)
genutfstrkill;
	kill %genutfstrchar
	quit
genutfstr(asciistr,genutfquotetodoublequote)
	; assumes asciistr is ascii
	new len,type,i,xstr,utfstr,asciichar,utfchar
	set len=$length(asciistr)
	set utfstr=""
	for i=1:1:len  do
	.	set asciichar=$extract(asciistr,i)
	.	if $data(%genutfstrchar(asciichar))  set utfchar=%genutfstrchar(asciichar)
	.	else  do
	.	.	set code=$zascii(asciichar)
	.	.	set codetype=""
	.	.	for type="C","P","N","U","L"  do  quit:codetype'=""
	.	.	.	if $data(^%genutfchar(type,code))'=0  set codetype=type
	.	.	set utfchar=$$genutfchar^genutfchar(codetype)
	.	.	set %genutfstrchar(asciichar)=utfchar
	.	if ($zlength(utfchar)=1)&(utfchar="""")&(+$get(genutfquotetodoublequote)'=0)  set utfstr=utfstr_utfchar_utfchar
	.	else  set utfstr=utfstr_utfchar
	.
	quit utfstr
init	;
	kill ^%genutfchar
	do dbfill
	do clean
	do check
	quit
check	;
	set act="write ""type="",type,"":subs="",subs,!"
	do common
	quit
clean	;
	set act="kill ^%genutfchar(type,subs)"
	do common
	quit
common	;
	for type="C","P","N","U","L"  do
	.	set xstr="if x?1"_type_"'=1 "_act
	.	set subs=$order(^%genutfchar(type,""))
	.	set count=0
	.	for  quit:subs=""  do
	.	.	set count=count+1
	.	.	set x=$c(subs)
	.	.	x xstr
	.	.	set subs=$order(^%genutfchar(type,subs))
	.	set ^%genutfchar("count",type)=count
	quit
dbfill	;
	; one-byte
	; -----------
	; C = control     = 0x00-0x1F,0x7F	/* Ascii */
	; P = punctuation = 0x20-0x2F,0x3A-0x40,0x5B-0x60,0x7B-0x7E	/* Ascii */
	; N = numbers     = 0x30-0x39		/* Ascii */
	; U = upper-case  = 0x41-0x5A		/* Ascii */
	; L = lower-case  = 0x61-0x7A		/* Ascii */
	; 
	for i=0:1:31,127  set ^%genutfchar("C",i)="Ascii"
	for i=32:1:47,58:1:64,91:1:96,123:1:126  set ^%genutfchar("P",i)="Ascii"
	for i=48:1:57 set ^%genutfchar("N",i)="Ascii"
	for i=65:1:90 set ^%genutfchar("U",i)="Ascii"
	for i=97:1:122 set ^%genutfchar("L",i)="Ascii"
	;
	; two-byte
	; -----------
	; C = control     = 0x80-0x9F		/* Latin */
	; P = punctuation = 0xA0-0xBF		/* Latin */
	; N = numbers     = 0x660-0x669		/* Arabic-Indic */
	; U = upper-case  = 0xC0-0xD6,0xD8-0xDE	/* Latin */
	; L = lower-case  = 0xDF-0xF6,0xF8-0xFF	/* Latin */
	; 
	for i=128:1:159  set ^%genutfchar("C",i)="Latin"
	for i=160:1:191  set ^%genutfchar("P",i)="Latin"
	for i=1632:1:1641 set ^%genutfchar("N",i)="Arabic-Indic"
	for i=192:1:214,216:1:222 set ^%genutfchar("U",i)="Latin"
	for i=223:1:246,248:1:255 set ^%genutfchar("L",i)="Latin"
	;
	; three-byte
	; -----------
	; C = control     = 
	; P = punctuation = 0x2000-0x2057		/* General Punctuation */
	; N = numbers     = 0x966-0x96F			/* Devanagari */
	; U = upper-case  = 0x1E00-0x1E94 (alternate)	/* Latin Extended Additional */
	; L = lower-case  = 0x1E01-0x1E95 (alternate)	/* Latin Extended Additional */
	;
	;for i=128:1:159  set ^%genutfchar("C",i)=""
	for i=8192:1:8279 set ^%genutfchar("P",i)="General Punctuation"
	for i=2406:1:2415 set ^%genutfchar("N",i)="Devanagari"
	for i=7680:2:7828 set ^%genutfchar("U",i)="Latin Extended Additional"
	for i=7681:2:7829 set ^%genutfchar("L",i)="Latin Extended Additional"
	; 
	; four-byte
	; -----------
	; C = control     = 
	; P = punctuation = 0x10100-0x10102		/* Aegean */
	; N = numbers     = 0x104A0-0x104A9		/* Osmanya */
	; U = upper-case  = 0x10400-0x10427		/* Deseret */
	; L = lower-case  = 0x10428-0x1044F		/* Deseret */
	;
	;for i=128:1:159  set ^%genutfchar("C",i)=""
	for i=65792:1:65794 set ^%genutfchar("P",i)="Aegean"
	for i=66720:1:66729 set ^%genutfchar("N",i)="Osmanya"
	for i=66560:1:66599 set ^%genutfchar("U",i)="Deseret"
	for i=66600:1:66639 set ^%genutfchar("L",i)="Deseret"
	;
	quit
