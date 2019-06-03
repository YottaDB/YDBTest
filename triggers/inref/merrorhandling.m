;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
merrorhandling
	quit

start
	do text^dollarztrigger("tfile^merrorhandling","merrorhandling.trg")
	if $ztrigger("file","merrorhandling.trg")
	quit

testetrap
	kill ^etrap
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("show")="show me that there is NO ETRAP"
	set ^etrap("div by zero")=101
	tcommit:$tlevel
	quit

testetrap2
	kill ^etrap
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()	 ; tlevel=1
	set $ETRAP="write ""BASE HALT"",! halt"
	write "i: ",$increment(i),!
	tstart:tp ()	 ; tlevel=2
	ztrigger ^etrap("replace")
	tcommit:$tlevel	 ; tlevel=2
	set ^etrap("div by zero")=56
	tcommit:$tlevel	 ; tlevel=1
	if $data(^etrap("div by zero")) write "FAIL",!
	quit

divbyzeropass
	do ^echoline
	write "Set ecode to null in ETRAP, this should pass",!
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("div by zero")="expect success"
	if $data(^etrap("div by zero")) write "PASS",!
	if '$data(^etrap("div by zero")) write "FAIL",!
	tcommit:$tlevel
	do ^echoline
	quit

badquote
	write "Bad quoting in etrap",!
	set $ETRAP="do stacker^merrorhandling write $zstatus,!,$ecode,! halt"
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("show")="show me the ETrap"
	tcommit:$tlevel
	tstart:tp ()
	set ^etrap("div by zero")=99
	tcommit:$tlevel
	do ^echoline
	quit

stacker
	write ?5,"ecode",?15,$piece($ecode,",",3,4),!
	write ?5,"place",?15,$zposition,!
	write ?5,"mcode",?15,$text(@$zposition),!
	for l=0:1:$STACK  do
	. write !
	. for i="ecode","place","mcode" write ?5,i,?15,$stack(l,i),!
	quit

newedetrap
	do ^echoline
	write "Show the default, installed and NEWed etraps",!
	set $ETRAP="write ""BASE HALT"",! halt"
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("show")="show me an ETrap"
	tcommit:$tlevel
	tstart:tp ()
	set ^etrap("div by zero")=0
	tcommit:$tlevel
	do ^echoline
	quit

changeetrap
	kill ^etrap
	do ^echoline
	write "Change etrap in the trigger",!
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("xecutetrap")=42*1024
	tcommit:$tlevel
	write "zgoto breaks the trigger update",!
	zwrite ^etrap("xecutetrap")
	do ^echoline
	quit

ehandle
	write "Override base etrap and gtm_trigger_etrap",!
	set $ETRAP="do stacker^merrorhandling write $zstatus,!,$ecode,! halt"
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("div by zero")=0
	tcommit:$tlevel
	do ^echoline
	quit

dortnerrs
	write !,"Testing do routines and errors",!
	set $ETRAP="do stacker^merrorhandling write $zstatus,!,$ecode,! halt"
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("div by zero")=0
	tcommit:$tlevel
	do ^echoline
	quit

badcompile
	do ^echoline
	write "Error handling with broken compile",!
	set $ETRAP="do stacker^merrorhandling write $zstatus,!,$ecode,! halt"
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("bustedxecute")="can't execute this!"
	tcommit:$tlevel
	do ^echoline
	quit

ecode

	do ^echoline
	kill ^etrap
	set $ETrap="write !,""Stack trace"",! zshow ""s"" set $ecode="""""
	do ecodesubrtn
	write $ecode,!
	write "Value get set? ",$data(^etrap),!
	if $data(^etrap) zwrite ^etrap
	write "Done",!
	do ^echoline
	quit

ecodesubrtn
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("ecode")=$zcmdline
	tcommit:$tlevel
	quit

nosuch
	write "Testing non existent labels and routines",!
	set $ETRAP="do saneZS^merrorhandling($zstatus) set $ecode="""""
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("nosuchrtn")=2222
	tcommit:$tlevel
	tstart:tp ()
	set ^etrap("nosuchrtnlbl")=3333
	tcommit:$tlevel
	do ^echoline
	quit

nested
	set $etrap=""
	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel,!
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^CIF(1)=1
	tcommit:$tlevel
	zwrite ^CIF
	do ^echoline
	quit

noztrap
	set $ztrap="quit -1"
	set $ETRAP="do stacker^merrorhandling write $zstatus,!,$ecode,! halt"
	if '$ztrigger("item","+^a -commands=S -xecute=""w 1/0,!"" ")
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^a=101
	tcommit:$tlevel
	do ^echoline
	quit

