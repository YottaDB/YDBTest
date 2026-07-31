;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sigwinch1247	; Helper routines for the sigwinch_devparam-ydb1247 subtest
	quit

zshowd(pat)	; write whether the ZSHOW "D" output contains pat (avoids dumping the raw nondeterministic output)
	new d,i,ok
	zshow "D":d
	set ok=0,i=""
	for  set i=$order(d("D",i)) quit:""=i  if d("D",i)[pat set ok=1
	write $select(ok:"FOUND",1:"MISSING")," [",pat,"]",!
	quit

dims	; write the $PRINCIPAL WIDTH and LENGTH as reported by ZSHOW "D"
	new d,i,line
	zshow "D":d
	set line="",i=""
	for  set i=$order(d("D",i)) quit:""=i  set line=line_d("D",i)
	write "DIMS ",$piece($piece(line,"WIDTH=",2)," ",1),"x",$piece($piece(line,"LENG=",2)," ",1),!
	quit

stk	; write whether the frame the SIGWINCH handler code runs in shows up in ZSHOW "S" as a (SIGWINCH) frame
	new i,ok,s
	zshow "S":s
	set ok=0,i=""
	for  set i=$order(s("S",i)) quit:""=i  if s("S",i)["(SIGWINCH)" set ok=1
	write "STACK ",$select(ok:"FOUND",1:"MISSING")," [(SIGWINCH)]",!
	quit

readtest	; a terminal READ interrupted by a SIGWINCH resumes with the already-entered input intact
	new x
	write "READTEST-START",!
	read x
	write !,"READTEST-GOT [",x,"]",!
	quit
