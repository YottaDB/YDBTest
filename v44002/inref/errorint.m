errcmmt
	s $zint="do ^erthrint"
	s $ZTE=1
	tstart ():serial
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d
	. s ^ERRCMT(j)=$$fib(j)
	d ^erthrint
	;
	f j=x+1:1:y d
	. s ^ERRCMT(j)=$$fib(j)
	s ^done("errcmt")=1
	;
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	s $ztexit=0
	w !,"----------------------------------------------------",!!
	q
errlbck
	view "TRACE":1:"^TRACE"
	s $zint="do ^erthrint"
	s $ZTE=1 
	tstart ():serial
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d
	. s ^ERRLBK(j)=$$fib(j)
	d ^erthrint
	;
	f j=x+1:1:y d
	. s ^ERRLBK(j)=$$fib(j)
	s ^done("errlbck")=1
	hang 5
	trollback
	hang 5
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	s $ztexit=0
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
