multdef
	s $zint="do ^thrint"
	s $ZTE="4rethrow" ;evaluates to true, re-throws
	tstart ()
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^MULTI1(j)=$$fib(j)
	d ^thrint
	;
	f j=x+1:1:y d 
	. s ^MULTI1(j)=$$fib(j)
	s ^done("muldef")=1
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	s $ZTE=""
	w !,"----------------------------------------------------",!!
	q
muldefrb
	view "TRACE":1:"^TRACE"
	s $zint="do ^thrint"
	s $ZTE=4 
	tstart ()
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^MULTI2(j)=$$fib(j)
	d ^thrint
	;
	f j=x+1:1:y d 
	. s ^MULTI2(j)=$$fib(j)
	s ^done("muldefrb")=1
	trollback:$tlevel
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	view "TRACE":0:"^TRACE"
	w !,"----------------------------------------------------",!!
	q
	;
multndef
	s $zint="do ^uthrint"
	s $ZTE=0
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^MULTI3(j)=$$fib(j)
	d ^uthrint
	;
	f j=x+1:1:y d 
	. s ^MULTI3(j)=$$fib(j)
	s ^done("mulundef")=1
	;
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	w !,"----------------------------------------------------",!!
	q
	;
mundefrb
	view "TRACE":1:"^TRACE"
	s $zint="do ^uthrint"
	s $ZTE="norethrow"  ;evaluates to false, no re-throws
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^MULTI4(j)=$$fib(j)
	d ^uthrint
	;
	f j=x+1:1:y d 
	. s ^MULTI4(j)=$$fib(j)
	s ^done("mundefrb")=1
	;
	trollback:$tlevel
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	view "TRACE":0:"^TRACE"
	w !,"----------------------------------------------------",!!
	q
	;
fib(n)
	n fib s fib=n
	s ^fib(0)=0,^fib(1)=1
	s fib(0)=0,fib(1)=1
	if n'>0 q fib
	f i=2:1:n d
	. s ^fib(i)=^fib(i-1)+^fib(i-2)
	s val=^fib(n)
	q val
	;
