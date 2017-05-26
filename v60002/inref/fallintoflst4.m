;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper script for fallintoflst.
fallintoflst4
	set count=0
	set $etrap="write $zstatus,! set $ecode="""" set count=count+1 if count<100 do b(count)"
	new y
	do a(.y)
	quit

a(y)
	write 1/0
	quit

b(x)
	write "we are in b",!
c(x)
	quit
