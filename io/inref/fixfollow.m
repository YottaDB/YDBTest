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
fixfollow
	; test disk reads for timed, non-zero timed, zero timed reads with both nofollow and follow
	; this script supports the disk_follow.csh test in M mode
	set ^a=0
	set p="rwfile"
	do initfile(p)
	close p
	job reader^fixfollow(p):(output="fixreader.mjo":error="fixreader.mje")
	job writer^fixfollow(p):(output="fixwriter.mjo":error="fixwriter.mje")
	write "setting ^a to a",!
	set ^a="a"
	do wait("h")
	write "setting ^a to i",!
	set ^a="i"
	quit

reader(p)
	new x,timebefore,timeafter,elapsedtime
	do savepid("fixreader")
	do wait("a")
	write "**********************************",!
	write "READONLY, NOFOLLOW, UNTIMED READS",!
	write "**********************************",!
	open p:(readonly:fixed)
	zshow "d"
	use p:(width=5)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, NON-ZERO TIMED READS",!
	write "**********************************",!
	zshow "d"
	use p:rewind
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, ZERO TIMED READS",!
	write "**********************************",!
	zshow "d"
	use p:rewind
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	open p:(fixed:readonly:follow)
	write "**********************************",!
	write "READONLY, FOLLOW, UNTIMED READS",!
	write "**********************************",!
	zshow "d"
	use p:(width=5)
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	write "setting ^a to b to have writer add a 0 to "_p_" after a 5 sec delay",!
	set ^a="b"
	use p
	; this read will hang until the extra char ("0") is written to the file
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	; have the writer delay 5 seconds add ABC delay 5 more sec and add EF
	use $p
	write "setting ^a to c to have writer delay 5 sec add ABC, delay 5 sec and add EF to "_p,!
	set timebefore=$horolog
	set ^a="c"
	use p
	read x
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (10>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; $test not changed in untimed read so force it to 1 for the expected output
	if 1
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p:nofollow
	use $p
	zshow "d"
	use p
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	; initialize the input file again
	do initfile(p)
	open p:(readonly:fixed:follow)
	write "**********************************",!
	write "READONLY, FOLLOW, NON-ZERO TIMED READS",!
	write "**********************************",!
	zshow "d"
	use p:(width=5)
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	; read with partial data
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	; read with no more data
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	use $p
	write "use p:nofollow to read an EOF",!
	use p:nofollow
	use $p
	zshow "d"
	use p
	read x:1
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	; just rewind it, but add follow just for a check of use
	use p:(rewind:follow)
	use $p
	write "**********************************",!
	write "READONLY, FOLLOW, ZERO TIMED READS",!
	write "**********************************",!
	zshow "d"
	use p
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	; read the partial line
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	; read with no more data
	read x:0
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	use $p
	write "use p:nofollow to read an EOF",!
	use p:nofollow
	use $p
	zshow "d"
	use p
	read x:0
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p

	; tell the writer to initialize the file with no eol and 10 chars
	set ^a="d"
	do wait("e")
	open p:(readonly:fixed:follow)
	write "**********************************",!
	write "READONLY x#n, FOLLOW, UNTIMED READS",!
	write "**********************************",!
	zshow "d"
	use p
	read x#5
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	use $p
	write "setting ^a to f to have writer wait 5 sec append 5 chars wait 5 sec and append 5 more",!
	set timebefore=$horolog
	set ^a="f"
	use p
	read x#15
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (10>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	write "use p:nofollow to read an EOF",!
	use p:nofollow
	use $p
	zshow "d"
	use p
	read x#10
	do results1(x,"$device= 1,Device detected EOF  $za= 9 $zeof= 1")
	close p
	write "setting ^a to g to tell writer we are done",!
	set ^a="g"
	quit

writer(p)
	do savepid("fixwriter")
	write p,!
	do wait("b")
	; wait 5 sec before writing to p so the reader will have to "follow" the input
	hang 5
	open p:(fixed:append)
	use p
	write "0"
	use $p
	do wait("c")
	; wait 5 sec before writing ABC then wait 5 sec before writing EF
	hang 5
	use p
	write "ABC"
	hang 5
	write "EF"

	; support read x#n
	do wait("d")
	close p
	do initnoeol(p)
	write "setting ^a to e",!
	open p:(fixed:append)
	use p
	set ^a="e"
	do wait("f")
	; wait 5 sec before writing ABCDE (no newline) then wait 5 sec before writing FGHIJ (no newline)
	hang 5
	write "ABCDE"
	hang 5
	write "FGHIJ"
	do wait("g")
	set ^a="h"
	quit



	set ^a="e"
	quit

wait(avalue)
	new cnt
	set cnt=0
	for  quit:avalue=^a  do
	. hang 1
	. set cnt=1+cnt
	. if 1800'>cnt use $p write "no change in 30 min so exiting",! halt
	quit

initfile(p)
	write "initialize ",p,!
	open p:(fixed:newversion)
	use p:(width=9)
	write "123456789"
	close p
	quit

initnoeol(p)
	write "initialize with no eol: ",p,!
	open p:(fixed:newversion)
	use p
	write "1234567890"
	; set $x to zero so a close won't add an eol
	set $x=0
	close p
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

results1(x,expected)
	new %io
	set %io=$io
	set z=$zeof,za=$za,d=$device
	use $p
	write "x= "_x_" length(x)= "_$length(x),!
	write "expect:",!
	write expected,!
	write "$device= "_d_" "_" $za= "_za_" $zeof= ",z,!
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