zgotodm
	write "Break everything such that the base etrap is called",!
	set $ETRAP="write ""BASE HALT"",! halt"
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("zgotodm")="the only safe place is the bottom"
	tcommit:$tlevel
	write "OK to see this",!
	do ^echoline
	quit

zgotoprompt
	write "Break everything such that the NO is called",!
	set $ETRAP="write ""BASE HALT"",! halt"
	set ^etrap("zgotoprompt")="the only safe place is outside"
	write "Should not see this",!
	do ^echoline
	quit

zgotoinvlvl
	do ^echoline
	write "Testing ZGOTOINVLVL",!
	set tp=$ztrnlnm("gtm_test_tp")="TP"
	tstart:tp ()
	set ^etrap("zgotoinvlvl")=1 write "zgoto 1",!
	tcommit:$tlevel
	tstart:tp ()
	set ^etrap("zgotoinvlvl")=0 write "zgoto 0, you should not see this",!
	tcommit:$tlevel
	quit

saneZS(zstatus)
	quit:0=$length(zstatus)
	write "$ZSTATUS=",$piece(zstatus,$ztname),$piece($ztname,"#",1,2),"#",$piece(zstatus,$ztname,2),!
	quit

tfile
	;-*
	;
	;;
	;; ETRAP related testing
	;+^etrap("show")		-command=S,ZK -xecute="do ^twork"
	;+^etrap("replace")      -command=ZTR  -xecute="write $increment(i),?10,$Etrap,! new $ETrap set $ETrap="""" write $increment(i),?10,$etrap,!"
	;
	;+^etrap("div by zero")	-command=S,ZK -xecute="do ^twork write $ZTVAlue/0"
	;
	;+^etrap("xecutetrap")	-command=ZTR -xecute="set $ETrap=""set $ecode="""""""" write $zstatus,! zgoto"""
	;+^etrap("xecutetrap")	-command=S,K -xecute="do ^twork ztrigger ^etrap(""xecutetrap"") do ^twork write $ZTVAlue/0"
	;
	;+^etrap("bustedxecute")	-command=S,ZK -xecute="xecute ""set 1=1"" quit"
	;
	;; recursive failure tests
	;+^CIF(:) -commands=SET -xecute=<<
	;	new $etrap
	;	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $reference=",$reference,!
	;	; intentionally create a bad entryref
	;	if $ztlevel>1 set $etrap="goto etr^TRIGBADREF"
	;	else  set $etrap="goto etr" set subs=$order(^CIF(""),-1) set ^($incr(subs))=subs
	;	write 1/0
	;	quit
	;etr	; Can't use $zstatus because $zpos contains a region disambiguator when spanning region testing is enabled
	;	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $reference=",$reference,!
	;	write "$ecode=",$ecode," : $zstatus=",$piece($zstatus,",",1),",",$piece($piece($zstatus,",",2),"#",1,2),"#,",$piece($zstatus,",",3,99),!
	;	set $ecode=""
	;	quit
	;>>
	;
	;+^etrap("ecode")	-command=S,ZK -xecute="do ^twork w 1/0,!,!"
	;
	;;
	;; No existent routines and labels
	;+^etrap("nosuchrtn")	-command=S,ZK -xecute="do ^nosuchrtn"
	;+^etrap("nosuchrtnlbl")	-command=S,ZK -xecute="do XXX^merrorhandling"
	;
	;;
	;; ZGOTO to direct mode and shell prompt
	;+^etrap("zgotodm")	-command=S -xecute=<<
	;	write $etrap,!
	;	set $etrap="set $ecode="""" write $ztlevel,""ETRAP2DM"",$zlevel,! zgoto 1"
	;	set x=1/0
	;>>
	;+^etrap("zgotoprompt")	-command=S -xecute=<<
	;	write $etrap,!
	;	set $etrap="set $ecode="""" write $ztlevel,""ETRAP2prompt"",$zlevel,! zgoto 0"
	;	set x=1/0
	;>>
	;
	;; attempt to get a ZGOTOINVLVL error
	;+^etrap("zgotoinvlvl")	-command=S,ZK -xecute="set x=1"
	;+^etrap("zgotoinvlvl")	-command=S,ZK -xecute="set x=2"
	;+^etrap("zgotoinvlvl")	-command=S,ZK -xecute="set x=3"
	;+^etrap("zgotoinvlvl")	-command=S,ZK -xecute="zgoto $ztvalue"
	;
	;; for MUPIP erors
	;;^etrap("zgotoprompt")	-command=S,ZK -xecute="new $ETRAP zgoto 1 write ""Should not see this wild zgoto"",!"
