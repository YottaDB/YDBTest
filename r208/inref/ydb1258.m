;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ydb1258	;
	; YDB#1258 : a journal record timestamp must never be behind a $HOROLOG read that
	; preceded the update.  See the subtest for what this is about.
	quit
	;
	; ----------------------------------------------------------------------------------
	; Records $HOROLOG just past a second boundary and then updates a global.  Just past
	; a second boundary is the window in which a coarse clock still reports the previous
	; second, so this is where a journal record timestamp taken from such a clock lands
	; behind the $HOROLOG read that preceded it.
	;
	; ^x is updated with nothing in between, so its journal record must not be BEHIND the
	; recorded $HOROLOG.  ^y has a HANG 1 in between, as rollback_A/full_qual does, so its
	; journal record must be strictly LATER.
	;
	; The spin is bounded by $ZUT so it cannot hang on a build too slow to land in the
	; window.  Landing outside the window costs detection, never a false failure.
	;
	; Each iteration waits for the SECOND to change before accepting a landing.  Without
	; that, once one iteration lands just past a boundary the next few find the microsecond
	; field still small and fire immediately, so ten iterations sample two boundaries
	; instead of ten.
	; ----------------------------------------------------------------------------------
update	;
	new i,h,sec,stop,hor,hory
	for i=1:1:10 do
	. set sec=$piece($zhorolog,",",2),stop=$zut+3000000
	. for  set h=$zhorolog quit:(sec'=$piece(h,",",2))&(200>$piece(h,",",3))  quit:$zut>stop
	. set hor(i)=$piece(h,",",1)_","_$piece(h,",",2)
	. set ^x(i)=i
	for i=1:1:3 do
	. set sec=$piece($zhorolog,",",2),stop=$zut+3000000
	. for  set h=$zhorolog quit:(sec'=$piece(h,",",2))&(200>$piece(h,",",3))  quit:$zut>stop
	. set hory(i)=$piece(h,",",1)_","_$piece(h,",",2)
	. hang 1
	. set ^y(i)=i
	open "horolog.txt":newversion
	use "horolog.txt"
	for i=1:1:10 write "x",i,"|",hor(i),!
	for i=1:1:3 write "y",i,"|",hory(i),!
	close "horolog.txt"
	quit
	;
	; ----------------------------------------------------------------------------------
	; Compares each journal record time against the $HOROLOG recorded before that update.
	; Prints one line per stage when every record is correct, and one line per offending
	; record when it is not.
	; ----------------------------------------------------------------------------------
check	;
	new line,hor,jt,n,i,g,s,key,rec,t,jsec,hsec,badx,bady,seenx,seeny,io
	set io=$principal
	set (badx,bady,seenx,seeny,n)=0
	open "horolog.txt":readonly
	use "horolog.txt"
	for  read line quit:$zeof  if line'="" set hor($piece(line,"|",1))=$piece(line,"|",2)
	close "horolog.txt"
	use io
	open "jnlext.mjf":readonly
	use "jnlext.mjf"
	for  read line quit:$zeof  if line'="" set n=n+1,jt(n)=line
	close "jnlext.mjf"
	use io
	for i=1:1:n do
	. set line=jt(i)
	. quit:$piece(line,"\",1)'="05"
	. set rec=$piece(line,"\",$length(line,"\"))
	. set g=""
	. if $extract(rec,1,3)="^x(" set g="x"
	. if $extract(rec,1,3)="^y(" set g="y"
	. quit:g=""
	. set s=$piece($extract(rec,4,$length(rec)),")",1)
	. set key=g_s
	. set t=$piece(line,"\",2)
	. set jsec=$piece(t,",",1)*86400+$piece(t,",",2)
	. set hsec=$piece($get(hor(key)),",",1)*86400+$piece($get(hor(key)),",",2)
	. if g="x" do
	. . set seenx=seenx+1
	. . quit:jsec'<hsec
	. . set badx=badx+1
	. . write "WRONG : ^x(",s,") journal record time ",t," is BEHIND the $HOROLOG ",$get(hor(key))," read just before the update",!
	. if g="y" do
	. . set seeny=seeny+1
	. . quit:jsec>hsec
	. . set bady=bady+1
	. . write "WRONG : ^y(",s,") journal record time ",t," is not later than the $HOROLOG ",$get(hor(key))," read before HANG 1",!
	if seenx'=10 write "WRONG : expected 10 journal records for ^x, found ",seenx,!
	else  if 'badx write "PASS : all 10 ^x journal records are at or after the $HOROLOG read just before the update",!
	if seeny'=3 write "WRONG : expected 3 journal records for ^y, found ",seeny,!
	else  if 'bady write "PASS : all 3 ^y journal records are later than the $HOROLOG read before HANG 1",!
	quit
