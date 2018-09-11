;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utfdiskfollow
	; test utf disk reads for timed, non-zero timed, zero timed reads with both nofollow and follow
	; this script supports the disk_follow.csh test in Unicode testing
	; the following files are created by utfinit.m for aid in debugging test failures:
	; utf8_bom, utf8_bom_head, utf8_nobom_noeol, utf8_bom_tail, utf8_nobom, utf8_nobom_head, utf8_nobom_tail,
	; utf16_bom, utf16_bom_head, utf16_nobom_noeol, utf16_bom_tail, utf16_nobom, utf16_nobom_head, utf16_nobom_tail
	;
	; The reader job is used to test various forms of non-fixed mode reads.  The writer job is a coroutine
	; which starts utfinit.m via a pipe device.  The global variable ^a is used to synchronize the behavior
	; of these 2 coroutines.  For instance, the reader job sets ^a to "cp1" which instructs utfinit to
	; write characters into the rwutffile to be read by the reader job.
	;
	; Similar coroutine code exists in:
	;	utffixfollow.m which uses utffixinit.m
	;	utffollowtimeout.m which uses utftimeoutinit.m
	;
	write "setting ^a to start",!
	set ^a="start"
	set p1="rwutffile"
	job reader^utfdiskfollow(p1):(output="utfreader.mjo":error="utfreader.mje")
	job writer^utfdiskfollow(p1):(output="utfwriter.mjo":error="utfwriter.mje")
	do wait("rdone")
	quit

