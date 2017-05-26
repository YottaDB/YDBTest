;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is the original bug's test case. The new entry point at label drive has other
; test cases to confirm the results
gtm8389
	new rtn,trig1,trig2
	set rtn=$piece($zposition,"+")
	write rtn,!
	set trig1="+^a -commands=S -xecute=""zwrite $ztname"""
	set trig2="+^a -commands=S -xecute=""ZWRITE $ZTNAME"""
	if $ztrigger("i","-*"),$ztrigger("i","+^a -commands=S -xecute=""zwrite $ztname,$ztoldvalue""")
	write "Xecute",!
	set ^a=$justify($increment(%x),%just)
	if $ztrigger("i","-*"),$ztrigger("i","+^a -commands=S -xecute=""zwrite $ztname""")
	write !,"ZPrint ^a#1# ",!
	tstart ()
	zwrite:$tlevel $trestart
	zprint ^a#1#
	tcommit
	write !,"Xecute",!
	set ^a=$justify($increment(%x),%just)
	zprint ^a#1#
	quit

	; Documenting evidence of the original failure:
	; V6200[012] will produce the following behavior where a simple ZPrint inside TP will
	; restart until the fourth retry even when there are NO concurrent updates
	;
	;0430 2:48pm e1020505@shaha:/testarea1/e1020505/triggers 0> mumps -run ^gtm8389
	;All existing triggers (count = 1) deleted
	;Added SET trigger on ^a named a#1
	;execute
	;$ZTNAME="a#1#"
	;$ZTOLDVAL=1
	;replace
	;All existing triggers (count = 1) deleted
	;Added SET trigger on ^a named a#1
	;zprint
	;$TRESTART=0  <---\
	;$TRESTART=1  <----\__________> That's too many when there's only one process
	;$TRESTART=2  <----/
	;$TRESTART=3  <---/
	; zwr $ztname
	;$ZTNAME="a#1#"
	; zwr $ztname

; This is main entry point into this test case. Pass justification on the cli to induce spanning nodes
drive
	set %just=+$zcmdline,%x=0
	kill ^a
	do ^echoline,^gtm8389 write !
	do ^echoline,notexecuted write !
	do ^echoline,executedbutdeleted write !
	do ^echoline,replaced write !
	do ^echoline,execreplaced write !
	do ^echoline,zprintinflight write !
	do ^echoline,dtinflight write !
	do ^echoline,zprintunlink
drivecont1					; Come here to restart after above unlink type test
	write !
	do ^echoline,dtunlink
drivecont2
	write !
	do ^echoline,zprintunlinkdel
drivecont3
	write !
	do ^echoline,dtunlinkdel
drivecont4
	write !
	quit

; Send trigger load operation output to a file instead of including it in the reference file
trigload(rtn,op1,op2)
	new file,$ETRAP
	set $ETRAP="use $p zwrite $zstatus set $ecode="""" close file"
	set file=rtn_".trig.out",op1=$get(op1),op2=$get(op2)
	if $length(op2) write "=>","Replacing triggers"
	else  if $length(op1) write "=>","Loading triggers"
	else  write "=>","Unloading triggers"
	open file:newversion
	use file
	if $ztrigger("i","-*")
	if $length(op1),$ztrigger("i",op1)
	if $length(op2),$ztrigger("i",op2)
	close file
	quit

; Print the comments above a label so that we can see them before the test output
printcomments(label)
	new i,j
	for i=-1:-1:-9 quit:$text(@(label_"+"_i_"^gtm8389"))=" "
	for j=i+1:1:-1 write $text(@(label_"+"_j_"^gtm8389")),!
	write label,!
	quit

; Generic setup for each test case
setup(zpos,trigstr,printcomments)
	set $etrap="set $ecode="""" trollback:$tlevel  write $piece($piece($zstatus,$char(45),3),$char(44)),! zshow ""*"" halt"
	set printcomments=$get(printcomments,1)
	set rtn=$piece(zpos,"+"),gvn="^"_$zconvert(rtn,"U")
	set trig1="+"_gvn_trigstr,trig2=$zconvert(trig1,"U")
	set %just=$get(%just,0)
	do:printcomments printcomments(rtn)
	quit

