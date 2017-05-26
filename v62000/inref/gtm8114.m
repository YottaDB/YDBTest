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
	;
gtm8114	; Test runtime error after a TP restart does not SIG-11
	;
	set $etrap="do err"
        tstart (a):serial
	write "ZWRITE at $trestart = ",$trestart,! zwrite
        do
        .	if $trestart=1 write 1/0
        .	quit
        set a(1)=2
        if $trestart<1 trestart
        tcommit
	write "ZWRITE after TCOMMIT",! zwrite
	quit
err	;
	write $zstatus,!
	set $ecode=""
	quit
