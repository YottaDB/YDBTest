;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utffixfollow
	; test utf disk reads for timed, non-zero timed, zero timed reads with both nofollow and follow
	; this script supports the disk_follow.csh test in Unicode testing
	; the following files were created by utffixinit.m:
	; utf8_fix_bom, utf8_fix_bom_head, utf8_fix_bom_tail, utf8_fix_nobom, utf8_fix_nobom_fill1,
	; utf8_fix_nobom_fill2, utf8_fix_nobom_head, utf8_fix_nobom_head2, utf8_fix_nobom_head3, utf8_fix_nobom_tail,
	; utf8_fix_nobom_tail2, utf8_fix_nobom_tail3, utf16_fix_bom, utf16_fix_bom_head, utf16_fix_bom_head2,
	; utf16_fix_bom_tail, utf16_fix_bom_tail2, utf16_fix_nobom, utf16_fix_nobom_fill1, utf16_fix_nobom_fill2,
	; utf16_fix_nobom_head, utf16_fix_nobom_head2, utf16_fix_nobom_head3, utf16_fix_nobom_head4,
	; utf16_fix_nobom_tail, utf16_fix_nobom_tail2, utf16_fix_nobom_tail3
	;
	; The reader job is used to test various forms of fixed mode reads.  The writer job is a coroutine
	; which starts utffixinit.m via a pipe device.  The global variable ^a is used to synchronize the behavior
	; of these 2 coroutines.  For instance, the reader job sets ^a to "cp1" which instructs utffixinit to
	; write characters into the rwutffixfile to be read by the reader job.
	;
	; Similar coroutine code exists in:
	;	utfdiskfollow.m which uses utfinit.m
	;	utffollowtimeout.m which uses utftimeoutinit.m
	;
	write "setting ^a to start",!
	set ^a="start"
	set p1="rwutffixfile"
	job reader^utffixfollow(p1):(output="utffixreader.mjo":error="utffixreader.mje")
	job writer^utffixfollow(p1):(output="utffixwriter.mjo":error="utffixwriter.mje")
	set ^Zreadcnt(p1)=0
	set ^NumIntrSent(p1)=0
	job sendintr^utffixfollow(p1):(output="utffixsendintr.mjo":error="utffixsendintr.mje")
	do wait("rdone")
	quit

