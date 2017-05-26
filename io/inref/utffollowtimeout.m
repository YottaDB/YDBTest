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
utffollowtimeout
	; test disk read follow timeout interval
	; this script supports the diskfollow_timeout.csh test in UTF mode
	; the following files were created by utftimeoutinit.m:
	; utf8_timeout_with_bom, utf8_timeout_just_bom, utf8_timeout_no_bom, utf16_timeout_with_bom,
	; utf16_timeout_with_bom, utf16_timeout_just_bom
	;
	; The reader job is used to test various forms of reads with timeout.  The writer job is a coroutine
	; which starts utftimeoutinit.m via a pipe device.  The global variable ^a is used to synchronize the behavior
	; of these 2 coroutines.  For instance, the reader job sets ^a to "cp1" which instructs utftimeoutinit to
	; write characters into the utftimeoutfile to be read by the reader job.
	;
	; Similar coroutine code exists in:
	;	utffixfollow.m which uses utffixinit.m
	;	utffollowtimeout.m which uses utftimeoutinit.m
	;
	write "setting ^a to a",!
	set ^a="start"
	set p="utftimeoutfile"
	job reader^utffollowtimeout(p):(output="utfreader_timeout.mjo":error="utfreader_timeout.mje")
	job writer^utffollowtimeout(p):(output="utfwriter_timeout.mjo":error="utfwriter_timeout.mje")
	set ^Zreadcnt(p)=0
	set ^NumIntrSent(p)=0
	job sendintr^utffollowtimeout(p):(output="utfsendintr_timeout.mjo":error="utfsendintr_timeout.mje")
	do wait("timeoutrdone")
	quit

