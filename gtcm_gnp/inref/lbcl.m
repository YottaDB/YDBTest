lbcl	; lock ^b at client
	; and hang around
	;now set again some global variables
	 s unix=$zv'["VMS"
	if 'unix job lock^lbcl:(detached:startup="startup.com":output="lbcl.out":error="lbcl_err.out") q
lock    s fn="lbcl.pid"
        o fn
	u fn
	w $$FUNC^%DH($J,0),!
	c fn
        k ^bexitnow
	s fname="trylockb.out"
	o fname
	u fname
	w "I am going to lock ^b ..."
	c fname
	w "I will now lock ^b...(at ",$H,")",!
	l ^b
	i '$T w "Could not get the lock.ERROR. This routine should have gotten the lock.",!
	w "I did lock ^b (at ",$H,")",!
	f i=1:1:1000 q:$D(^bexitnow)  h 10
	w "I was told to leave at ",$H,!,"Bye...",!
	q
