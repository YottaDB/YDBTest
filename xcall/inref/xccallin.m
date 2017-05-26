xccallin ;
	 ;
	 ; Initiliaze the timer routines.
	do &timers^init()
	set before=$H
	; Now sleep for 10 secs
	do &timers^tstslp(10000)
	set after=$H
	;w !,"Time Elapsed =",after - before,!
	do &timers^tsttmr(1000,10000)
	q

