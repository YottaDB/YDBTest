ydb1249aim	;
	;################################################################
	;								#
	; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
	; All rights reserved.						#
	;								#
	;	This source code contains the intellectual property	#
	;	of its copyright holder(s), and is made available	#
	;	under a license.  If you do not know the terms of	#
	;	the license, please stop and do not read further.	#
	;								#
	;################################################################
	;
	; YDB#1249 : AIM builds a trigger whose subscript specification has an open
	; ended range when xsub asks for one, e.g. "2:". Reading that definition back
	; from ^#t used to examine the first byte of the empty side of the range,
	; which is one byte past its end, and act on it when it happened to be a
	; double quote. The KILL below is what reported the resulting
	; TRIGSUBSCRANGE. Measured against an unfixed build, it reports it on
	; roughly one iteration in thirty, so 200 iterations leaves ample margin.
	;
	new $etrap,g,i,n,s,x
	; AIM reports an error by unwinding it a caller frame at a time, and it NEWs
	; its own copy of n on the way, so the handler uses $GET(n) at this level and
	; takes n as a formal at the level that does the KILL.
	set $etrap="use $principal write ""# error at iteration "",$get(n),"" : "",$piece($zstatus,"","",3,999),! set $ecode="""" halt"
	set g="^x",s(1)="2:"
	for n=1:1:200 do
	. kill @g
	. for i=1:1:5 set @g@(i)="abcd|efgh"
	. set x=$$XREFDATA^%YDBAIM(g,.s,"|",1)
	. set x=$$XREFSUB^%YDBAIM(g,.s,1)
	. do killit(g,n)
	. do UNXREFDATA^%YDBAIM() do UNXREFSUB^%YDBAIM()
	write "# completed 200 iterations with no error",!
	quit
killit(g,n)	; KILL the cross referenced global, reporting the iteration on error
	new $etrap
	set $etrap="use $principal write ""# error at iteration "",n,"" : "",$piece($zstatus,"","",3,999),! set $ecode="""" halt"
	kill @g
	quit
