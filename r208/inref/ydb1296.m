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
; READ x:5 from a PIPE whose command writes a partial line (no newline) and then keeps the PIPE open.
; Expect the READ to return the partial line with $TEST=0 once the 5 seconds are up.
ydb1296
	new p,x,t,start,elapsed
	set p="pipe"
	open p:(command="printf 'DSE> '; exec cat")::"PIPE"
	use p
	set start=$zut
	read x:5
	set t=$test,elapsed=$zut-start\1000000
	use $principal
	close p
	if "DSE> "=x write "# x is ""DSE> "" as expected",!
	else  write "WRONG : x is ",$zwrite(x),", expected ""DSE> """,!
	if 0=t write "# $TEST is 0 as expected",!
	else  write "WRONG : $TEST is ",t,", expected 0",!
	if 60>elapsed write "# READ took less than 60 seconds as expected",!
	else  write "WRONG : READ took ",elapsed," seconds, expected less than 60",!
	quit
