locks1	; Locks regression test.  
		; Test locks :  storage ( i.e. invisible to the user )
		;		basic function
		;		timed response
		;		multiple user interaction
		;		multiple region interaction
	use 0 
	set cnt=120,$zt=""
	set unix=$zv'["VMS"
	write $zgbldir,!
	write "d TEST1",!  do TEST1^locks1
	write "d TEST2",!  do TEST2^locks1
	write "d TEST4",!  do TEST4^locks1
	write "d TEST5",!  do TEST5^locks1
	write "d TEST6",!  do TEST6^locks1
	write "d TEST7",!  do TEST7^locks1
	write "d TEST9",!  do TEST9^locks1
	write "d TEST10",!  do TEST10^locks1
	write "d TEST11",!  do TEST11^locks1
	write "d TEST12",!  do TEST12^locks1
	write "d d002014",!  do d002014^locks1
	quit

TEST1	set ^Fail=0
	kill ^X,^A
	set x=$test,^A(1,1)=1
	lock (^A,a)
	if x'=$test  do EXAM("Error in  1, untimed lock changed $test",$test,x)
	set ^(2)=2 if '$data(^A(1,2))  do EXAM("Error in 1, naked reference botched by lock",1,$data(^A(1,2)))
	set ^A=1,x=$o(^%)
	if x'="^A"  do EXAM("Error in 1, Locks stored between percent and A: ",^A,x)
	set x=$test
	lock
	if x'=$test  do EXAM("Error in 1, untimed lock changed $test",x,$test)
	if '^Fail write "1 PASS",!
	quit

