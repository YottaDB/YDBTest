;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8450	;Validate that $ZGETJPI() returns large values correctly
	;use the white box case to inflate the actual time and check that it comes out large
	set x=0
	for i=1:1:10000000 set x=x+1	;#  Do some nonsense to take up at least a second of CPU time
	write !,$select(2**31<$zgetjpi(0,"CPUTIM"):"PASS",1:"FAIL")," from ",$text(+0)
	quit
