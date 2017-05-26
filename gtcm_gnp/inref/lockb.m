lockb	; Lock ^b and stay around
	; ^d is local (on this host)
	; a,b are local var.
	w "Entered at: "_$zdate($H,"24:60:SS"),!
	w "PID:",$J,!
	k ^bexitnow
	L (^b,^d,a)
	za ^b,^d,b
	w "ZAllocated at: "_$zdate($H,"24:60:SS"),!
	f i=1:1:1000 q:$D(^bexitnow)  h 10
	w "going out...",!
