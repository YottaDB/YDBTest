	; Valid test cases to check functionality of ZYERROR set using
	; environment variable

TST1	w "Testing ZYERROR Label...",!
	s $zt="do ^ztraph"
	kill x
	set x=x+1 ;bad line
	q
TST2 	w "Testing ZYERROR Label+offset..."
	s $zt="do ^ztraph"
        set x=0,$zyerr="SUB3+1" ; Note -: ZYERROR is defined :-
	w 1/x ;bad line
	q
TST3    w "Testing ZYERROR Label+module..."
	s $zt="do ^ztraph"
        set x=""
	w @x ;bad line
	q
TST4	w "Testing ZYERROR Label+offset+module..."
	s $zt="do ^ztraph"
	kill x
	set x=x+1 ;bad line
	q

SUB2    w "done(SUB2)",!
	do report^zeleaf
	w "end of SUB2",! q

SUB3	w "done(SUB3)",! goto SUB3+2	
	w "done(SUB3+1)",!
	do report^zeleaf
	w "end of SUB3",! q
