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
;
; Cases for r208/ztrap_new_noline-ydb1347 : an argumentless or exclusive NEW in $ZTRAP or device EXCEPTION code
; for an error on a line without a label. The subtest compiles this routine both with and without -noline_entry.
; With -noline_entry, the local variable slots of a routine frame are filled only at the start of a line with a
; label, so after the NEW, the line that is retried must still see the variables of the new symbol table.
;
ydb1347
	quit
argless	; $ZTRAP does an argumentless NEW and sets x, then the line with the error is retried
	set $ztrap="new  set x=1"
	do r1
	write "back from r1",!
	quit
exclusive	; $ZTRAP does an exclusive NEW that keeps y, and sets x to y, then the line is retried
	set y=5,$ztrap="new (y) set x=y"
	do r1
	write "back from r1",!
	quit
laterline	; The error is on the second line after the label, after a line that sets another variable
	set $ztrap="new  set x=1"
	do r2
	write "back from r2",!
	quit
device	; Device EXCEPTION code does an argumentless NEW, then the OPEN, which references f, is retried
	set $etrap="write $piece($zstatus,"","",3,4),! set $ecode="""" quit"
	do r3
	write "back from r3",!
	quit
r1	; x is undefined until the error handling sets it
	write "r1 x=",x,!
	quit
r2	; z is set before the error, so it is undefined in the new symbol table
	set z=1
	write "r2 x=",x," $get(z)=",$get(z),!
	quit
r3	; f is set before the OPEN, so it is undefined in the new symbol table when the OPEN is retried
	set f="nonexistent.dir/f.txt"
	open f:(readonly:exception="new  set x=1")
	write "r3 opened",!
	quit
