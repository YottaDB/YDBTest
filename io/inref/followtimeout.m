;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
followtimeout
	; test disk read follow timeout interval
	; this script supports the diskfollow_timeout.csh test in M mode
	set ^a=0
	set p="timeoutfile"
	do initfile(p)
	job reader^followtimeout(p):(output="reader_timeout.mjo":error="reader_timeout.mje")
	job writer^followtimeout(p):(output="writer_timeout.mjo":error="writer_timeout.mje")
	write "setting ^a to a",!
	set ^a="a"
	set ^Zreadcnt(p)=0
	set ^NumIntrSent(p)=0
	job sendintr^followtimeout(p):(output="sendintr_timeout.mjo":error="sendintr_timeout.mje")
	do wait("l")
	quit

reader(p)
	set $Zint="Set ^Zreadcnt("""_p_""")=^Zreadcnt("""_p_""")+1"
	new x,timebefore,timeafter,elapsedtime
	do savepid("reader_timeout")
	do wait("a")
	; set ^a to a1 to let interrupts start
	write "setting ^a to a1 to have sendintr start sending interrupts",!
	set ^a="a1"
	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT",!
	write "**********************************",!
	open p:(readonly:follow)
	zshow "d"
	use p
	for i=1:1:2 do
	. ; timeout a couple of times with an empty file
        . set time1=$$getTime($test)
	. read x:1
        . set time2=$$getTime($test)
	. do prnttimeout(1,time1,time2,$test)
	do wait("a2")

	u $p
	write "setting ^a to b to have writer add chars to "_p_" after a 5 sec delay",!
	set ^a="b"
	use p
        set time1=$$getTime($test)
	read x:10
	set time2=$$getTime($test)
	do prnttimeout(10,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	do usenofollow(p)
	read x
	do results1(x,"$device= 1,Device detected EOF  $za= 9 $zeof= 1")
	close p

	write "**********************************",!
	write "READ FOLLOW FIXED WITH TIMEOUT",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed)
	zshow "d"
	use p
	for i=1:1:2 do
	. ; timeout a couple of times with an empty file
        . set time1=$$getTime($test)
	. read x:1
        . set time2=$$getTime($test)
	. do prnttimeout(1,time1,time2,$test)

	u $p
	write "setting ^a to c to have writer add chars to "_p_" after a 5 sec delay",!
	set ^a="c"
	use p
        set time1=$$getTime($test)
	read x:10
	set time2=$$getTime($test)
	do prnttimeout(10,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0")
	do usenofollow(p)
	read x
	do results1(x,"$device= 1,Device detected EOF  $za= 9 $zeof= 1")
	close p
	write "setting ^a to k",!
	set ^a="k"
	quit

writer(p)
	do savepid("writer_timeout")
	write p,!
	do wait("b")
	; wait 5 sec before writing to p
	hang 5
	open p:append
	use p
	write "ABCDEFG"
	; close p since reader will create file again using newversion
	set $x=0
	close p
	do wait("c")
	; wait 5 sec before writing to p
	hang 5
	open p:append
	use p
	write "HIJKLMN"
	do wait("k")
	set ^a="l"
	quit

sendintr(type)
	do savepid("sendintr_timeout")
	; randomly decide whether to send interrupts to the reader
	if $Random(2) do savepid("sendintr_timeout_not") do wait("a1") set ^a="a2" quit
	write "type = ",type,!
	set ^signum=$$^signals
	write "signum = ",^signum,!
	set ^loopcnt(type)=0
	do wait("a1")
	set ^a="a2"
	; get the reader pid
	set pid="reader_timeout_pid"
	open pid:readonly
	use pid
	read readerpid
	use $p
	write "readerpid = ",readerpid,!
	set intfrequency=.5
	write "intfrequency = ",intfrequency,!
	; quit if in this loop for 20 min
	for  do  quit:("l"=^a)!(1200=^loopcnt(type))
	. if '$ZSigproc(readerpid,^signum) set ^NumIntrSent(type)=^NumIntrSent(type)+1
	. hang intfrequency
	. set ^loopcnt(type)=^loopcnt(type)+1
	write "^loopcnt = ",^loopcnt(type),!
	if (1200=^loopcnt(type)) write "^loopcnt reached 1200 - setting ^a to l!",!
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

initfile(p)
	write "initialize ",p,!
	open p:newversion
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
	new pid
	set pid=type_"_pid"
	open pid:newversion
	use pid
	write $job,!
	close pid
	quit

prnttimeout(expected,time1,time2,dollartest)
	new %io,dsec
	set %io=$io
	use $p
	set dsec=(time2-time1)/1E6
	if expected'>dsec write "PASSED: timeout disk read= "_dsec_" minimum= "_expected,!
	else  write "FAILED: timeout disk read= "_dsec_" minimum= "_expected,!
	use %io
	if dollartest
	quit

usenofollow(p)
	new %io
	set %io=$io
	use $p
	write "use p:nofollow to read an EOF",!
	use p:nofollow
	use $p
	zshow "d"
	use %io
	quit

getTime(dollartest)
	; Invoke the gettimeofday() routine via an external call.
	new tvSec,tvUsec,errNum
	if $&gtmposix.gettimeofday(.tvSec,.tvUsec,.errNum)
	if dollartest
	; return the current time in microseconds.
	quit (1E6*tvSec)+tvUsec