reader(p1)
	new x,timebefore,timeafter,elapsedtime
	do savepid("utfreader")
	do wait("initdone")
	write "**********************************",!
	write "READONLY, NOFOLLOW, UNTIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	set p="utf8_bom"
	open p:readonly
	zshow "d"
	use p
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, UNTIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	set p="utf8_nobom"
	open p:readonly
	zshow "d"
	use p
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, UNTIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	set p="utf16_bom"
	open p:(readonly:ICHSET="UTF-16")
	zshow "d"
	use p
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, UNTIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	set p="utf16_nobom"
	open p:(readonly:ICHSET="UTF-16")
	zshow "d"
	use p
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, NON-ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	set p="utf8_bom"
	open p:readonly
	zshow "d"
	use p
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, NON-ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	set p="utf8_nobom"
	open p:readonly
	zshow "d"
	use p
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, NON-ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	set p="utf16_bom"
	open p:(readonly:ICHSET="UTF-16")
	zshow "d"
	use p
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, NON-ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	set p="utf16_nobom"
	open p:(readonly:ICHSET="UTF-16")
	zshow "d"
	use p
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	set p="utf8_bom"
	open p:readonly
	zshow "d"
	use p
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	set p="utf8_nobom"
	open p:readonly
	zshow "d"
	use p
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	set p="utf16_bom"
	open p:(readonly:ICHSET="UTF-16")
	zshow "d"
	use p
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	set p="utf16_nobom"
	open p:(readonly:ICHSET="UTF-16")
	zshow "d"
	use p
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, UNTIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	; copy utf8_bom_head to p1
	set ^a="cp1"
	do wait("cp1done")
	open p1:(readonly:follow)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td1 to have writer add utf8_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td1"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, UNTIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	; copy utf8_nobom_head to p1
	set ^a="cp2"
	do wait("cp2done")
	open p1:(readonly:follow)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td2 to have writer add utf8_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td2"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, UNTIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	; copy utf16_bom_head to p1
	set ^a="cp3"
	do wait("cp3done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td3 to have writer add utf16_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td3"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, UNTIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	; copy utf16_nobom_head to p1
	set ^a="cp4"
	do wait("cp4done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td4 to have writer add utf16_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td4"
	use p1
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, NON-ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:follow)
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	close p1
	; copy cp utf8_bom_head to p1
	set ^a="cp5"
	do wait("cp5done")
	open p1:(readonly:follow)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td5 to have writer add utf8_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td5"
	use p1
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, NON-ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	; copy utf8_nobom_head to p1
	set ^a="cp6"
	do wait("cp6done")
	open p1:(readonly:follow)
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td6 to have writer add utf8_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td6"
	use p1
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
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
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, NON-ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:follow:ICHSET="UTF-16")
	use p1
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	close p1
	; copy utf16_bom_head to p1
	set ^a="cp7"
	do wait("cp7done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td7 to have writer add utf16_bom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td7"
	use p1
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, NON-ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	; copy utf16_nobom_head to p1
	set ^a="cp8"
	do wait("cp8done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	set timebefore=$horolog
	write "setting ^a to td8 to have writer add utf16_nobom_tail to "_p1_" after a 5 sec delay",!
	set ^a="td8"
	use p1
	read x:90
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
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
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, ZERO TIMED READS UTF-8 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:follow)
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	close p1
	; since doing a zero timed read then make it complete
	; copy utf8_bom to p1
	set ^a="cp9"
	do wait("cp9done")
	open p1:(readonly:follow)
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, ZERO TIMED READS UTF-8 NO BOM",!
	write "**********************************",!
	; copy utf8_nobom to p1
	set ^a="cp10"
	do wait("cp10done")
	open p1:(readonly:follow)
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, ZERO TIMED READS UTF-16 WITH BOM",!
	write "**********************************",!
	write "create a null file and read with a timeout to show that it will not return an EOF",!
	open p1:(newversion:follow:ICHSET="UTF-16")
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	close p1
	;copy utf16_bom to p1
	set ^a="cp11"
	do wait("cp11done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	use $p

	write "**********************************",!
	write "READONLY, FOLLOW, ZERO TIMED READS UTF-16 NO BOM",!
	write "**********************************",!
	; copy utf16_nobom to p1
	set ^a="cp12"
	do wait("cp12done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1

	write "**********************************",!
	write "READONLY, x#n, FOLLOW, UNTIMED READS UTF-8",!
	write "**********************************",!
	; create file with 8 utf chars
	; copy utf8_nobom_noeol to p1
	set ^a="cp13"
	do wait("cp13done")
	open p1:(readonly:follow)
	zshow "d"
	use p1
	read x#5
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timebefore=$horolog
	write "setting ^a to td9 to have writer add 8 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td9"
	use p1
	read x#11
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x#11
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1

	write "**********************************",!
	write "READONLY, x#n, FOLLOW, UNTIMED READS UTF-16",!
	write "**********************************",!
	; create file with 4 utf-16 chars
	; copy utf16_nobom_noeol to p1
	set ^a="cp14"
	do wait("cp14done")
	open p1:(readonly:follow:ICHSET="UTF-16")
	zshow "d"
	use p1
	read x#3
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timebefore=$horolog
	write "setting ^a to td10 to have writer add 4 more chars to "_p1_" after a 5 sec delay",!
	set ^a="td10"
	use p1
	read x#5
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (5>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p1:nofollow
	use $p
	zshow "d"
	use p1
	read x#5
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p1
	set ^a="rdone"
	quit

writer(p)
	do savepid("utfwriter")
	set pp="apipe"
	; test is using a pipe device to start the mumps process "utfinit" in M mode instead of zsystem
	; no actual I/O is done over the pipe, but in case test cleanup is necessary, just killing
	; the writer process will also kill the child process.
	open pp:(comm="source $gtm_tst/$tst/u_inref/switch_chset_m.csh; $gtm_exe/mumps -r utfinit "_p:write)::"pipe"
	do wait("rdone")
	close pp
	quit

wait(avalue)
	new cnt
	set cnt=0
	for  quit:avalue=^a  do
	. hang 1
	. set cnt=1+cnt
	. if 1800'>cnt use $p write "no change in 30 min so exiting",! halt
	quit

results(x,expected)
	new %io
	set %io=$io
	set z=$zeof,za=$za,d=$device,t=$test
	use $p
	write "x= "_x_" length(x)= "_$length(x),!
	write "expect:",!
	write expected,!
	write "$device= "_d_" "_" $za= "_za_" $test= "_t_" $zeof= ",z,!
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
