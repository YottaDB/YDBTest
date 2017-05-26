	; Invalid test cases to check functionality of ZYERROR when an
	; error occurs again in the ZYERROR handler.

TST1	w "Testing ZYERROR Label...",!
	s $zt="do ^ztraph"
	set $zyerror="SUB2" 
	kill x
	set x=x+1 ;bad line
	;
 	w "Testing ZYERROR Label+offset...",!
        set $zyerror="SUB3+1",x=0
	w 1/x,! ;bad line
	;
	w "end of TST1",!
        quit

TST2	w "Testing ZYERROR with command...",!
	s $zt="do ^ztraph"
	set $zyerror="set x=10" 
	kill x
	w x,! ;bad line
 	q	

TST3	;
        w "Testing ZYERROR @(Label+offset)...",!
	s $zt="do ^ztraph"
	set ind="lab+1",$zyerror="@ind^zeleaf"
	kill x
	set x=x+1 ;bad line
	q
TST4    ;
        w "Testing ZYERROR @(offset^module)...",!
	s $zt="do ^ztraph"
	set ind="+1^zeleaf",$zyerror="lab@ind"
	kill x
	set x=x+1 ;bad line
	q

SUB2    w "done(SUB2)",! s $zyerr="DEAD+0"
	do report^zeleaf
	kill x
	set x=x+1 ;badline again!!
	w "end of SUB2",!
        quit

SUB3	goto SUB3+2	
	w "done(SUB3+1)",! s $zyerr="DEAD"
	do report^zeleaf
	kill x
	set x=x+1 ;badline again!!
	w "end of SUB3",!
 	quit

DEAD	w "should not reach here",!
	q
