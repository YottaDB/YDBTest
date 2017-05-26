	; Valid test cases to check functionality of ZYERROR when set to entry 
	; references
     	; format of entryref : label+offset^module.

SUB1	w "Testing ZYERROR Label^module..."
	s $zt="do ^ztraph"
	set $zyerror="SUB2^zevref2" 
	kill x
	set x=x+1 ;bad line
	;
	w "end of SUB1",!
        quit

SUB2    w "done(SUB2)",!
	do report^zeleaf
	w "end of SUB2",!
        quit
