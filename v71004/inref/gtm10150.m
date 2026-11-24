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
; Helper routines of the dollartext_dbrolledback-gtm10150 subtest. See that subtest for the overall scheme.
gtm10150	;
	quit

init	; Install a trigger (journal sequence number 1) and then do 1000 updates
	new i
	if '$ztrigger("item","+^b -commands=set -xecute=""set ^c=1"" -name=gtm10150trig") write "TEST-E-FAIL : $ZTRIGGER failed",!
	for i=1:1:1000  set ^a(i)=$justify(i,10)
	quit

control	; $TEXT() of the trigger with no online rollback
	write "$TEXT(+1^gtm10150trig#) returned [",$text(+1^gtm10150trig#),"]",!
	quit

test	; $TEXT() of the trigger after an online rollback that this process has not noticed yet
	new $etrap,line
	set $etrap="do err^gtm10150"
	set ^a=1	; open the database file before the online rollback
	zsystem "$MUPIP journal -online -rollback -backward -resync=800 -verbose ""*"" >&! orlbk.out"
	; This process has not read the trigger yet, so $TEXT() reads the trigger from the database file
	set line=$text(+1^gtm10150trig#)
	write "FAIL : $TEXT(+1^gtm10150trig#) returned [",line,"] and did not issue an error",!
	quit

err	;
	if $zstatus["DBROLLEDBACK" write "PASS : $TEXT(+1^gtm10150trig#) issued DBROLLEDBACK",!
	else  write "FAIL : unexpected error : ",$zstatus,!
	set $ecode=""
	write "$TEXT(+1^gtm10150trig#) after the error returned [",$text(+1^gtm10150trig#),"]",!
	quit
