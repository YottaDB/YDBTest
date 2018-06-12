;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm8781
	zsystem "echo 'gtm8781 subtest'"
	write "Memory Allocated after 1 ZSYSTEM: ",$zrealstor,!
	set mem=$zrealstor
	set pass=1
	set halt=0
	for i=1:1:100 do  quit:halt=1
	. zsystem "echo 'hello' > /dev/null"
	. if mem'=$zrealstor  set pass=0  write "Memory Allocated Changed After ",i," Passes, Memory Leak Detected, Test Failed"  set halt=1
	write:pass "Memory Allocated After 100 ZSYSTEMS Is The Same, No Memory Leaks, Test Passed"
	quit
