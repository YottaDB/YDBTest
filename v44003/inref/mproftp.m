mproftp(timeout,longwait);
	view "trace":1:"^mproftp"
	if '$data(^MAXTRIES) set ^MAXTRIES=3 ; Try upto 3 times if it fails (might be due to load)
	d init(timeout,longwait)
	set $ztrap="d ^mprtpzt  halt"
	set passed=0
	tstart ():serial 
	set tbegtp=$h
	f i=1:1:10000000 set now=$h  set passed=$$^difftime(now,tbegtp)  set ^dummy(i#10)=$j(i*i/3.14,200)  hang 0.1  DO  q:passed>^longwait
	W "Loop finished at i=",i,!
	w "Message inside TP:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!    
	tcommit
	w "Message after TC: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!   
	d finish
	q
examinf(i)	s t=i;
	w "The number of executions:",!
	f  s t=$Q(@t) q:t=""  d
	. s value=@t
	. s no=$P(value,":",1)
	. s ut=$P(value,":",2)
	. s st=$P(value,":",3)
        . s ct=$P(value,":",4)
	. i t["FOR_LOOP" s no="1 FOR_LOOP"
	. i t["difftime" q
        . i ((ct="")&(ut'="")&(st'="")) q
	. w t,": ",no
	. i (no=0) W "     INVALID COUNT"
	. i (ut<0) W " User Time ",ut," Invalid"
	. i (st<0) W " System Time ",st," Invalid"
	. w !
	q
init(timeout,longwait)	;
	SET ^timeout=timeout
	SET ^longwait=longwait
	SET ^delta=4
	SET $ztrap="d ^mprtpzt  halt"
	SET $zmaxtptime=timeout
	q
	;
ERROR   SET $ZT=""
	W !,"ZSHOW ""*""",!
	ZSHOW "*"
        ZM +$ZS
	if $tlevel trollback
	Q
finish	;
	W !,"Sorry, we should not be here. Something is wrong...",!
	s tendtp=$h
	s elaptime=$$^difftime(tendtp,tbegtp)
	w "Transaction finished in ",elaptime," sec",!
	if elaptime'<longwait  w "Did not time out, TEST FAILED",!
	else  w "Unknown ERROR occured. TEST FAILED",!
	ZSHOW "*"
	q
