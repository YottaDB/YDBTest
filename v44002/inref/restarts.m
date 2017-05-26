singlec 
	s $zint="do ^thrint"
	s $ZTE=1 
	tstart ():serial
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d
	. s ^SINGLC(j)=$$fib(j)
	;
	d ^thrint
	;
	f j=x+1:1:y d
	. s ^SINGLC(j)=$$fib(j)
	s ^done("singlc")=1
	;
	if $trestart=0 trestart
	w "$trestart -> ",$trestart 
	s ^done("singlec")=1 
	tcommit
	w !,"End of transaction....",!    
	; interrupt rethrown
	w !,"$ZTEXIT = ",$ZTE,!
	q
	;
singler 
	view "TRACE":1:"^TRACE"
	s $zint="do ^thrint"
	s $ZTE=1
	tstart ():serial
	w !,"Transaction Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=8
	f j=1:1:x d
	. s ^SINGLR(j)=$$fib(j)
	;
	d ^thrint
	;
	f j=x+1:1:y d
	. s ^SINGLR(j)=$$fib(j)
	if $trestart=0 trestart
	w "$trestart -> ",$trestart 
	s ^done("singler")=1 
	trollback
	w !,"End of transaction....",!    
	; interrupt rethrown
	w !,"$ZTEXIT = ",$ZTE,!
	view "TRACE":0:"^TRACE"
	q
	;
nestedc 
	s $zint="do ^uthrint"
	s $ZTE=0
	w !,"Transaction Starts...."
	tstart ():serial  d
	. s x=3
	. s ^nested(1)=$$fib(2)
	.     tstart ():serial  d
	.     . s ^nested(2)=$$fib(2)
	.     . d ^uthrint
	.     . if $trestart=0 trestart:0
	.     . w "$trestart -> ",$trestart 
	.     w !," tcommit:1 ",! tcommit
	.     s ^done("all")=1
	. w !,"tcommit 1 ",! tcommit
	;
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