TEST2	set ^Fail=0
	set ^ITEM="TEST2"
	kill ^X
	if unix do
	. job BASIC:(nodet:out="job2.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job BASIC:(nodet:out="job2.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "2 Job command timed out",! quit
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST2 timed out",!  set ^Fail=^Fail+1
	lock ^A:5
	if (('$test)!(^Fail))  do EXAM("Argumentless zdeallocate failed.",1,$test)
	; release locks, don't interfere with other tests
	lock
	quit

	; The intent of this test is to ensure that we don't wait too short or too
	; long when trying to obtain a lock with a time out, so the parent locks ^A
	; prior to forking off the child
TEST4
	set ^Fail=0
	set ^ITEM="TEST4"
	kill ^X
	lock ^A
	if unix do
	. job TIMETEST:(nodet:out="job4.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job TIMETEST:(nodet:out="job4.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "4 Job command timed out",! quit
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST4 timed out",!  set ^Fail=^Fail+1
	if '^Fail write "4 PASS",!
	; release locks, don't interfere with other tests
	lock
	quit

TEST5	set ^Fail=0
	set ^ITEM="TEST5"
	kill ^X
	lock ^A
	if unix do
	. job TIMEGET:(nodet:out="job5.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job TIMEGET:(nodet:out="job5.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "5 Job command timed out",! quit
	lock
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST5 timed out",!  set ^Fail=^Fail+1
	if '^Fail write "5 PASS",!
	quit

TEST6	set ^Fail=0
	set ^ITEM="TEST6"
	kill ^X
	lock ^A(1,1)
	if unix do
	. job PATHLOCK:(nodet:out="job6.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job PATHLOCK:(nodet:out="job6.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "6 Job command timed out",! quit
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST6 timed out",!  set ^Fail=^Fail+1
	if '^Fail write "6 PASS",!
	quit

TEST7	set ^Fail=0
	set ^ITEM="TEST7"
	kill ^X
	lock ^AC
	if unix do
	. job BACKOUT:(nodet:out="job7.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job BACKOUT:(nodet:out="job7.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "7 Job command timed out",! quit
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST7 timed out",!  set ^Fail=^Fail+1
	if '^Fail write "7 PASS",!
	quit

TEST9
	set ^Fail=0
	set ^ITEM="TEST9"
	kill ^X
	lock (^B,^C,^D)
	if unix do
	. job MULREGION:(nodet:out="job9.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job MULREGION:(nodet:out="job9.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "9 Job command timed out",! quit
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST9 timed out",!  set ^Fail=^Fail+1
	lock
	if '^Fail write "9 PASS",!
	quit

TEST10
	set ^Fail=0
	set ^ITEM="TEST10"
	write "Zallocate test ",!
	if unix set jobarg="ZALTEST:(nodet:out=""job10.log"":gbl=""mumps.gld""):30"
	else  set jobarg="ZALTEST:(nodet:out=""job10.log"":gbl=""mumps.gld"":startup=""startup.com""):30"
	zallocate ^X
	lock ^A
	set ^A=0
	zallocate (^B,^C)
	zallocate (^D)	; test to make sure that zallocate doesn't unlock inbetween
	job @jobarg
	if  job @jobarg
	if  job @jobarg
	if  job @jobarg
	else  write "10 Job command timed out",! quit
	zdeallocate ^X
	zdeallocate ^X ; test to make sure zdeallocate won't urp on non-existent locks
	for k=1:1:cnt quit:^A=4  hang 1
	if k=cnt write "TEST10-a timed out",!  set ^Fail=^Fail+1
	set ^A=""
	zdeallocate ^B
	for k=1:1:cnt  quit:$l(^A)=1  hang 1
	if k=cnt write "TEST10-b timed out",!  set ^Fail=^Fail+1
	zdeallocate ^A ; test to make sure zdeallocate doesn't zap locks
	zdeallocate ^D
	for k=1:1:cnt quit:$l(^A)'<2  hang 1
	if k=cnt write "TEST10-c timed out",!  set ^Fail=^Fail+1
	lock
	for k=1:1:cnt  quit:$l(^A)=3  hang 1
	if k=cnt write "TEST10-d timed out",!  set ^Fail=^Fail+1
	zdeallocate ^C
	for k=1:1:cnt  quit:$l(^A)=4  hang 1
	if k=cnt write "TEST10-e timed out",!  set ^Fail=^Fail+1
	if ^A'="1302" do EXAM("Zallocate test failure: ",1302,^A)
	if '^Fail write "10 PASS",!
	quit

TEST11
	set ^Fail=0
	set ^ITEM="TEST11"
	kill ^X
	lock ^A,^B,^C
	if unix do
	. job LISTLOCK:(nodet:out="job11.log":gbl="mumps.gld"):30 set dt=$test
	else  do
	. job LISTLOCK:(nodet:out="job11.log":gbl="mumps.gld":startup="startup.com"):30 set dt=$test
	if 'dt write "11 Job command timed out",! quit
	for k=1:1:cnt quit:$data(^X)  hang 1
	if k=cnt write "TEST11 timed out",!  set ^Fail=^Fail+1
	lock
	if '^Fail write "11 PASS",!
	quit

TEST12  ; C9J06-003144
	if 0
	write "Testing $T ",$test,!
	lock ^A
	lock +^A
	lock -^A:5
	set t=$test
	if $test write "12 PASS",!
	lock
	quit
	
d002014	; D9B12-002014 -- See TR/Outlook for details
	; test nested TP with lock rollback
	;
	new x,lstat
	set x=0
	lock ^a
	tstart ()
	lock +^a
	tstart ()
	lock +^a
	if x=0 set x=1 trestart
	trollback
	zsh "L":lstat
	if $data(lstat("L",1))=0 do error quit
	if lstat("L",1)'="LOCK ^a LEVEL=1" do error quit
	kill lstat("L",1)
	kill lstat("L",0) ; remove MLG,MLT line
	if $data(lstat)'=0 do error quit	 ; check no other lock was recorded
	;
	lock  ; to ensure we don't hold any locks at start
	set x=0
	tstart ()
	lock +^a
	tstart ()
	lock +^a
	if x=0 set x=1 trestart
	trollback
	new lstat
	zsh "L":lstat
	if $data(lstat("L",1))'=0 do error quit
	write "d002014 PASS",!
	quit

error	;
	write "d002014 FAILED",!
	zshow "*"
	quit

BACKOUT
	write "Backout Lock test ",^ITEM,!
	lock (^A,^AB,^AC):5 set x=$test
	if x write "  failed: truth despite an item being previously locked.",! set ^Fail=^Fail+1
	zallocate (^A,^AB,^AC):5 set x=$test
	if x write "  failed: truth despite an item being previously locked.",! set ^Fail=^Fail+1
	lock (^A,^AB):5 set x=$test
	if 'x write "  failed: Locks not acquired.",! set ^Fail=^Fail+1
	set ^X=1
	if '^Fail write "  PASS",!
	quit

BASIC	write "Basic test ",^ITEM,!
	zallocate (^A,a):5
	if '$test write "Lock release failed",! set ^Fail=^Fail+1
	zdeallocate
	set ^X=1
	if '^Fail write "  PASS",!
	quit

LISTLOCK
	write "List lock test ",^ITEM,!
	lock ^C:5
	if $test write "  error, should not have obtained lock ^C.",! set ^Fail=^Fail+1
	lock ^B:5 set x=$test
	if 'x write "  error, should have obtained lock ^B.",! set ^Fail=^Fail+1
	lock ^A:5 set x=$test
	if 'x write "  error, should have obtained lock ^A.",! set ^Fail=^Fail+1
	set ^X=1
	if '^Fail write "  PASS",!
	quit
MULREGION
	write "Multiple Regions test ",^ITEM,!
	lock ^B:10 set x=$test
	if x write "  failed.",! set ^Fail=^Fail+1 
	lock ^C:10 set x=$test
	if x write "  failed.",! set ^Fail=^Fail+1 
	lock ^D:10 set x=$test
	if x write "  failed.",! set ^Fail=^Fail+1 
	set ^X=1
	if '^Fail  write "  PASS",!
	quit
PATHLOCK
	write "Path Lock test ",^ITEM,!
	lock ^A:5 set x=$test
	if x write "  failed: locked ancestor global",! set ^Fail=^Fail+1
	lock ^A(1,1,1):5 set x=$test
	if x write "  failed: locked child 1 global",! set ^Fail=^Fail+1
	lock ^A(1,2):5 set x=$test
	if 'x write "  failed: locked child 2 global",! set ^Fail=^Fail+1
	lock ^A(2):5 set x=$test
	if 'x write "  failed: could not lock a non-path subscript",! set ^Fail=^Fail+1
	if '^Fail write "  PASS",!
	set ^X=1
	quit
TIMEGET
	write "Timed Lock Get ",^ITEM,!
	lock ^A:10 set x=$test
	set ^X=1
	if x do
	.	write "  PASS",! 
	else  do
	.	set ^Fail=^Fail+1
	quit

	; the parent has already locked ^A. we are testing that we don't
	; wait too short or too long for the timeout
TIMETEST
	write "Timing test ",^ITEM,!
	; choose a skip factor 1 to 5, otherwise this test will always take 55 seconds
	set skip=$random(5)+1
	write "Skip factor ",skip,!
	; if result is ever 1, then something cause the parent to drop the lock, stop the test
	for i=1:skip:10 do TRYLOCK quit:result
	set ^X=1
	if '^Fail write "  PASS",!
	quit
TRYLOCK
	write "Try lock ",^ITEM,!
	set passes=0
	; improve test resilience, try the lock at most 3 times in case of failures
	for rep=1:1:3 quit:passes  do
	. set start=$horolog
	. lock ^A:i
	. set result=$test,stop=$horolog
	. set tdiff=$$^difftime(stop,start)
	. set passes=1
	. if 'result,tdiff<(i-1) write "Error in time test, ",i," wait too short: ",tdiff," occurence ",$increment(tooshort),! set passes=0
	. if tdiff>(i+1) write "Error in time test, ",i," wait too long: ",tdiff," occurence ",$increment(toolong),! set passes=0 zshow "*":^TRYLOCK(i,rep)
	. if passes write "passes ",i," with ",tdiff,!,!
	. if 'passes write "fails ",i," with ",tdiff,!,!
	quit:passes  ; otherwise the test failed
	set ^Fail=^Fail+1
	quit
ZALTEST
	write "Zallocate test ",^ITEM,!
	lock ^X
	set x="^"_$c(65+^A),loc=^A,^A=^A+1
	lock @x
	set ^A=^A_loc
	write "  PASS",!
	quit

EXAM(lbl,corr,comp)
	write lbl,!
	write "     COMPUTED=",comp,!
	write "     CORRECT =",corr,!
	set ^Fail=^Fail+1
	quit

