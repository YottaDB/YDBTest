lockcl	;multiple clients, one holding the lock other one is waiting on
	; waiting for lockbcl to lock ^b
	s maxtime=60,found=0,timeout=0
	f  q:(found!timeout)  d
	. s x=$zsearch("lockedbcl.out")
	. if x="" d
	.. h 5
	.. s maxtime=maxtime-5
	.. if maxtime=0 s timeout=1
	. else  s found=1
	if timeout w "TEST-E-Timeout, lockbcl timed out!",!
	w "time: ",$H,!
	l ^b:10
	w $T,!
	w "it should not have gotten the lock",!,"(at ",$H,")",!,!
	W "now tell it to let go",!,"(at ",$H,")",!
	s ^bexitnow=1
	s h1=$E($H,7,12)
	l ^b:40
	w $T,!
	s h2=$E($H,7,12)
	w "now it should have gotten the lock",!,"(at ",$H,")",!
	w "The time it took the lock command to finish:",h2-h1,!
	w "it should be as long as the lockbcl sleeps after releasing the lock (which is 5 seconds now).",!
	s dif=h2-h1
	i dif>39 w "FAILED. Waited too long.",dif,!
	q
