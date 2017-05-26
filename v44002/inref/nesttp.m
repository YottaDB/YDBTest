cmmit ;
      s $zint="d ^thrint"    
      s $ZTE=1 
      tstart ()
      w !,"Transaction Starts, $TLEVEL = ",$TL,!
      s x=5,y=10
      tstart ()
      f j=1:1:x d 
      . s ^cmmit(j)=$$fib(j)
      ;
      w !,"nested transaction, $TLEVEL = ",$TL,!
      d ^thrint
      f j=x+1:1:y d 
      . s ^cmmit(j)=$$fib(j)
      ;
      tcommit:$tlevel=2
      w !,"TCommit #1: $TLEVEL = ",$TL,!
      w !,"$ZTEXIT = ",$ZTE,!
      s ^done("cmmit")=1
      tcommit:$tlevel
      w !,"TCommit #2: $TLEVEL = ",$TL,!
      w !,"            $ZTEXIT = ",$ZTE,!
      w !,"End of transaction....",!    
      w !,"----------------------------------------------------",!!
      q
rollbck1 ;
      view "TRACE":1:"^TRACE"
      s $zint="d ^thrint"    
      s $ZTE="1throw" 
      tstart ()
      w !,"Transaction Starts....",!
      s x=3,y=5
      tstart ()
      f j=1:1:x d 
      . s ^rlbck1(j)=$$fib(j)
      ;
      w !,"nested transaction, $TLEVEL = ",$TL,!
      d ^thrint
      w !,"trollback:$tlevel=2 ",! trollback:$tlevel=2
      w !,"nested transaction, $TLEVEL = ",$TL,!
      w !,"$ZTEXIT = ",$ZTE,!
      ;
      f j=1:1:y d 
      . s ^rlbck1(j)=$$fib(j)
      ;
      s ^done("rollbck1")=1
      tcommit:$tlevel
      w !,"TCommit at $TLEVEL = ",$TL,!
      w !,"            $ZTEXIT = ",$ZTE,!
      w !,"End of transaction....",!    
      w !,"$ZTEXIT = ",$ZTE,!
      view "TRACE":0:"^TRACE"
      w !,"----------------------------------------------------",!!
      q
      ;
rollbck2 ;
      view "TRACE":1:"^TRACE"
      s $zint="d ^thrint"    
      s $ZTE=1
      tstart ()
      w !,"Transaction Starts....",!
      s x=3,y=5
      tstart ()
      f j=1:1:x d 
      . s ^rlbck2(j)=$$fib(j)
      ;
      w !,"nested transaction, $TLEVEL = ",$TL,!
      d ^thrint
      w !,"tcommit:$tlevel=2 ",! tcommit:$tlevel=2
      w !,"nested transaction, $TLEVEL = ",$TL,!
      w !,"$ZTEXIT = ",$ZTE,!
      ;
      f j=1:1:y d 
      . s ^rlbck2(j)=$$fib(j)
      ;
      s ^done("rollbck2")=1
      w !,"trollback:$tlevel ",! trollback:$tlevel
      w !,"Trollback at $TLEVEL = ",$TL,!
      w !,"            $ZTEXIT = ",$ZTE,!
      w !,"End of transaction....",!
      view "TRACE":0:"^TRACE"    
      w !,"----------------------------------------------------",!!
      q
      ;
rollbck3 ;
      view "TRACE":1:"^TRACE"
      s $zint="d ^thrint"    
      s $ZTE=1
      tstart ()
      w !,"Transaction Starts....",!
      s x=3,y=5
      tstart ()
      f j=1:1:x d 
      . s ^rlbck3(j)=$$fib(j)
      ;
      w !,"nested transaction, $TLEVEL = ",$TL,!
      d ^thrint
      f j=x+1:1:y d 
      . s ^rlbck3(j)=$$fib(j)
      w !,"trollback 0 ",! trollback 0
      w !,"nested transaction, $TLEVEL = ",$TL,!
      s ^done("rollbck3")=1
      w !,"$ZTEXIT = ",$ZTE,!
      view "TRACE":0:"^TRACE"
      w !,"----------------------------------------------------",!!
      q
      ;
fib(n)
      n fib s fib=n
      s fib(0)=0,fib(1)=1
      s fib(0)=0,fib(1)=1
      if n'>0 q fib
      f i=2:1:n d
      . s fib(i)=fib(i-1)+fib(i-2)
      s val=fib(n)
      q val
      ;
