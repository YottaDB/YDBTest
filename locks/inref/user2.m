user2 ;
	write "--------------------------------------------",!
	set unix=$zv'["VMS"
	if unix set zstr="/usr/local/bin/tcsh lkeinput.csh"
	else  set zstr="@lkechk.com"
	s ^result="TEST FAILED"
	s ^child="UP"
	for i=1:1:240 quit:$data(^parent)  h 1
	if i=240 w "Timed out: ^parent not set by user1!" set fail=$get(fail)+1
	write "P2, will now try to lock ^alongnam",!
	lock +^alongnam:15
	if $T=0 w "TEST-E-ERROR as lock expected but didn't acquire",! set fail=$get(fail)+1
	zsystem zstr
	write "P2, will now try to lock ^alongnamecheckingforlocks",!
	lock +^alongnamecheckingforlocks:15
	if $T=1 w "Got the lock ^alongnamecheckingforlocks but user1 is still holding the lock ^alongnamecheckingforlocks TEST FAILED",! set fail=$get(fail)+1
	zsystem zstr
	s ^donewithchecking="PID2 now done with checking"
	for i=1:1:240 quit:$data(^released)  h 1
	if i=240 w "Timed out: user1 hasn't released lock ^alongnamecheckingforlocks!" set fail=$get(fail)+1
	write "P2, will now try to lock ^alongnam",!
	lock +^alongnam:15
	if $T=0 w "TEST-E-ERROR as lock expected but didn't acquire",! set fail=$get(fail)+1
	zsystem zstr
	write "P2, will now try to lock ^alongnamecheckingforlocks",!
	lock +^alongnamecheckingforlocks:15
	if $T'=1 w "TEST-E-ERROR  could not lock ^alongnamecheckingforlocks",! set fail=$get(fail)+1
	if ""=$get(fail) s ^result="TEST PASSED"
	zsystem zstr
	if ^result="TEST PASSED" lock -^alongnamecheckingforlocks,^alongnam
	write "--------------------------------------------",!
	quit
