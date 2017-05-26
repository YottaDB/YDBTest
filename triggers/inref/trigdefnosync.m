;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trigdefnosync
	write !
	do ^echoline
	write "Load triggers on the primary",!
	do text^dollarztrigger("tfile^trigdefnosync","trigdefnosync.trg")
	do file^dollarztrigger("trigdefnosync.trg",1)
	do ^echoline
	do selectall^dollarztrigger
	do ^echoline
	quit

	; Objective : Remove all ^b related ^#t nodes
	;
	; The below M program makes it easier for us to remove those records from ^#t's leaf level block
	; which correspond to trigger definitions of ^b. Note, the number of times we issue the DSE command
	; depends heavily on the layout of ^#t's leaf block. Below is the layout
	; ----------------------
	; Rec:1  Blk 3  Off 10  Size 1D  Cmpc 0  Key ^#t("#TNAME","a","#SEQNUM")
	; Rec:2  Blk 3  Off 2D  Size E  Cmpc 10  Key ^#t("#TNAME","a","#TNCOUNT")
	; Rec:3  Blk 3  Off 3B  Size B  Cmpc D  Key ^#t("#TNAME","a#1")
	; Rec:4  Blk 3  Off 46  Size 11  Cmpc C  Key ^#t("#TNAME","b","#SEQNUM")
	; Rec:5  Blk 3  Off 57  Size E  Cmpc 10  Key ^#t("#TNAME","b","#TNCOUNT")
	; Rec:6  Blk 3  Off 65  Size B  Cmpc D  Key ^#t("#TNAME","b#1")
	; Rec:7  Blk 3  Off 70  Size 19  Cmpc 4  Key ^#t("a",1,"BHASH")
	; Rec:8  Blk 3  Off 89  Size C  Cmpc A  Key ^#t("a",1,"CHSET")
	; Rec:9  Blk 3  Off 95  Size 9  Cmpc B  Key ^#t("a",1,"CMD")
	; Rec:A  Blk 3  Off 9E  Size 13  Cmpc A  Key ^#t("a",1,"LHASH")
	; Rec:B  Blk 3  Off B1  Size 12  Cmpc A  Key ^#t("a",1,"TRIGNAME")
	; Rec:C  Blk 3  Off C3  Size 26  Cmpc A  Key ^#t("a",1,"XECUTE")
	; Rec:D  Blk 3  Off E9  Size E  Cmpc 6  Key ^#t("a","#COUNT")
	; Rec:E  Blk 3  Off F7  Size B  Cmpc 9  Key ^#t("a","#CYCLE")
	; Rec:F  Blk 3  Off 102  Size C  Cmpc 8  Key ^#t("a","#LABEL")
	; Rec:10  Blk 3  Off 10E  Size 18  Cmpc 8  Key ^#t("a","#TRHASH",25847717,1)
	; Rec:11  Blk 3  Off 126  Size 19  Cmpc 4  Key ^#t("b",1,"BHASH")
	; Rec:12  Blk 3  Off 13F  Size C  Cmpc A  Key ^#t("b",1,"CHSET")
	; Rec:13  Blk 3  Off 14B  Size 9  Cmpc B  Key ^#t("b",1,"CMD")
	; Rec:14  Blk 3  Off 154  Size 13  Cmpc A  Key ^#t("b",1,"LHASH")
	; Rec:15  Blk 3  Off 167  Size 12  Cmpc A  Key ^#t("b",1,"TRIGNAME")
	; Rec:16  Blk 3  Off 179  Size 26  Cmpc A  Key ^#t("b",1,"XECUTE")
	; Rec:17  Blk 3  Off 19F  Size E  Cmpc 6  Key ^#t("b","#COUNT")
	; Rec:18  Blk 3  Off 1AD  Size B  Cmpc 9  Key ^#t("b","#CYCLE")
	; Rec:19  Blk 3  Off 1B8  Size C  Cmpc 8  Key ^#t("b","#LABEL")
	; Rec:1A  Blk 3  Off 1C4  Size 18  Cmpc 8  Key ^#t("b","#TRHASH",25859893,1)
	; ----------------------
removetrigdef
	for i=1:1:10 zsystem "dse remove -bl=3 -rec=11"	; rec 11 - 1A are the ^#t("b",*) nodes
	for i=1:1:3  zsystem "dse remove -bl=3 -rec=4"	; rec  4 -  6 are the ^#t("#TNAME","b...) nodes
	quit

	; Test cases
expectnoissues
	do ^echoline
	write "Do some updates to ^a global. Expect no issues",!
	do ^echoline
	Set ^a=20
	for i=1:1:10  set ^a(i)=$justify(i,100)
	write !,!
	quit

insyslog
	do ^echoline
	write "Do an update to ^b. TRIGDEFNOSYNC warning will be sent to syslog.",!
	do ^echoline
	set ^b=20
	write !,!
	quit

notinsyslog
	do ^echoline
	write "Do another update to ^b. TRIGDEFNOSYNC warning will NOT be sent to syslog",!
	do ^echoline
	set ^b(2)=2
	write !,!
	quit

tfile
	;-*
	;+^a -commands=SET -xecute="set ^x($ztvalue)=$ztvalue"
	;+^b -commands=SET -xecute="set ^y($ztvalue)=$ztvalue"
