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
diskfollow
	; test disk reads for untimed, non-zero timed, zero timed reads with both nofollow and follow
	; this script supports the disk_follow.csh test in M mode
	set ^a=0
	set p="rwfile"
	do initfile(p)
	close p
	job reader^diskfollow(p):(output="reader.mjo":error="reader.mje")
	job writer^diskfollow(p):(output="writer.mjo":error="writer.mje")
	write "setting ^a to a",!
	set ^a="a"
	do wait("l")
	quit

reader(p)
	new x,timebefore,timeafter,elapsedtime
	do savepid("reader")
	do wait("a")
	write "**********************************",!
	write "READONLY, NOFOLLOW, UNTIMED READS",!
	write "**********************************",!
	open p:readonly
	zshow "d"
	use p
	read x
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	read x
	do results1(x,"$device= 1,Device detected EOF  $za= 9 $zeof= 1")
	use $p
	write "**********************************",!
	write "READONLY, NOFOLLOW, NON-ZERO TIMED READS",!
	write "**********************************",!
	zshow "d"
	use p:rewind
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
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1")
	close p
	open p:(readonly:follow)
	write "**********************************",!
	write "READONLY, FOLLOW, UNTIMED READS",!
	write "**********************************",!
	zshow "d"
	use p
	read x
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	use $p
	write "setting ^a to b to have writer add a line to "_p_" after a 5 sec delay",!
	set ^a="b"
	use p
	read x
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	use $p
	; have the writer split the line into 2 chunks with a 5 sec pause before and between them
	write "setting ^a to c to have writer add a line to "_p_" as 2 chunks with 5 sec delay before and between them",!
	set timebefore=$horolog
	set ^a="c"
	use p
	read x
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	use $p
	set timeafter=$horolog
	set elapsedtime=$$^difftime(timeafter,timebefore)
	if (10>elapsedtime) write "FAIL - elapsed time = ",elapsedtime,!
	; change to nofollow to get EOF
	write "use p:nofollow to read an EOF",!
	use p:nofollow
	use $p
	zshow "d"
	use p
	read x
	do results1(x,"$device= 1,Device detected EOF  $za= 9 $zeof= 1")
	close p

	; initialize the input file again
	do initfile(p)
	; tell the writer to close and reopen the file
	set ^a="d"
	do wait("e")
	open p:(readonly:follow)
	write "**********************************",!
	write "READONLY, FOLLOW, NON-ZERO TIMED READS",!
	write "**********************************",!
	zshow "d"
	use p
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 1 $zeof= 0")
	; read with no more data
	read x:1
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	use $p
	write "setting ^a to f to have writer add a partial line to "_p,!
	set ^a="f"
	do wait("g")
	use p
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
	set ^a="h"
	do wait("i")
	open p:(readonly:follow)
	write "**********************************",!
	write "READONLY x#n, FOLLOW, UNTIMED READS",!
	write "**********************************",!
	zshow "d"
	use p
	read x#10
	do results1(x,"$device= 0  $za= 0 $zeof= 0")
	u $p
	write "setting ^a to j to have writer wait 5 sec append 5 chars wait 5 sec and append 5 more",!
	set timebefore=$horolog
	set ^a="j"
	use p
	read x#10
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
	write "setting ^a to k",!
	set ^a="k"
	quit

writer(p)
	do savepid("writer")
	write p,!
	do wait("b")
	; wait 5 sec before writing to p so the reader will have to "follow" the input
	hang 5
	open p:append
	use p
	write "ABCDEFG",!
	use $p
	do wait("c")
	; wait 5 sec before writing CHUNK1 (no newline) then wait 5 sec before writing CHUNK2 (with newline)
	hang 5
	use p
	write "CHUNK1"
	hang 5
	write "CHUNK2",!
	do wait("d")
	; close p and reopen for append.  The file was initialized by the reader.
	close p
	open p:append
	; tell reader we are ready to write to the file
	write "setting ^a to e",!
	set ^a="e"
	do wait("f")
	; append ABCDEFG without a newline
	use p
	write "ABCDEFG"
	use $p
	write "setting ^a to g",!
	set ^a="g"

	; support read x#n
	do wait("h")
	close p
	do initnoeol(p)
	use $p
	write "setting ^a to i",!
	use p
	set ^a="i"
	do wait("j")
	; wait 5 sec before writing ABCDE (no newline) then wait 5 sec before writing FGHIJ (no newline)
	hang 5
	write "ABCDE"
	hang 5
	write "FGHIJ"
	do wait("k")
	set ^a="l"
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
	open p:newversion
	use p
	write "123456789",!
	close p
	quit

initnoeol(p)
	write "initialize with no eol: ",p,!
	open p:newversion
	use p
	write "1234567890"
	; leave it open so writer can add more without an eol
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
	new pid
	set pid=type_"_pid"
	open pid:newversion
	use pid
	write $job,!
	close pid
	quit
