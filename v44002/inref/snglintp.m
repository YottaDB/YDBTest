cmmit 
	s $zint="d ^uthrint"
	s $ZTE="norethrow"
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^sngcmmit(j)=$$fib(j)
	;
	d ^uthrint
	;
	f j=x+1:1:y d 
	. s ^sngcmmit(j)=$$fib(j)
	s ^done("sngcmtt")=1
	;
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	q
	;
cmmitd 
	s $zint="d ^thrint"
	s $ZTE="1rethrow"
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^sngcmmd(j)=$$fib(j)
	;
	d ^thrint
	;
	f j=x+1:1:y d 
	. s ^sngcmmd(j)=$$fib(j)
	s ^done("sngcmmd")=1
	;
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	q
	;
rollbck ;
	view "TRACE":1:"^TRACE"
	s $zint="d ^uthrint"
	s $ZTE=0
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^sngrlbk(j)=$$fib(j)
	;
	d ^uthrint
	;
	f j=x+1:1:y d 
	. s ^sngrlbk(j)=$$fib(j)
	s ^done("sngrlbk")=1
	;
	trollback
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	view "TRACE":0:"^TRACE"
	q
	;
rollbckd ;
	view "TRACE":1:"^TRACE"
	s $zint="d ^thrint"
	s $ZTE=1
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d 
	. s ^sngrlbkdd(j)=$$fib(j)
	;
	d ^thrint
	;
	f j=x+1:1:y d 
	. s ^sngrlbkdd(j)=$$fib(j)
	s ^done("sngrlbkdd")=1
	;
	trollback
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	view "TRACE":0:"^TRACE"
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
