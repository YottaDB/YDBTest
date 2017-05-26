;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; When the trigger chain/nest breaks because of an error, the
	; transacation should not cause any updates
	;
	; On the other hand, if $ecode gets set to null, then the updates
	; should occur.  In this case, the error handler should drop back into
	; the trigger and complete the remaining updates.
updateerrors
	quit

setup
	do ^echoline
	do text^dollarztrigger("tfiletail^updateerrors","tail.trg")
	do text^dollarztrigger("tfileintermediate^updateerrors","intermediate.trg")
	do text^dollarztrigger("tfileinitial^updateerrors","initial.trg")
	quit

test1
	set x=$zcmdline
	do file^dollarztrigger("tail.trg",1)
	write "test 1: break the tail trigger update",!
	do main(x)
	quit

test2
	set x=$zcmdline
	do file^dollarztrigger("intermediate.trg",1)
	write "test 2: break the intermediate trigger update",!
	do main(x)
	quit

test3
	set x=$zcmdline
	do file^dollarztrigger("initial.trg",1)
	write "test 3: break the initial trigger update",!
	do main(x)
	quit

main(x)
	do ^echoline
	kill ^a,^a1,^b,^c,^d,^slate
	set ^slate=""
	set etrap="set ^slate=$ztslate do saneZS^updateerrors($zstatus) set $ecode="""""
	set $piece(blob,"|",$increment(i))=x
	set $piece(blob,"|",$increment(i))=x*20
	set $piece(blob,"|",$increment(i))=""
	set $piece(blob,"|",$increment(i))=x*200
	do oneline
	do chained
	do done
	do ^echoline
	quit

oneline
	do ^echoline
	set $etrap=etrap_" goto onelineret"
	write "OneLine",!
	set ^a(x)=blob
onelineret
	if ^slate=""  write "PASS",!  quit  ; only when $etrap does set $ecode=""
	set len=$length(^slate,$char(10))
	for i=2:1:len  write $tr($piece(^slate,$char(10),i),".",$char(9)),!
	quit

chained
	do ^echoline
	set $etrap=etrap_" goto chainedret"
	write "Chained",!
	set ^a1(x*5)=blob
chainedret
	set len=$length(^slate,$char(10))
	write $tr($piece(^slate,$char(10),len-1),".",$char(9)),!
	write $tr($piece(^slate,$char(10),len),".",$char(9)),!
	quit

done
	if $data(^fired) zwr ^fired
	if $data(^a) zwr ^a
	if $data(^a1) zwr ^a1
	if $data(^b) zwr ^b
	if $data(^c) zwr ^c
	if $data(^d) zwr ^d
	quit

saneZS(zstatus)
	quit:0=$length(zstatus)
	write $piece(zstatus,",",1),","
	write $piece($piece(zstatus,",",2),"#",1,2),"#,"
	write $piece(zstatus,",",3,99),!
	quit

mrtn
	set $piece(slate,".",$i(i))=$piece($ZTNAme,"#",1,2)_"#"
	set $piece(slate,".",$i(i))=$reference
	set $piece(slate,".",$i(i))=subs
	set $piece(slate,".",$i(i))=$ztvalue
	set $ZTSLate=$ztslate_$char(10)_slate
	quit

tfiletail
	;; test 1: break the tail trigger update
	;-*
	;+^a(subs=:) -command=S -xecute="do mrtn^updateerrors set ^d($ztvalue)=subs set ^c(subs)=$ztvalue set ^b(subs)=$ztupdate" -delim="|"
	;+^d(subs=:) -command=S -xecute="do mrtn^updateerrors"
	;+^c(subs=:) -command=S -xecute="do mrtn^updateerrors"
	;+^b(subs=:) -command=S -xecute="do mrtn^updateerrors w 1/0,!"
	;
	;; repeat with chained triggers
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^d($ztvalue)=subs" -delim="|"
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^c(subs)=$ztvalue" -delim="|"
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^b(subs)=$ztupdate" -delim="|"
	quit

tfileintermediate
	;; test 2: break the intermediate trigger update
	;-*
	;+^a(subs=:) -command=S -xecute="do mrtn^updateerrors set ^c(subs)=$ztvalue set ^b(subs)=$ztupdate set ^d($ztvalue)=subs" -delim="|"
	;+^d(subs=:) -command=S -xecute="do mrtn^updateerrors"
	;+^c(subs=:) -command=S -xecute="do mrtn^updateerrors"
	;+^b(subs=:) -command=S -xecute="do mrtn^updateerrors w 1/0,!"
	;
	;; repeat with chained triggers
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^c(subs)=$ztvalue" -delim="|"
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^b(subs)=$ztupdate" -delim="|"
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^d($ztvalue)=subs" -delim="|"
	quit

tfileinitial
	;; test 3: break the initial trigger update
	;-*
	;+^a(subs=:) -command=S -xecute="do mrtn^updateerrors set ^b(subs)=$ztupdate set ^c(subs)=$ztvalue set ^d($ztvalue)=subs" -delim="|"
	;+^d(subs=:) -command=S -xecute="do mrtn^updateerrors"
	;+^c(subs=:) -command=S -xecute="do mrtn^updateerrors"
	;+^b(subs=:) -command=S -xecute="do mrtn^updateerrors w 1/0,!"
	;
	;; repeat with chained triggers
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^b(subs)=$ztupdate" -delim="|"
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^c(subs)=$ztvalue" -delim="|"
	;+^a1(subs=:) -command=S -xecute="do mrtn^updateerrors set ^d($ztvalue)=subs" -delim="|"

