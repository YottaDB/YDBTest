cmmit ;
	s $ZTE=0
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=25
	f j=1:1:x d 
	. s ^ZTEDEF(j)=$$fib(j)
	;
	s ^done("ztedef")=1
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	q
	;
cmmitd 	;
	s $ZTE=1
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=25
	f j=1:1:x d 
	. s ^ZTEDEF(j)=$$fib(j)
	;
	s ^done("ztedef")=1
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	q
	;
rollbck	;
	s $ZTE=0
	tstart
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=15
	f j=1:1:x d 
	. s ^ZTEUNDEF(j)=$$fib(j)
	s ^done("ztendef")=1
	trollback
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
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
