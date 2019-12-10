;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmmit
	s $zint="d lthrint"
	s $ZTE=1
	s x=4
	f j=1:1:x d
	. s num(j,"fibval")=$$fib(j)
	;
	tstart ()
	w !,"Transaction Starts...."
	w !,"$ZTEXIT -> ",$ZTE
	;
	w !,"Interrupt signal sent....",!
	i '$ZSigproc($j,"sigusr1") w !,"SIGUSR1 sent to process"
	f i=1:1:4 d
	s fact(i)=$$^fact(i)
	;
	s ^aaa=1111          ;$reference
	i $d(^aaa) w !,"gbl var ^aaa set"
	w !,"$reference -> ",$reference
	w !,"$test -> ",$test
	;
	w !,"Before rethrow..."
	w !,"$reference -> ",$reference
	w !,"$test -> ",$test
	w !,"$ZTEXIT -> ",$ZTE
	;
	;
	tcommit
	w !,"End of transaction....",!
	w !,"After rethrow..."
	w !,"$reference -> ",$reference
	w !,"$test -> ",$test
	w !,"$ZTEXIT -> ",$ZTE
	q
	;
rollbck
	view "TRACE":1:"^TRACE"
	s $zint="d lthrint"
	s $ZTE=1
	s x=4
	;
	f j=1:1:x d
	. s num(j,"fibval")=$$fib(j)
	;
	s ^aaa=1111          ;$reference
	i $d(^aaa) w !,"gbl var ^aaa set"
	w !,"$reference -> ",$reference
	w !,"$test -> ",$test
	tstart ()
	w !,"Transaction Starts...."
	w !,"$ZTEXIT -> ",$ZTE
	;
	w !,"Interrupt signal sent....",!
	i '$ZSigproc($j,"sigusr1") w !,"SIGUSR1 sent to process"
	f i=1:1:4 d
	s fact(i)=$$^fact(i)
	;
	trollback
	w !,"End of transaction....",!
	w !,"After rethrow..."
	w !,"$reference -> ",$reference
	w !,"$test -> ",$test
	w !,"$ZTEXIT -> ",$ZTE
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
lthrint
	w !,!,!
	w !,"***************************"
	w !,"Interrupt issued to process",!
	w !,"***************************",!
	if $test=0 s val=1
	h 5              ;wait a little to avoid timing problems
	w !,"$test in intr -> ",$test
	s ^bbb=1 w !,"$reference -> ",$reference
	q
