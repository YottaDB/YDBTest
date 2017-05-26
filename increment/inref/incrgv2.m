incrgv2	;
	view "NOISOLATION":"^xglobalname"
	set ^xglobalname=1
	tstart ():serial
	write $incr(^xglobalname,1)
	tcommit
	quit
