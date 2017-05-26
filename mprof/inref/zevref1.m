	; Valid test cases to check functionality of ZYERROR when set to entry 
	; references
     	; format of entryref : label+offset^module.

SUB1	w "Testing ZYERROR Label...",!
	s $zt="do ^ztraph"
	set $zyerror="SUB2" 
	kill x
	set x=x+1 ;bad line
	;
 	w "Testing ZYERROR Label+offset..."
        set x=0,$zyerror="SUB3+1"
	w 1/x ;bad line
	;
    	w "Testing ZYERROR Label+module..."
        set x="",$zyerror="lab^zeleaf"
	w @x ;bad line
	;
	w !,"Testing ZYERROR Label+offset+module..."
        set $zyerror="lab+1^zeleaf" kill x
	set x=x+1 ;bad line

	w "end of SUB1",!
        quit

SUB2    w "done(SUB2)",!
	do report^zeleaf
	w "end of SUB2",!
        quit

SUB3	goto SUB3+2	
	w "done(SUB3+1)",!
	do report^zeleaf
	w "end of SUB3",!
 	quit
