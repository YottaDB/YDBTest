;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; Note: Below are various test cases that failed during fuzz testing. No pattern otherwise to these test cases.

	; The below tests used to fail with a GTMASSERT2 before YDB@bc947837
	; They should now produce a ZBRKCNTNEGATIVE error
	zbreak :-1:-10
	zbreak ::-1
	zbreak ::-2
	zbreak ::-3
	;
	; The below tests did not fail previously. But are there to test other aspects of YDB@bc947837
	zbreak ::0	; Ensure we don't get any error when breakpoint count is 0 (we will get a INVZBREAK error if in direct mode)
	zbreak -x::-1	; Ensure we get a parse error when ZBREAK - (i.e. cancel breakpoint) and a negative count (-1) is specified
	zbreak -x::-2	; Ensure we get a parse error when ZBREAK - (i.e. cancel breakpoint) and a negative count (-2) is specified
	zbreak -x::-3	; Ensure we get a parse error when ZBREAK - (i.e. cancel breakpoint) and a negative count (-3) is specified
	zbreak -x::0	; Ensure we get a parse error when ZBREAK - (i.e. cancel breakpoint) and a zero count () is specified
	zbreak -x::2	; Ensure we get a parse error when ZBREAK - (i.e. cancel breakpoint) and a positive count (1) is specified
	quit

