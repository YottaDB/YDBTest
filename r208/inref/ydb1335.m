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
;
; SET $SYSTEM after the string pool has been expanded (see r208/u_inref/system_gcol-ydb1335.csh)
;
ydb1335	;
	quit

append	; SET $SYSTEM to a non-empty value appends it to the initial value of $SYSTEM
	new init
	set init=$system
	do grow
	set $system="abc"
	do check(init_"abc","SET $SYSTEM=""abc""")
	quit

reset	; SET $SYSTEM to the empty string sets $SYSTEM back to its initial value
	new init
	set init=$system
	set $system="xyz"
	do grow
	set $system=""
	do check(init,"SET $SYSTEM=""""")
	quit

grow	; Use enough string space that the string pool is expanded, and garbage collected, more than once
	new i,x,y
	for i=1:1:200 set x(i)=$justify(i,100000)
	kill x
	for i=1:1:2000 set y(i)=$translate($justify(i,500)," ","#")
	quit

check(expect,cmd)
	if $system=expect write "PASS : after ",cmd," $SYSTEM is the expected value",! quit
	write "WRONG : after ",cmd," $SYSTEM is ",$zwrite($system)," but expected ",$zwrite(expect),!
	quit