reader(p)
	set $Zint="Set ^Zreadcnt("""_p_""")=^Zreadcnt("""_p_""")+1"
	new x,dh1,dh2
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	do savepid("utfreader_timeout")
	do wait("initdone")
	write "**********************************",!
	write "NON-FIXED MODE READ FOLLOW WITH TIMEOUT UTF TESTS",!
	write "**********************************",!,!
	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-8 NULL FILE",!
	write "**********************************",!
	open p:(newversion:follow:key=key_" "_iv)
	zshow "d"
	use p
	for i=1:1:2 do
	. ; timeout a couple of times with an empty file
        . set time1=$$getTime($test)
	. read x:1
        . set time2=$$getTime($test)
	. do prnttimeout(1,time1,time2,$test)
	. do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-16 NULL FILE",!
	write "**********************************",!
	open p:(newversion:readonly:follow:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	use p
	for i=1:1:2 do
	. ; timeout a couple of times with an empty file
	. set time1=$$getTime($test)
	. read x:1
	. set time2=$$getTime($test)
	. do prnttimeout(1,time1,time2,$test)
	. do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-8 NO BOM",!
	write "**********************************",!
	open p:(newversion:readonly:follow:key=key_" "_iv)
	zshow "d"
	write "setting ^a to td1 to have writer add utf8_timeout_no_bom to "_p_" after a 5 sec delay",!
	set ^a="td1"
	use p
	set time1=$$getTime($test)
	read x:10
	set time2=$$getTime($test)
	do prnttimeout(10,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-8 WITH BOM",!
	write "**********************************",!
	open p:(newversion:readonly:follow:key=key_" "_iv)
	zshow "d"
	write "setting ^a to td2 to have writer add utf8_timeout_just_bom to "_p_" after a 5 sec delay",!
	write "then add utf8_timeout_no_bom to "_p_" after a 5 sec delay",!
	set ^a="td2"
	use p
	set time1=$$getTime($test)
	read x:15
	set time2=$$getTime($test)
	do prnttimeout(15,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-16 WITH BOM",!
	write "**********************************",!
	open p:(newversion:readonly:follow:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	write "setting ^a to td3 to have writer add utf16_timeout_just_bom to "_p_" after a 5 sec delay",!
	write "then add utf16_timeout_no_bom to "_p_" after a 5 sec delay",!
	set ^a="td3"
	use p
	set time1=$$getTime($test)
	read x:15
	set time2=$$getTime($test)
	do prnttimeout(15,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-8 WITH NO DELAY BETWEEN BOM AND DATA",!
	write "**********************************",!
	open p:(newversion:readonly:follow:key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp1 to have writer copy utf8_timeout_with_bom to "_p,!
	set ^a="cp1"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-16 WITH NO DELAY BETWEEN BOM AND DATA",!
	write "**********************************",!
	open p:(newversion:readonly:follow:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp2 to have writer copy utf16_timeout_with_bom to "_p,!
	set ^a="cp2"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-8 WITH BOM ONLY",!
	write "**********************************",!
	open p:(newversion:readonly:follow:key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp3 to have writer copy utf8_timeout_just_bom to "_p,!
	set ^a="cp3"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "READ FOLLOW WITH TIMEOUT UTF-16 WITH BOM ONLY",!
	write "**********************************",!
	open p:(newversion:readonly:follow:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp4 to have writer copy utf16_timeout_just_bom to "_p,!
	set ^a="cp4"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write !,"**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF TESTS",!
	write "**********************************",!,!
	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-8 NULL FILE",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:key=key_" "_iv)
	zshow "d"
	use p
	for i=1:1:2 do
	. ; timeout a couple of times with an empty file
	. set time1=$$getTime($test)
	. read x:1
	. set time2=$$getTime($test)
	. do prnttimeout(1,time1,time2,$test)
	. do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-16 NULL FILE",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	use p
	for i=1:1:2 do
	. ; timeout a couple of times with an empty file
	. set time1=$$getTime($test)
	. read x:1
	. set time2=$$getTime($test)
	. do prnttimeout(1,time1,time2,$test)
	. do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-8 NO BOM",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:key=key_" "_iv)
	zshow "d"
	write "setting ^a to td4 to have writer add utf8_timeout_no_bom to "_p_" after a 5 sec delay",!
	set ^a="td4"
	use p
	set time1=$$getTime($test)
	read x:10
	set time2=$$getTime($test)
	do prnttimeout(10,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-8 WITH BOM",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:key=key_" "_iv)
	zshow "d"
	write "setting ^a to td5 to have writer add utf8_timeout_just_bom to "_p_" after a 5 sec delay",!
	write "then add utf8_timeout_no_bom to "_p_" after a 5 sec delay",!
	set ^a="td5"
	use p
	set time1=$$getTime($test)
	read x:15
	set time2=$$getTime($test)
	do prnttimeout(15,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-16 WITH BOM",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	write "setting ^a to td6 to have writer add utf16_timeout_just_bom to "_p_" after a 5 sec delay",!
	write "then add utf16_timeout_no_bom to "_p_" after a 5 sec delay",!
	set ^a="td6"
	use p
	set time1=$$getTime($test)
	read x:15
	set time2=$$getTime($test)
	do prnttimeout(15,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-8 WITH NO DELAY BETWEEN BOM AND DATA",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp5 to have writer copy utf8_timeout_with_bom to "_p,!
	set ^a="cp5"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-16 WITH NO DELAY BETWEEN BOM AND DATA",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp6 to have writer copy utf16_timeout_with_bom to "_p,!
	set ^a="cp6"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 3",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-8 WITH BOM ONLY",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp7 to have writer copy utf8_timeout_just_bom to "_p,!
	set ^a="cp7"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "**********************************",!
	write "FIXED MODE READ FOLLOW WITH TIMEOUT UTF-16 WITH BOM ONLY",!
	write "**********************************",!
	open p:(newversion:readonly:follow:fixed:ICHSET="UTF-16":key=key_" "_iv)
	zshow "d"
	write "setting ^a to cp8 to have writer copy utf16_timeout_just_bom to "_p,!
	set ^a="cp8"
	use p
	set time1=$$getTime($test)
	read x:5
	set time2=$$getTime($test)
	do prnttimeout(5,time1,time2,$test)
	do results(x,"$device= 0  $za= 0 $test= 0 $zeof= 0 $x= 0",0)
	do usenofollow(p)
	read x
	do results(x,"$device= 1,Device detected EOF  $za= 9 $test= 1 $zeof= 1 $x= 0",1)
	close p

	write "setting ^a to timeoutrdone",!
	set ^a="timeoutrdone"
	quit

writer(p)
	do savepid("utfwriter_timeout")
	set pp="apipe"
	; test is using a pipe device to start the mumps process "utftimeoutinit" in M mode instead of zsystem
	; no actual I/O is done over the pipe, but in case test cleanup is necessary, just killing
	; the writer process will also kill the child process.
	open pp:(comm="unsetenv gtm_chset; $gtm_exe/mumps -r utftimeoutinit "_p:write)::"pipe"
	do wait("timeoutrdone")
	close pp
	quit

sendintr(type)
	do savepid("utfsendintr_timeout")
	; randomly decide whether to send interrupts to the reader
	if $Random(2) do savepid("utfsendintr_timeout_not") quit
	write "type = ",type,!
	set ^signum=$$^signals
	write "signum = ",^signum,!
	set ^loopcnt(type)=0
	do wait("initdone")
	; get the reader pid
	set pid="utfreader_timeout_pid"
	open pid:readonly
	use pid
	read readerpid
	use $p
	write "readerpid = ",readerpid,!
	set intfrequency=.5
	write "intfrequency = ",intfrequency,!
	; quit if in this loop for 20 min
	for  do  quit:("timeoutrdone"=^a)!(1200=^loopcnt(type))
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

results(x,expected,test1)
	; x is the variable to be printed
	; expected is the expected output
	; if test1 is non-zero then it is set $test to 1 in output as it is a non-timed read
	new %io
	set %io=$io
	set z=$zeof,za=$za,d=$device,t=$test,dx=$x
	; override $test if test1 set
	if test1 set t=1
	use $p
	write "x= "_x_" length(x)= "_$length(x),!
	write "expect:",!
	write expected,!
	write "$device= "_d_" "_" $za= "_za_" $test= "_t_" $zeof= "_z_" $x= ",dx,!
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