; Do a SET the invokes the trigger outside of TP
xecnontp(gvn,trig1,trig2)
	set:'$data(%x) %x=1
	do trigload(rtn,trig1)
	write !,"Invoke ",gvn,!
	xecute "set "_gvn_"(%x)=$justify($increment(%x),%just)"
	do trigload(rtn,,$get(trig2))
	quit

; Execute the main test
testit(gvn,zpORtext)
	write !,"TEST: ",$select('$data(zpORtext):"ZPrint ",1:"$Text "),gvn_"#1# ",!
	set tp=$random(2)
	tstart:tp ()
	zprint:'$data(zpORtext) @(gvn_"#1#")
	write:$data(zpORtext) $text(@(gvn_"#1#")),!
	tcommit:tp
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Actual Test Cases FOLLOW ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Show how ZPrint'ing a trigger that was not already executed works as expected
notexecuted
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do trigload(rtn,trig1)
	do testit(gvn)
	quit

; Show how ZPrint'ing a trigger that was executed and deleted works as expected
executedbutdeleted
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1)
	set tp=$random(2)
	write !,"ZPrint "_gvn_"#1# ",!
	tstart:tp ()
	zprint @(gvn_"#1#")
	xecute "set "_gvn_"(%x)=$justify(%x+1,%just)"
	tcommit:tp
	quit

; Show how ZPrint'ing a trigger that was executed and replaced will use whatever trigger is
; currently loaded - the prior trigger
replaced
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1,trig2)
	do testit(gvn)
	quit

; Show how ZPrint'ing a trigger that was executed and replaced will use whatever trigger is
; currently loaded - the new trigger
execreplaced
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1,trig2)
	set tp=$random(2)
	write !,"Xecute "_gvn_"#1# ",!
	tstart:tp ()
	write "before:",$text(@(gvn_"#1#")),!
	xecute "set "_gvn_"(%x)=$justify(%x+1,%just)"
	write "after :",$text(@(gvn_"#1#")),!
	tcommit:tp
	quit

; Show how ZPrint'ing a trigger that was already ZPrint'ed/$TEXT()'d inside a trigger and then
; deleted will print regardless of transaction state. While the outcome is no different than
; the above, the prior version behaved differently in this scenario
zprintinflight
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zprint @($char(94)_$ztname)""")
	do xecnontp(gvn,trig1)
	do testit(gvn)
	quit

; Show how $TEXT()'ing a trigger that was already ZPrint'ed/$TEXT()'d inside a trigger and then
; deleted will print regardless of transaction state. While the outcome is no different than
; the above, the prior version behaved differently in this scenario
dtinflight
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""write $text(@($char(94)_$ztname)),!""")
	do xecnontp(gvn,trig1)
	do testit(gvn,1)
	quit

; Show how ZPRINTing a trigger that was already ZPRINTed/$TEXT()'d or executed prior to execution
; of an UNLINK scenario is reloaded and printed at this reference.
zprintunlink
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1,trig2)
	zgoto 0:zprintunlinkcont 	     ; unlink everything and restart routine at label
	write !!,"Shouldn't be here: ",$zposition,!!
	zshow "*"
	zhalt 1
	; Continue this test here. Note we have tossed the entire stack so there is nowhere to
	; return to so after signifying our success, we have to "restart" the drive routine in
	; the proper place. Note there is no returning to the drive routine's caller - we'll just
	; exit.
