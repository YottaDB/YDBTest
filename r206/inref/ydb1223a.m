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

ydb1223a ;
	set ^Q(1,"XBase",0,"XBvers")="24.1.12"
	write "SystemVersion=",$$getSystemVersion(),!
	if $d(^A)
	write "SystemVersion=",$$getSystemVersion(),!
	quit

Prog1() ;
	new system set system=$get(^Q(1,"XBase",0,"XBName"))
	quit system

getSystemVersion() ;
	new version set version=$get(^Q(1,"XBase",0,"XBvers"))
	quit version
