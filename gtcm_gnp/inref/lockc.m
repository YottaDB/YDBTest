lockc	; Lock c and stay around
	w "PID:",$J,!
	w "Entered at: "_$zdate($H,"24:60:SS"),!
	k ^cexitnow
	L ^c,^d
	za ^c,^d,a,b
	w "ZAllocated at: "_$zdate($H,"24:60:SS"),!
	f i=1:1:1000 q:$D(^cexitnow)  h 10
