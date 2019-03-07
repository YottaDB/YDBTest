;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8855
	set $ztrap="goto incrtrap^incrtrap"
	set ^X=1
	set mem=$zrealstor
	write "Initial Memory Allocated=",mem,!
	set halt=0
	set pass=1
	for i=1:1:100 do  quit:halt=1
	. set ^X(i)=i
	. if mem'=$zrealstor  set halt=1  set pass=0  set mem=$zrealstor
	write:pass "Memory allocated remained ",mem," through 100 processes, no memory leaks detected, TEST PASSED"
	write:halt "Memory allocated changed during the ",i,"th updates, memory leak detected, TEST FAILED"
	quit
