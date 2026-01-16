;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb254a ;
	write $view("statshare"),!
	view "nostatshare":"DEFAULT"
	write $view("statshare"),!
	quit

ydb254b ;
	write $view("STATSHARE")
	view "nostatshare":"AREG"
	zsys "ls -l /proc/"_$j_"/fd > ydb254b-before.log"
	write $get(^b)
	zsys "ls -l /proc/"_$j_"/fd > ydb254b-after.log"
	quit

ydb254c ;
	view "nostatshare"
	write $view("STATSHARE"),!
	view "statshare"
	write $view("STATSHARE"),!
	view "statshare":"DEFAULT"
	write $view("STATSHARE"),!
	view "nostatshare":"DEFAULT"
	write $view("STATSHARE"),!
	quit

ydb254d ;
	view "NOSTATSHARE":"DEFAULT"
	write $view("STATSHARE","DEFAULT")
	quit
