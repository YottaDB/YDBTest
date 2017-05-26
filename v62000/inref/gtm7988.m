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
gtm7988
	; Make sure both globals are locals don't issue an error when undefined
	view "NOUNDEF"
	do exec("zwrite varA")
	do exec("zwrite varA(1)")
	do exec("set varA(10,2)=1")
	do exec("zwrite varA(10)")
	do exec("set varB=2")
	do exec("zwrite varB(1)")
	do exec("set varB(1,1)=3")
	do exec("zwrite varB(1)")
	quit
exec(comm)
	; Try the same command as a local as well as a global
	write "# Executing [^]",comm,!
	xecute comm
	xecute $piece(comm," ",1)_" ^"_$piece(comm," ",2)
	quit
