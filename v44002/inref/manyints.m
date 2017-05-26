cmmit 
	s $zint="do lthrint"
	s $ZTE="notdefined"
	tstart ()
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d
	. s ^CMMIT(j)=$$fib(j)
	i '$ZSigproc($j,$ztrnlnm("sigusrval")) w !,"SIGUSR1 sent to process"
	;
	f j=x+1:1:y d
	. s ^CMMIT(j)=$$fib(j)
	s ^done("commit")=1
	;
	tcommit
	w !,"End of transaction....",!    
	w !,"$ZTEXIT = ",$ZTE,!
	w !,"----------------------------------------------------",!!
	q
rollbck 
	view "TRACE":1:"^TRACE"
	s $zint="do lthrint"
	s $ZTE=0 
	tstart ()
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d
	. s ^RLBCK(j)=$$fib(j)
	;
	i '$ZSigproc($j,$ztrnlnm("sigusrval")) w !,"SIGUSR1 sent to process"
	;
	f j=x+1:1:y d
	. s ^RLBCK(j)=$$fib(j)
	s ^done("rolbck")=1
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
lthrint
	w !,!,!
	w !,"***************************"
	w !,"Interrupt issued to process",!
	w !,"***************************",!
	i '$ZSigproc($j,$ztrnlnm("sigusrval")) w !,"SIGUSR1 sent to process"
	e  w !,"Interrupt discarded - can't interrput process while $ZINI=1"
	w !,"**************************************************************",!
	q

