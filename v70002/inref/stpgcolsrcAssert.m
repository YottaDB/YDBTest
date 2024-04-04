;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

stpgcolsrcAssert	;
	set $ztrap="goto incrtrap^incrtrap"
	for j=1:1:10 do
	. set $zmalloclim=1
	. do helper
	. do helper
	quit

helper	;
	for i=1:1:1000000 set x(i)=$justify(i,800)
	quit

