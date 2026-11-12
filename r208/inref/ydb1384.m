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
; YDB#1384 : Update helper processes must not exit when the statistics database of a region cannot be created or
; opened.
;
; Used by updhelper_statsdb-ydb1384.csh.
;
ydb1384	;
	quit

ygs	; Write 1 if the process whose pid is in $ZCMDLINE shares statistics for region DEFAULT, else 0. Needs
	; gtm_statshare set, so that this process can read ^%YGS.
	write $data(^%YGS("DEFAULT",+$zcmdline))#10,!
	quit
