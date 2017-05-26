lckspeed	; drive inctest
	L +^permit
	set ^totdata=^size
	SET jobcnt=^jobcnt
	SET top=^totdata
	set timeout=top
	set jmaxwait=0
	set jmjoname="inclock"
	do ^job("^inclock("_top_")",jobcnt,"""""")
	L -^permit
	SET et1=$h
	H 0
	H 2
	L +^permit:timeout
	IF $t'=1 W "SPEED_TEST TIME OUT, TEST FAILED",!  Q
	SET et2=$h
        SET ^elaptime(^image,^typestr,^jnlstr,^typestr,^order,"PARENT",^run)=$$^difftime(et2,et1)
	do wait^job
	Quit
