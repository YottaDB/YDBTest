;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alststartvar;
	;
	; Test that TSTART variable is restored properly on restart
	;
	set a=1,*a(1)=b,b=29,b("a")=457
	tstart (a):(serial)
	set *c(2)=b
	if $trestart=0 write !,"Zwrite output BEFORE trestart",! zwrite
	else           write !,"Zwrite output AFTER  trestart",! zwrite
	kill *b
	tstart (kk):(serial)
	set *kk=c(2)
	kill *c
	tstart (kk):(serial)
	set kk=3
	if $trestart<1 trestart
	tcommit
	tcommit
	tcommit
	write !,"Zwrite output AFTER  tcommit",! zwrite
	quit

