;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb828fjustify	; Test $JUSTIFY and $FNUMBER with a huge 3rd parameter does not cause a SIG-11 or assert failures
	;
	; The reason why we test both $JUSTIFY and $FNUMBER is that they both use the same underlying function (op_fnj3)
	; when the 3rd argument is specified.
	;
	write "# Testing $FNUMBER with random huge 3rd argument",!
	for i=1:1:10 set xstr="set x=$fnumber(1,""P,"",$$gennumber^ydb828arith)" do execute(xstr)
	write "# Testing $JUSTIFY with random huge 3rd argument",!
	for i=1:1:10 set xstr="set x=$justify(1,20,$$gennumber^ydb828arith)" do execute(xstr)
	write "# Testing $JUSTIFY with random huge 2nd and 3rd arguments",!
	for i=1:1:10 set xstr="set x=$justify(1,$$gennumber^ydb828arith,$$gennumber^ydb828arith)" do execute(xstr)
	write "PASS",!
	quit

execute(xstr)
	new $etrap
	set $etrap="do etrap"
	xecute xstr
	quit

etrap	;
	; Only allow the following errors as expected. Any other error is unexpected and we halt the program in that case.
	;	%YDB-E-MAXSTRLEN, Maximum string length exceeded
	;	%YDB-E-NUMOFLOW, Numeric overflow
	;	%YDB-E-JUSTFRACT, Fraction specifier to $JUSTIFY cannot be negative
	if ($zstatus["YDB-E-MAXSTRLEN")!($zstatus["YDB-E-NUMOFLOW")!($zstatus["YDB-E-JUSTFRACT") set $ecode=""
	else  zshow "*" halt
	quit