reader(p1)
	set $Zint="Set ^Zreadcnt("""_p1_""")=^Zreadcnt("""_p1_""")+1"
	new x,timebefore,timeafter,elapsedtime
	do savepid("utffixreader")
	do wait("initdone")
; uncomment all non-comment lines in this file and utffixinit.m with the word "skip" in them to do a reduced standalone test
;	goto skip
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, UNTIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	set p="utf8_fix_bom"
	open p:(readonly:fix:recordsize=15)
	zshow "d"
	use p:width=5
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, UNTIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	set p="utf8_fix_nobom"
	open p:(readonly:fix:recordsize=15)
	zshow "d"
	use p:width=5
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, UNTIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	set p="utf16_fix_bom"
	open p:(readonly:fix:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p:width=3
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, UNTIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	set p="utf16_fix_nobom"
	open p:(readonly:fix:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p:width=3
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, NON-ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	set p="utf8_fix_bom"
	open p:(readonly:fix:recordsize=15)
	zshow "d"
	use p:width=5
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, NON-ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	set p="utf8_fix_nobom"
	open p:(readonly:fix:recordsize=15)
	zshow "d"
	use p:width=5
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, NON-ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	set p="utf16_fix_bom"
	open p:(readonly:fix:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p:width=3
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, NON-ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	set p="utf16_fix_nobom"
	open p:(readonly:fix:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p:width=3
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, FIXED, NOFOLLOW, ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	set p="utf8_fix_bom"
	open p:(readonly:fix:recordsize=15)
	zshow "d"
	use p:width=5
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	set p="utf8_fix_nobom"
	open p:(readonly:fix:recordsize=15)
	zshow "d"
	use p:width=5
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	set p="utf16_fix_bom"
	open p:(readonly:fix:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p:width=3
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	set p="utf16_fix_nobom"
	open p:(readonly:fix:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p:width=3
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, UNTIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	; copy utf8_fix_bom_head to p1
	set ^a="cp1"
	do wait("cp1done")
	open p1:(readonly:fix:follow:recordsize=15)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td1 to have writer add utf8_fix_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td1"
	use p1:width=5
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, UNTIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	; copy utf8_fix_nobom_head to p1
	set ^a="cp2"
	do wait("cp2done")
	open p1:(readonly:fix:follow:recordsize=15)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td2 to have writer add utf8_fix_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td2"
	use p1:width=5
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, UNTIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	; copy utf16_fix_bom_head to p1
	set ^a="cp3"
	do wait("cp3done")
	open p1:(readonly:fix:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td3 to have writer add utf16_fix_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td3"
	use p1:width=3
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, UNTIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	; copy utf16_fix_nobom_head to p1
	set ^a="cp4"
	do wait("cp4done")
	open p1:(readonly:fix:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td4 to have writer add utf16_fix_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td4"
	use p1:width=3
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",1,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, NON-ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:fix:follow:recordsize=15)
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0,0)
	close p1
	; copy utf8_fix_bom_head to p1
	set ^a="cp5"
	do wait("cp5done")
	open p1:(readonly:fix:follow:recordsize=15)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td5 to have writer add utf8_fix_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td5"
	use p1:width=5
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, NON-ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	; copy utf8_fix_nobom_head to p1
	set ^a="cp6"
	do wait("cp6done")
	open p1:(readonly:fix:follow:recordsize=15)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td6 to have writer add utf8_fix_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td6"
	use p1:width=5
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, NON-ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:fix:follow:recordsize=12:ICHSET="UTF-16")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0,0)
	close p1
	; copy utf16_fix_bom_head to p1
	set ^a="cp7"
	do wait("cp7done")
	open p1:(readonly:fix:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td7 to have writer add utf16_fix_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td7"
	use p1:width=3
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, NON-ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	; copy utf16_fix_nobom_head to p1
	set ^a="cp8"
	do wait("cp8done")
	open p1:(readonly:fix:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td8 to have writer add utf16_fix_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td8"
	use p1:width=3
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; change to nofollow to get EOF
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:fix:follow)
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0,0)
	close p1
	; copy utf8_fix_bom_head to p1
	set ^a="cp9"
	do wait("cp9done")
	open p1:(readonly:fix:follow:recordsize=15)
	zshow "d"
	use p1:width=5
	; this one will timeout after reading 1 char
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 1",0,0)
	; add utf8_fix_bom_tail to the end of p1 with no delay
	set ^a="tnd1"
	do wait("tnd1done")
	; this one will timeout because it tries to read recordsize bytes
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	; copy utf8_fix_nobom_head2 to p1
	set ^a="cp10"
	do wait("cp10done")
	open p1:(readonly:fix:follow:recordsize=15)
	zshow "d"
	use p1:width=5
	; this one will timeout after reading 1 char
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 2",0,0)
	; add utf8_fix_nobom_tail2 to the tail of p1 with no delay
	set ^a="tnd2"
	do wait("tnd2done")
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:fix:follow:ICHSET="UTF-16")
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0,0)
	close p1
	; copy utf16_fix_bom_head2 to p1
	set ^a="cp11"
	do wait("cp11done")
	open p1:(readonly:fix:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p1:width=3
	; this one will timeout after reading 1 char
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 1",0,0)
	; add utf16_fix_bom_tail2 to the tail of p1 with no delay
	set ^a="tnd3"
	do wait("tnd3done")
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FIXED, FOLLOW, ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	; copy utf16_fix_nobom_head2 to p1
	set ^a="cp12"
	do wait("cp12done")
	open p1:(readonly:fix:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p1:width=3
	; this one will timeout after reading 1 char
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 1",0,0)
	; add utf16_fix_nobom_tail2 to the tail of p1 with no delay
	set ^a="tnd4"
	do wait("tnd4done")
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0",0,0)
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",0,0)
	close p1

	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, UNTIMED READS UTF-8",!
	write "**********************************",!
	; create file with 10 utf chars
	; copy utf8_fix_bom to p1
	set ^a="cp13"
	do wait("cp13done")
	open p1:(readonly:follow:fixed:recordsize=30)
	zshow "d"
	use $p
	set timebefore=$horolog
	write "setting ^a to td9 to have writer add 10 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td9"
	use p1
	read y1#4,y2#6
	set x=y1_y2
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 10",1,0)
	set $x=0
	read y3#4,y4#6
	set x=y3_y4
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 10",1,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x#10
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1

	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, UNTIMED READS UTF-16",!
	write "**********************************",!
	; create file with 6 utf-16 chars
	; copy utf16_fix_bom to p1
	set ^a="cp14"
	do wait("cp14done")
	open p1:(readonly:follow:fixed:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use $p
	set timebefore=$horolog
	write "setting ^a to td10 to have writer add 6 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td10"
	use p1
	read y1#2,y2#4
	set x=y1_y2
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 6",1,0)
	set $x=0
	read y3#4,y4#2
	set x=y3_y4
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 6",1,0)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x#6
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1

	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, NON-ZERO TIMED READS UTF-8",!
	write "**********************************",!
	; create file with 3 utf chars
	; copy utf8_fix_nobom_head3 to p1
	set ^a="cp15"
	do wait("cp15done")
	open p1:(readonly:follow:fixed:recordsize=15)
	zshow "d"
	use p1
	read x#10:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3 $y= 0",0,1)
	use $p
	set timebefore=$horolog
	write "setting ^a to td11 to have writer add 7 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td11"
	use p1
	read x#7
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 10 $y= 0",1,1)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1
	set ^a="tnd5"
	do wait("tnd5done")
	read x#8
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",1,1)
	u p1
	read x#5
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 5 $y= 1",1,1)
	; change to nofollow to get EOF
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x#10
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1

; uncomment all non-comment lines in this file and utffixinit.m with the word "skip" in them to do a reduced standalone test
;skip
	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, UNTIMED READS WIDTH < RECORDSIZE UTF-8",!
	write "**********************************",!
	; copy utf8_fix_nobom with 10 utf characters and 15 bytes to p1
	set ^a="cp16"
	do wait("cp16done")
	open p1:(readonly:follow:fixed:recordsize=15)
	zshow "d"
	use p1:width=8
	read x#10
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",1,1)
	read x#6
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 2 $y= 1",1,1)
	set timebefore=$horolog
	use $p
	write "setting ^a to td12 to have writer add 16 more chars (22 bytes) to "_p1_" after a 5 sec delay",!
	set ^a="td12"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",1,1)
	use $p
	write "the previous read consumed 7 bytes of the 15 byte recordsize or 6 utf chars to finish the ",!
        write "width of 8 chars leaving 8 bytes in the record for the next read",!
	write "This will be a read of 5 utf chars followed by a read of 3 to finish the next width.",!
	write "Finally 2 utf chars are read.",!
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 5 $y= 2",1,1)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 3",1,1)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 2 $y= 3",1,1)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0 $y= 4",1,1)
	close p1

	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, TIMED READS WITH TIMEOUTS UTF-8, DEFAULT RECORDSIZE",!
	write "**********************************",!
	; copy utf8_fix_nobom_head3 with 3 utf characters and 6 bytes to p1
	set ^a="cp17"
	do wait("cp17done")
	open p1:(readonly:follow:fixed)
	zshow "d"
	use p1
	read x#10:2
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3 $y= 0",0,1)
	set ^a="tnd6"
	use $p
	write "setting ^a to tnd6 to have writer add 3 more chars to "_p1,!
	do wait("tnd6done")
	use p1
	read x#10:2
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 6 $y= 0",0,1)
	set ^a="tnd7"
	use $p
	write "setting ^a to tnd7 to have writer add 3 chars, hang 2, add 3 chars to "_p1,!
	; not waiting for tnd7done because the writes are done as 3 chars followed by 3 chars with 2 sec between
	use p1
	read x#10:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 12 $y= 0",0,1)
	set ^a="tnd8"
	use $p
	write "setting ^a to tnd8 to have writer add 2 chars, hang 2, add 2 chars to "_p1,!
	; not waiting for tnd8done because the writes are done as 2 chars followed by 2 chars with 2 sec between
	use p1
	read x#10:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 16 $y= 0",0,1)
	set ^a="tnd9"
	use $p
	write "setting ^a to tnd9 to have writer add 3 more chars to "_p1,!
	do wait("tnd9done")
	use p1
	read x#10:2
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 19 $y= 0",0,1)
	set ^a="tnd10"
	use $p
	write "setting ^a to tnd10 to have writer add 2 chars, hang 2, add 2 chars to "_p1,!
	; not waiting for tnd10done because the writes are done as 2 chars followed by 2 chars with 2 sec between
	use p1
	read x#10:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 23 $y= 0",0,1)
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1

	write "**********************************",!
	write "READONLY, x, FIXED, FOLLOW, TIMED READS WITH/WITHOUT TIMEOUT UTF-8, RECORDSIZE=15",!
	write "**********************************",!
	; copy utf8_fix_nobom_head3 with 3 utf characters and 6 bytes to p1
	set ^a="cp18"
	do wait("cp18done")
	open p1:(read:fixed:follow:recordsize=15)
	zshow "d"
	use p1:width=10
	read x:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3 $y= 0",0,1)
	use $p
	write "setting ^a to td13 to have writer add 7 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td13"
	use p1
	read x:10
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",0,1)
	use $p
	write "setting ^a to tnd11 to have writer hang 2, write 3 chars, hang 2, write 7 chars to "_p1,!
	set ^a="tnd11"
	use p1
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",0,1)
	use $p
	write "setting ^a to tnd12 to have writer hang 2, write 3 chars, hang 2, write 7 chars to "_p1,!
	set ^a="tnd12"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 3",1,1)
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0 $y= 4",1,1)
	close p1

	write "**********************************",!
	write "READONLY, x, FIXED, FOLLOW, TIMED and UNTIMED READS, FILL CHARS, UTF-8, RECORDSIZE=10",!
	write "**********************************",!
	; copy utf8_fix_nobom_head3 with 3 utf characters and 6 bytes to p1

	set ^a="cp19"
	do wait("cp19done")
	open p1:(read:fixed:follow:recordsize=10)
	zshow "d"
	use p1:width=3
	set ^a="td14"
	read x#5
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",1,1)
	set ^a="tnd13"
	do wait("tnd13done")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",1,1)
	set ^a="td15"
	use p1
	; will hang waiting for 4 fill chars
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",1,1)
	set ^a="tnd14"
	do wait("tnd14done")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 2 $y= 2",0,1)
	set ^a="tnd15"
	do wait("tnd15done")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 3",0,1)
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 1 $y= 3",1,1)
	set ^a="tnd16"
	do wait("tnd16done")
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 4",1,1)
	use p1
	read x#4
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 1 $y= 4",1,1)
	use p1:nofollow
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0 $y= 5",1,1)
	close p1

	write "**********************************",!
	write "READONLY, x, FIXED, FOLLOW, TIMED and UNTIMED READS, FILL CHARS, UTF-16, RECORDSIZE=10",!
	write "**********************************",!

	; copy utf16_fix_nobom_head3 with 3 utf characters and 6 bytes to p1
	set ^a="cp20"
	do wait("cp20done")
	open p1:(read:fixed:follow:recordsize=10:ICHSET="UTF-16")
	zshow "d"
	use p1:width=3
	set ^a="td16"
	read x#5
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",1,1)
	set ^a="tnd17"
	do wait("tnd17done")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",1,1)
	set ^a="td17"
	use p1
	; will hang waiting for 4 fill chars
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",1,1)
	set ^a="tnd18"
	do wait("tnd18done")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 2 $y= 2",0,1)
	set ^a="tnd19"
	do wait("tnd19done")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 3",0,1)
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 1 $y= 3",1,1)
	set ^a="tnd20"
	do wait("tnd20done")
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 4",1,1)
	use p1
	read x#4
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 1 $y= 4",1,1)
	use p1:nofollow
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0 $y= 5",1,1)
	close p1

	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, TIMED READS WITH TIMEOUTS UTF-16, DEFAULT RECORDSIZE",!
	write "**********************************",!
	; copy utf8_fix_nobom_head3 with 3 utf characters and 6 bytes to p1
	set ^a="cp21"
	do wait("cp21done")
	open p1:(readonly:follow:fixed:ICHSET="UTF-16")
	zshow "d"
	use p1
	read x#10:2
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3 $y= 0",0,1)
	set ^a="tnd21"
	use $p
	write "setting ^a to tnd21 to have writer add 3 more chars to "_p1,!
	do wait("tnd21done")
	use p1
	read x#10:2
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 6 $y= 0",0,1)
	set ^a="tnd22"
	use $p
	write "setting ^a to tnd22 to have writer add 3 chars, hang 2, add 3 chars to "_p1,!
	; not waiting for tnd22done because the writes are done as 3 chars followed by 3 chars with 2 sec between
	use p1
	read x#10:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 12 $y= 0",0,1)
	set ^a="tnd23"
	use $p
	write "setting ^a to tnd23 to have writer add 2 chars, hang 2, add 2 chars to "_p1,!
	; not waiting for tnd23done because the writes are done as 2 chars followed by 2 chars with 2 sec between
	use p1
	read x#10:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 16 $y= 0",0,1)
	set ^a="tnd24"
	use $p
	write "setting ^a to tnd24 to have writer add 3 more chars to "_p1,!
	do wait("tnd24done")
	use p1
	read x#10:2
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 19 $y= 0",0,1)
	set ^a="tnd25"
	use $p
	write "setting ^a to tnd25 to have writer add 2 chars, hang 2, add 2 chars to "_p1,!
	; not waiting for tnd25done because the writes are done as 2 chars followed by 2 chars with 2 sec between
	use p1
	read x#10:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 23 $y= 0",0,1)
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1,0)
	close p1

	write "**********************************",!
	write "READONLY, x#n, FIXED, FOLLOW, UNTIMED READS WIDTH < RECORDSIZE UTF-16",!
	write "**********************************",!
	; copy utf16_fix_nobom twice with 12 utf characters and 24 bytes to p1
	set ^a="cp22"
	do wait("cp22done")
	open p1:(readonly:follow:fixed:recordsize=24:ICHSET="UTF-16")
	zshow "d"
	use p1:width=10
	read x#12
	use $p
        write "this read will return a width of 10 chars (20 bytes) leaving 4 bytes in the record for the next read",!
	use p1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",1,1)
	read x#6
	use $p
        write "this read will return 2 chars (4 bytes) leaving the record empty",!
	use p1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 2 $y= 1",1,1)
	set timebefore=$horolog
	use $p
	write "setting ^a to td18 to have writer add 12 more chars (24 bytes) to "_p1_" after a 5 sec delay",!
	set ^a="td18"
	use p1
	read x
	use $p
        write "this read will return 8 chars (16 bytes) to finish the width of 10 chars, leaving 4 chars in record",!
	use p1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",1,1)
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	use $p
        write "this read will return 4 chars (8 bytes) to empty the record",!
	use p1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 4 $y= 2",1,1)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0 $y= 3",1,1)
	close p1

	write "**********************************",!
	write "READONLY, x, FIXED, FOLLOW, TIMED READS WITH/WITHOUT TIMEOUT UTF-16, RECORDSIZE=12",!
	write "**********************************",!
	; copy utf16_fix_nobom_head3 with 3 utf characters and 6 bytes to p1
	set ^a="cp23"
	do wait("cp23done")
	open p1:(read:fixed:follow:recordsize=12:ICHSET="UTF-16")
	zshow "d"
	use p1:width=6
	read x:5
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3 $y= 0",0,1)
	use $p
	write "setting ^a to td19 to have writer add 3 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td19"
	use p1
	read x:10
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 1",0,1)
	use $p
	write "setting ^a to tnd26 to have writer hang 2, write 3 chars, hang 2, write 3 chars to "_p1,!
	set ^a="tnd26"
	use p1
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 2",0,1)
	use $p
	write "setting ^a to tnd27 to have writer hang 2, write 3 chars, hang 2, write 3 chars to "_p1,!
	set ^a="tnd27"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0 $x= 0 $y= 3",1,1)
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0 $y= 4",1,1)
	close p1

	set ^a="rdone"
	quit

writer(p)
	do savepid("utffixwriter")
	set pp="apipe"
	; test is using a pipe device to start the mumps process "utffixinit" in M mode instead of zsystem
	; no actual I/O is done over the pipe, but in case test cleanup is necessary, just killing
	; the writer process will also kill the child process.
	open pp:(comm="unsetenv gtm_chset; $gtm_exe/mumps -r utffixinit "_p:write)::"pipe"
	do wait("rdone")
	close pp
	quit

sendintr(type)
	do savepid("utffixsendintr")
	write "type = ",type,!
	set ^signum=$$^signals
	write "signum = ",^signum,!
	set ^loopcnt(type)=0
	do waitnot("start")
	; get the reader pid
	set pid="utffixreader_pid"
	open pid:readonly
	use pid
	read readerpid
	use $p
	write "readerpid = ",readerpid,!
	; since there are a lot of 5 sec reads sending interrupts every sec will hit a lot of them
	; but pick a random interval from .5 to 2.5 sec for a better test
	set intfrequency=.5+$Random(3)
	write "intfrequency = ",intfrequency,!
	; quit if in this loop for 20 min
	for  do  quit:("rdone"=^a)!(1200=^loopcnt(type))
	. if '$ZSigproc(readerpid,^signum) set ^NumIntrSent(type)=^NumIntrSent(type)+1
	. hang intfrequency
	. set ^loopcnt(type)=^loopcnt(type)+1
	write "^loopcnt = ",^loopcnt(type),!
	if (1200=^loopcnt(type)) write "^loopcnt reached 1200 - setting ^a to rdone!",!
	write "Number of interrupts sent = ",^NumIntrSent(type),!
	quit

wait(avalue)
	new cnt
	set cnt=0
	for  quit:avalue=^a  do
	. hang 1
	. set cnt=1+cnt
	. if 1800'>cnt use $p write "no change in 30 min so exiting",! halt
	quit

waitnot(avalue)
	; wait until ^a is not equal to avalue
	new cnt
	set cnt=0
	for  quit:avalue'=^a  do
	. hang 1
	. set cnt=1+cnt
	. if 1800'>cnt use $p write "no change in 30 min so exiting",! halt
	quit

results(x,expected,test1,prntdy)
	; x is the variable to be printed
	; expected is the expected output
	; if test1 is non-zero then it is set $test to 1 in output as it is a non-timed read
	; if prntdy is non-zero then include $y in the output
	new %io
	set %io=$io
	set z=$zeof,za=$za,d=$device,t=$test,dx=$x
	; override $test if test1 set
	if test1 set t=1
	if prntdy set dy=$y
	use $p
	write "x= "_x_" length(x)= "_$length(x),!
	write "expect:",!
	write expected,!
	if prntdy write "$device= "_d_" "_" $za= "_za_" $test= "_t_" $zeof= "_z_" $x= "_dx_" $y= ",dy,!
	else  write "$device= "_d_" "_" $za= "_za_" $test= "_t_" $zeof= "_z_" $x= ",dx,!
	use %io
	quit

savepid(type)
	; save the pid
	set pid=type_"_pid"
	open pid:newversion
	use pid
	write $job,!
	close pid
	quit
