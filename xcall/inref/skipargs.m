;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
; Helper script for the xcall/skip_args test. It invokes specific external
; routines with the last argument(s) skipped.
test
	do &testInt(1,2)
	do &testLong(1)
	do &testIntStar()
	do &testLongStar(1,2)
	do &testFloatStar(1,2)
	do &testDoubleStar(1)
	do &testCharStar(1,2,3)
	do &testString(1)
	do &testInt(1,,3)
	do &testLong(,2)
	do &testIntStar(,2)
	do &testLongStar(,2,)
	do &testFloatStar(1,,,4)
	do &testDoubleStar(,2)
	do &testCharStar(,,3)
	do &testString(,,3)
	new $estack
	do nogbls^incretrap
	set $etrap="do incretrap^incretrap"
	set incretrap("PRE")="write ""%""_$piece($zstatus,""%"",2),!"
	set incretrap("NODISP")=1
	do &testInt(a1,,3)
	do &testLong(0,0)
	do &testIntStar(a3,2)
	do &testLongStar(0,0,)
	do &testFloatStar(1,,,,.e5)
	do &testDoubleStar(,b6)
	do &testCharStar(,b7,)
	do &testString(.a8,,3)
	quit
