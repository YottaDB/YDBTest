lockbcl	; Lock ^b and stay around
	; a,b are local var.
	 s unix=$zv'["VMS"
         if 'unix job lock^lockbcl:(detached:startup="startup.com":output="lockbcl.out":error="lockbcl_err.out") q
lock    w "This client will lock ^b, ^d, a, and b now",!
	k ^bexitnow
	w "Locking...",!
	s h1=$E($H,7,12)
	w "Time: ",$H,!
	;L (^b(1),^d,a,b)
	L (^b,^d,a,b)
	s h2=$E($H,7,12)
	w "Locked (hopefully)...(at ",h2-h1,")",!
	s fname="lockedbcl.out"
	o fname
	u fname
	w "I locked ^b, ^d, a and b",!
	c fname
	f i=1:1:10000 q:$D(^bexitnow)  h 1
	s h3=$E($H,7,12)
	w "I was told to let go...(at ",h3-h1,")",!
	h 5	; sleep 5 secs before exiting
	s h4=$E($H,7,12)
	w "Bye then. (at ",$H,")",!
