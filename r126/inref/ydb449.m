;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main ;
	kill ^x
	set isNoIso=$piece($ZCMDLINE," ",1) set isOrder=$piece($ZCMDLINE," ",2)
	set ^x("sub0")=1
	set x=$order(^x("sub0"),-1)
	if isNoIso VIEW "NOISOLATION":"+^x" tstart ():serial set ^x("sub0")=^x("sub0")+1
	else  set x=$incr(^x("sub0"))
	tcommit:isNoIso
	if isOrder set x=$order(^x("sub0","sub1"),-1)
	else  set x=$query(^x("sub0","sub1"),-1)
	quit
concur ;
	set ^x=""
	quit

