;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm10099 ;
	set test=$piece($zcmdline," ",1)
	do trans^gtm10099(test)
	quit

trans(test)
	tstart ():serial
	if 3>$trestart trestart
	if ("T1"=test)  do
	. zedit "extcall"
	else  do
	. do &gtm10099()
	tcommit:$tlevel
	quit
