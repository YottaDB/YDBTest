readtst(timeout,longwait)	;
	d ^init(timeout,longwait)    
        tstart ():serial
	s tbegtp=$h
	read dummy:longwait
        w "Message inside TS/TC block:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
        tcommit
        w "Message after TS/TC block: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	d ^finish
	q
