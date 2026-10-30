;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
; Helper M program used by the r208/invdlrcval_value-ydb1343 subtest (UTF-8 mode). Each label checks one case and
; prints PASS or WRONG.
;
xecute	; XECUTE of a $CHAR() with a literal argument that is not a valid code point
	new err
	set err=""
	do xecute1(.err)
	do check(err,1114112)
	quit
xecute1(err)
	new $etrap
	set $etrap="set err=$zstatus,$ecode="""" quit"
	xecute "write $char(1114112)"
	quit
rtn	; Run a line of a compiled routine with a $CHAR() whose literal argument is not a valid code point
	new err
	set err=""
	do rtn1(.err)
	do check(err,1114112)
	quit
rtn1(err)
	new $etrap
	set $etrap="set err=$zstatus,$ecode="""" quit"
	do ^ydb1343bad
	quit
check(err,value)	; Check that "err" is INVDLRCVAL with the given value
	new want
	set want="%YDB-E-INVDLRCVAL, Invalid $CHAR() value "_value
	if $piece(err,",",3,99)=want write "PASS : the error is ",want,! quit
	write "WRONG : the error is [",$piece(err,",",3,99),"], expected ",want,!
	quit
