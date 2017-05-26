difftime(x,y)	; diff the two times input ($H format) to return (in seconds) x-y
	SET xpiece1=$piece(x,",")
	SET xpiece2=$piece(x,",",2)
	SET ypiece1=$piece(y,",")
	SET ypiece2=$piece(y,",",2)
	if (xpiece1=ypiece1)  set timediff=xpiece2-ypiece2
	else  set timediff=(xpiece1-ypiece1)*24*60*60+(xpiece2-ypiece2)
	; Negative time is possible only when the local time gets switched from DST to normal,
	; exactly between noting down the start time and end time. Add 3600 to timediff
	if (timediff<0) do
	.	set timediff=timediff+3600
	; With normally small timeouts, an elapsed time of more than 3600 is not expected.
	; Possibly the local time was switched from normal to DST between noting down the start time and end time. 
	; Subtract 3600 from timediff
	; But since this is possible that the timeout exceeded 1 hour and we would want to catch that,don't implement it
	q (timediff)
