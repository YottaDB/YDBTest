;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nodb	;
	set $ztrap="write:$zversion'[""VMS"" $piece($zstatus,"","",3,99),! halt"
	w !,"I do not have a database..."
	VIEW "TRACE":1:"^TRACE(""ZMPROF0"")"
	w !,"I said, I do not have a database...",!
	d ^one
	VIEW "TRACE":0:"^TRACE(""ZMPROF0"")"
	q