zprintunlinkcont
	write !,"TEST: ZGOTO 0:zprintunlinkcont successful - redo setup then try trigger",!
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""",0)
	do trigload(rtn,trig1)
	do testit(gvn)
	zgoto $zlevel:drivecont1

; Show how $TEXT()ing a trigger that was already ZPRINTed/$TEXT()'d or executed prior to execution
; of an UNLINK scenario is reloaded and printed at this reference.
dtunlink
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1,trig2)
	zgoto 0:dtunlinkcont		; unlink everything and restart routine at label
	write !!,"Shouldn't be here: ",$zposition,!!
	zshow "*"
	zhalt 1
	; Continue this test here. Note we have tossed the entire stack so there is nowhere to
	; return to so after signifying our success, we have to "restart" the drive routine in
	; the proper place. Note there is no returning to the drive routine's caller - we'll just
	; exit.
dtunlinkcont
	write !,"TEST: ZGOTO 0:dtunlinkcont successful - redo setup then try trigger",!
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""",0)
	do trigload(rtn,trig1)
	do testit(gvn,1)
	zgoto $zlevel:drivecont2

; Show how ZPRINTing a trigger that was already ZPRINTed/$TEXT()'d or executed prior to execution
; of an UNLINK scenario is deleted and printed at this reference (expect error).
zprintunlinkdel
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1,trig2)
	zgoto 0:zprintunlinkdelcont 	     ; unlink everything and restart routine at label
	write !!,"Shouldn't be here: ",$zposition,!!
	zshow "*"
	zhalt 1
	; Continue this test here. Note we have tossed the entire stack so there is nowhere to
	; return to so after signifying our success, we have to "restart" the drive routine in
	; the proper place. Note there is no returning to the drive routine's caller - we'll just
	; exit.
zprintunlinkdelcont
	write !,"TEST: ZGOTO 0:zprintunlinkdelcont successful - redo setup then try trigger",!
	do setup($zposition,"(:) -commands=S -xecute=""write """"bogus invocation of zprintunlinkdlcont trigger"""",!""",0)
	; Trigger was loaded, executed, and purged with unlink. Now delete it before we try to
	; drive it.
	if $ztrigger("i","-*")
	; Set up a handler for it so we come back here
	set $ETRAP="set $ecode="""" trollback:$tlevel  write ""zprintunlinkdelcont $ETRAP triggered - $ZSTATUS: "",$zstatus,! quit"
	do testit(gvn)
	zgoto $zlevel:drivecont3

; Show how $TEXT()ing a trigger that was already ZPRINTed/$TEXT()'d or executed prior to execution
; of an UNLINK scenario is deleted and printed at this reference (expect null string return).
dtunlinkdel
	new gvn,rtn,trig1,trig2,$ETRAP
	do setup($zposition,"(:) -commands=S -xecute=""zwrite $ztname""")
	do xecnontp(gvn,trig1,trig2)
	zgoto 0:dtunlinkdelcont 	    ; unlink everything and restart routine at label
	write !!,"Shouldn't be here: ",$zposition,!!
	zshow "*"
	zhalt 1
	; Continue this test here. Note we have tossed the entire stack so there is nowhere to
	; return to so after signifying our success, we have to "restart" the drive routine in
	; the proper place. Note there is no returning to the drive routine's caller - we'll just
	; exit.
dtunlinkdelcont
	write !,"TEST: ZGOTO 0:dtunlinkdelcont successful - redo setup then try trigger",!
	do setup($zposition,"(:) -commands=S -xecute=""write """"bogus invocation of dtunlinkdlcont trigger"""",!""",0)
	; Trigger was loaded, executed, and purged with unlink. Now delete it before we try to
	; drive it.
	if $ztrigger("i","-*")
	; Set up a handler for it so we come back here
	set $ETRAP="set $ecode="""" trollback:$tlevel  write ""dtunlinkdelcont $ETRAP triggered - $ZSTATUS: "",$zstatus,! quit"
	do testit(gvn,1)
	zgoto $zlevel:drivecont4
