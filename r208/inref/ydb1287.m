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
;
; For each record below, and for each length that cuts the record within its key (up to and including the
; "=" after the key), MUPIP LOAD a ZWR file holding
;	1. a record as long as the one being cut (the "preceding record")
;	2. ^s=1
;	3. the cut copy
; MUPIP LOAD reads every line into the same buffer, so the bytes that follow the cut copy in that buffer are
; the tail of the preceding record. Each cut copy is loaded twice: once after the full record, so the bytes
; that follow it are the rest of that record, and once after a filler record of the same length whose
; bytes past its first few are all "z". The output of the two loads must be the same, since LOAD must not
; look past the end of the cut copy, and each load must reject the cut copy as its only failed record.
;
; A cut within the value is not tested, as the value is parsed by zwr2format(), not zwrkeyvallen().
;
; "noparen" loads, on its own, each $ze(...) record listed at label "noparenrecs". None of them has a ")", and
; neither has any line before it in the file, so nothing in LOAD's buffer can stop a scan for ")" that ignores
; the length of the record. Each load must reject the record as its only failed record.
;
; "emptykey" loads, on its own, the record "=1", whose key is empty. MUPIP LOAD must reject it as its only
; failed record, and report it as NOTGBL.
;
; "filter" is a replication filter: it passes every record through unchanged, except that it rewrites the key
; of a SET of ^zebad into the $ze(...) form, which MUPIP LOAD accepts but a filter must not return.
;
ydb1287	;
	quit
	;
run	; Entry point: test each record in the list at label "records"
	new i,rec
	for i=1:1 set rec=$piece($text(records+i),";;",2) quit:""=rec  do onerec(rec)
	quit
	;
