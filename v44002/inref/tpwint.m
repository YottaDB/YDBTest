;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ztedef
	s $zint="d ^thrint"
	tstart ():serial
	w !,"Transaction 1 Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=25
	f j=1:1:x d
	. s ^ZTEDEF(j)=$$fib(j)
	s $ZTE="4rethrow"
	;
	d ^thrint
	;
	s ^done("ztedef")=1
	w !,"$zint = ",$zint,!
	tcommit
	w !,"End of transaction 1....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s $ZTE=""
	w !,"----------------------------------------------"
	q
	;
ztendef
	s $zint="d ^uthrint"
	s $ZTE=0
	tstart ():serial
	w !,"Transaction 2 Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=15
	f j=1:1:x d
	. s ^ZTEUNDEF(j)=$$fib(j)
	d ^uthrint
	;
	s ^done("ztendef")=1
	tcommit
	w !,"End of transaction 2....",!
	w !,"$ZTEXIT = ",$ZTE,!
	w !,"----------------------------------------------"
	q
	;
discint
	s $zint="d discard"
	tstart ():serial
	w !,"Transaction 1 Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=5,y=10
	f j=1:1:x d
	. s ^ZTEDEF(j)=$$fib(j)
	;
	; Generate interrupt. SIGINT is represented by the
	; sigusrval environment variable on each platform
	i '$ZSigproc($j,"SIGUSR1") w !,"SIGUSR1 sent to process",!
	;
	f j=x+1:1:y d
	. s ^ZTEDEF(j)=$$fib(j)
	s ^done("ztedef")=1
	w !,"$zint = ",$zint,!
	tcommit
	w !,"End of transaction 1....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s $ZTE=""
	w !,"----------------------------------------------"
	q
	;
savzte
	s $zint="d ^thrint"
	tstart ():serial
	w !,"Transaction 1 Starts....",!
	w !,"$ZTEXIT = ",$ZTE,!
	s x=12
	f j=1:1:x d
	. s ^savzte(j)=$$fib(j)
	s $ZTE=1
	;
	d ^thrint
	;
	s ^done("savzte1")=1
	w !,"$zint = ",$zint,!
	tcommit
	w !,"End of transaction 1....",!
	w !,"$ZTEXIT = ",$ZTE,!
	w !,"---;;---;;---;;---;;---;;---"
	w !,"Transaction 2 Starts...",!
	tstart ():serial
	w !,"$ZTEXIT = ",$ZTE,!
	f j=1:1:x d
	. s ^factarry(j)=$$^fact(j)
	s $ZTE=1
	;
	d ^thrint
	;
	s ^done("savzte2")=1
	w !,"$zint = ",$zint,!
	tcommit
	w !,"End of transaction 2...",!
	w !,"---;;---;;---;;---;;---;;---"
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
discard
	s $ZTE="4rethrow"
	w !,"Interrupt issued to process",!
	i '$ZSigproc($j,"SIGUSR1") w !,"SIGUSR1 sent to process"
	e  w !,"Interrupt discarded - can't interrput process while $ZINI=1"
	w !,"**************************************************************",!
	q





