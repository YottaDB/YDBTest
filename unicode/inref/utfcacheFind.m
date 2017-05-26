;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test case for each of 3 types of successful returns from $FIND() in UTF8 mode.
;
;   1. Found char in the cache.
;   2. Found char in partially cached string but outside the cache.
;   3. Found char where string was either not in cache or cache was full so found via brute-force scan.
;
	set errors=0
	set x="1234567890"
	;goto case2					; uncomment and direct to invoke specific case
;
; Case 1: Find char in the cache
;
case1
	write !,"Case 1 - Find char in cache",!
	set y=x_x_x_x_$char(194)_x_x_x_x_$char(195)_x_x_x_x_$char(196)
	set zprime=$find(y,"z",$length(y))		; Should cache entire line
	set z=$find(y,"0",82)
	do verifyresult(z,93)
;
; Case 2a: Find char in partially cached string but outside the cache
;
case2a
	write "Case 2a - Find char in partially cached string but outside the cache",!
	set y=x_x_x_x_$char(194)_x_x_x_x_$char(195)_x_x_x_x_$char(196)	; Reset y to clear cache
	set zprime=$find(y,$char(194),2)		; Should cache first 41 chars
	set z=$find(y,"0",zprime)
	do verifyresult(z,52)
;
; Case 2b: Alterate case 2b - Find char as first char we search
;
case2b
	write "Case 2b - (alternate case 2) Find char as first char we search",!
	set y=x_x_x_x_$char(194)_x_x_x_x_$char(195)_x_x_x_x_$char(196)	; Reset y to clear cache
	set zprime=$find(y,$char(194),2)		; Should cache first 41 chars
	set z=$find(y,$char(194),zprime-1)
	do verifyresult(z,42)
;
; Case 3: Find char where string was either not in cache or cache was full so found via brute-force scan
;
case3
	write "Case 3 - Find char where string was either not in cache or cache was full so found via brute-force scan",!
	set z=$find(x,"0",2)				; Too small to cache
	do verifyresult(z,11)
;
; Epilogue
;
	write:(0=errors) !,"All subtests passed!",!
	quit

;
; Routine to verify result and print appropriate messages
;
verifyresult(result,expect)
	if (expect=result) write "  Success",!!
	else  write "  FAIL - expected ",expect," but received ",result,!! set errors=errors+1
	quit