onerec(rec)	; Test every cut of "rec" within its key
	new eqpos,filler,i,cut,outa,outb,nbad,n
	set eqpos=$find(rec,")=""")-2	; position of the "=" that ends the key
	; The filler record has the same form as "rec", as a $ze(...) record also changes where LOAD reads the lines after it.
	; The length in a $ze(...) record is that of its value, taken to be 2 digits long; the check after this verifies it.
	if "$"'=$extract(rec) set filler="^n="""_$$zs($length(rec)-5)_""""
	else  set n=$length(rec)-15,filler="$ze(^n,0,"_n_")="""_$$zs(n)_""""
	if $length(filler)'=$length(rec) write "TEST-E-FILLER : filler ",filler," is not as long as ",rec,! quit
	set nbad=0
	for i=1:1:eqpos do
	. set cut=$extract(rec,1,i)
	. set outa=$$load(rec,cut),outb=$$load(filler,cut)
	. set:'$$check(cut,outa,outb) nbad=nbad+1
	if 0=nbad write "PASS : each of the ",eqpos," cuts of ",rec," is the only failed record, with the same output after the full record as after filler",!
	quit
	;
zs(n)	; Return n "z" characters
	quit $translate($justify("",n)," ","z")
	;
check(cut,outa,outb)	; Return 1 if both loads rejected "cut" as the only failed record and gave the same output
	new i,ok
	set ok=1
	if $$failed(outa)'=1 set ok=0 write "WRONG : ",cut," after the full record : expected 1 failed record, got output:",! do show(outa)
	if $$failed(outb)'=1 set ok=0 write "WRONG : ",cut," after filler : expected 1 failed record, got output:",! do show(outb)
	if ok,outa'=outb do
	. set ok=0
	. write "WRONG : ",cut," : the output depends on the bytes after it. Lines that differ:",!
	. for i=1:1:$length(outa,$char(10)) if $piece(outa,$char(10),i)'=$piece(outb,$char(10),i) do
	. . write "    after the full record : ",$piece(outa,$char(10),i),!
	. . write "    after filler          : ",$piece(outb,$char(10),i),!
	quit ok
	;
failed(out)	; Return the count of failed records LOAD reported, 0 if none, -1 if LOAD did not finish
	new i,line,n
	set n=-1
	for i=1:1:$length(out,$char(10)) set line=$piece(out,$char(10),i) do
	. if line["LOAD TOTAL" set:n<0 n=0
	. if line["FAILEDRECCOUNT" set n=+$piece(line,"unable to process ",2)
	quit n
	;
show(out)	; Display LOAD output, indented
	new i
	for i=1:1:$length(out,$char(10)) write "    ",$piece(out,$char(10),i),!
	quit
	;
load(first,cut)	; MUPIP LOAD "first", ^s=1 and "cut". Return the output, with the lengths cut from the LOAD TOTAL line.
	quit $$loadrecs(first_$char(10)_"^s=1"_$char(10)_cut)
	;
loadrecs(recs)	; MUPIP LOAD the records in "recs", one per $char(10) piece. Return the output, as $$load does.
	new file,i,out,line
	set file="ydb1287.zwr"
	open file:newversion use file
	; LOAD requires "UTF-8" in the first line of the header when, and only when, it runs in UTF-8 mode
	write "YDB#1287 test",$select("UTF-8"=$zchset:" UTF-8",1:""),!,"30-SEP-2026  15:30:00 ZWR",!
	for i=1:1:$length(recs,$char(10)) write $piece(recs,$char(10),i),!
	close file
	; The output holds -E- messages that are expected, so it goes to a .logx file, which the test framework does not scan
	; ZSYSTEM runs $SHELL, which may be tcsh, so run the redirection in sh
	zsystem "sh -c '$ydb_dist/mupip load "_file_" >load.logx 2>&1'"
	set out=""
	open "load.logx":readonly use "load.logx"
	for  read line quit:$zeof  set:line["LOAD TOTAL" line="LOAD TOTAL" set out=out_line_$char(10)
	close "load.logx"
	quit out
	;
noparen	; Entry point: load each record at label "noparenrecs" on its own
	new i,out,rec
	for i=1:1 set rec=$piece($text(noparenrecs+i),";;",2) quit:""=rec  do
	. set out=$$loadrecs(rec)
	. if 1=$$failed(out) write "PASS : ",rec," is the only failed record",! quit
	. write "WRONG : ",rec," : expected 1 failed record, got output:",!
	. do show(out)
	quit
	;
emptykey	; Entry point: load the record "=1" on its own
	new out
	set out=$$loadrecs("=1")
	if (1=$$failed(out))&(out["%YDB-E-NOTGBL") write "PASS : =1 is the only failed record, and is reported as NOTGBL",! quit
	write "WRONG : =1 : expected 1 failed record, reported as NOTGBL, got output:",!
	do show(out)
	quit
	;
filter	; Entry point: replication filter that rewrites the key of a SET of ^zebad into the $ze(...) form
	new from,line,pos,to
	; The source server stops the filter by closing its pipes, so a write may then fail. That is not an error of the test.
	set $etrap="halt"
	use $principal:(nowrap)
	set from="\^zebad=",to="\$ze(^zebad,0,3)="
	for  read line quit:$zeof  quit:"99"=$piece(line,"\",1)  do
	. set pos=$find(line,from)
	. set:pos line=$extract(line,1,pos-$length(from)-1)_to_$extract(line,pos,$length(line))
	. set $x=0
	. write line,!
	quit
	;
replcheck	; Entry point: check INSTB holds ^good=1, and neither ^zebad nor ^after
	new i
	for i=1:1:300 quit:$data(^good)  hang 1
	if (1=$get(^good))&'$data(^zebad)&'$data(^after) write "PASS : INSTB holds ^good=1, and neither ^zebad nor ^after",! quit
	write "WRONG : expected INSTB to hold ^good=1, and neither ^zebad nor ^after. It holds:",!
	zwrite:$data(^good) ^good  zwrite:$data(^zebad) ^zebad  zwrite:$data(^after) ^after
	quit
	;
noparenrecs	; $ze(...) records with no ")", for label "noparen"
	;;$ze(^a,0,3
	;;$ze(^a,0,3=
	;;$ze(^a,0
	;;$ze(^a
	;
records	; Records to cut. The key of each must end with ')="'.
	;;^a($C(65)_"x"_$ZCH(10))="val"
	;;^a("x"_$C(1),"a""b")="v"
	;;^a($C(65)_$ZCH(66)_"y",2)="v"
	;;$ze(^a($C(65)_"x"),0,3)="abc"
