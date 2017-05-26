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
; Test possible $extract() cases with UTF8 caching
;
;   1. Case 1 - Simple uncached string with the extraction tests:
;        1a. Starting at first char, ending in middle
;        1b. Starting in middle, ending in middle+N
;        1c. Starting in middle ending at last char
;        1d. Starting at first char, end at last char
;   2. Case 2 - Fully cached string - all extractions should cross groups - the extraction tests:
;        2a. Starting at first char, ending in middle (start on ascii, end on ascii)
;        2b. Starting at first char, ending in middle (start on ascii, end on utf8)
;        2c. Starting at first char, ending in middle (start on utf8, end on ascii)
;        2d. Starting at first char, ending in middle (start on utf8, end on utf8)
;        2e. Starting in middle, ending in middle+N (start on ascii, end on ascii)
;        2f. Starting in middle, ending in middle+N (start on ascii, end on utf8)
;        2g. Starting in middle, ending in middle+N (start on utf8, end on ascii)
;        2h. Starting in middle, ending in middle+N (start on utf8, end on utf8)
;        2i. Starting in middle ending at last char (start on ascii, end on ascii)
;        2j. Starting in middle ending at last char (start on ascii, end on utf8)
;        2k. Starting in middle ending at last char (start on utf8, end on ascii)
;        2l. Starting in middle ending at last char (start on utf8, end on utf8)
;   3. Case 3 - Detect BADCHAR and verify target string unchanged
;   4. Case 4 - Detect BADCHAR and verify target string unchanged with src/target the same mval
;   5. Case 5 - Test extract with terminating character positions far beyond actual end of string. Note
;               that each extractions should contain at least one utf8 character. The extraction tests:
;        5a. Starting at first char (start on ascii)
;	 5b. Starting at first char (start on utf8)
;	 5c. Starting in middle char (start on ascii)
;	 5d. Starting in middle char (start on utf8)
;	 5e. Starting at last char (start on ascii - note contains no utf8 by definition)
;	 5f. Starting at last char (start on utf8)
;
; Note the conditional initialization on each subcase allows subcase isolation to work on specific
; issues when detected.
;
	set (c1init,c2init,c5init,failures)=0
	set $etrap="zwrite $zstats zshow ""*"" zhalt 1"
 	;goto subcase5f	   	   ; Used to zoot right to the specified case when debugging

;
; Subcase 1a: Starting at first char, ending in middle on ascii char
;
subcase1a
	do:('c1init) case1init
	write "  Subcase 1a: Starting at first char, ending in the middle",!
	set z=$extract(y,1,19)
	do verifyresult(z,"1234567890"_$char(195)_"12345678")
;
; Subcase 1b: Starting in middle, ending in middle+N
;
subcase1b
	do:('c1init) case1init
	write "  Subcase 1b: Starting in middle, ending in middle+N",!
	set z=$extract(y,3,20)
	do verifyresult(z,"34567890"_$char(195)_"123456789")
;
; Subase 1c: Starting in middle ending at last char
;
subcase1c
	do:('c1init) case1init
       	write "  Subcase 1c: Starting in middle ending at last char",!
	set z=$extract(y,15,$length(y))
	do verifyresult(z,"4567890")
;
; Subase 1d: Starting at first char ending at last char
;
subcase1d
	do:('c1init) case1init
       	write "  Subcase 1d: Starting at first char ending at last char",!
	set z=$extract(y,1,999999)
	do verifyresult(z,y)
;
; Subcase 2a: Starting at first char, ending in middle (start on ascii, end on ascii)
;
subcase2a
	do:('c2init) case2init
	write "  Subcase 2a: Starting at first char, ending in middle (start on ascii, end on ascii)",!
	set z=$extract(y,1,19)
	do verifyresult(z,"1234567890"_$char(195)_"12345678")
;
; Subcase 2b: Starting at first char, ending in middle (start on ascii, end on ascii)
;
subcase2b
	do:('c2init) case2init
	write "  Subcase 2b: Starting at first char, ending in middle (start on ascii, end on utf8)",!
	set z=$extract(y,1,11)
	do verifyresult(z,"1234567890"_$char(195))
;
; Subcase 2c: Starting at first char, ending in middle (start on utf8, end on ascii)
;
subcase2c
	do:('c2init) case2init
	write "  Subcase 2c: Starting at first char, ending in middle (start on utf8, end on ascii)",!
	set z=$extract(y1,1,11)
	do verifyresult(z,$char(195)_"1234567890")
;
; Subcase 2d: Starting at first char, ending in middle (start on utf8, end on utf8)
;
subcase2d
	do:('c2init) case2init
	write "  Subcase 2d: Starting at first char, ending in middle (start on utf8, end on utf8)",!
	set z=$extract(y1,1,12)
	do verifyresult(z,$char(195)_"1234567890"_$char(196))
;
; Subcase 2e: Starting in middle, ending in middle+N (start on ascii, end on ascii)
;
subcase2e
	do:('c2init) case2init
	write "  Subcase 2e: Starting in middle, ending in middle+N (start on ascii, end on ascii)",!
	set z=$extract(y,3,20)
	do verifyresult(z,"34567890"_$char(195)_"123456789")
;
; Subcase 2f: Starting in middle, ending in middle+N (start on ascii, end on utf8)
;
subcase2f
	do:('c2init) case2init
	write "  Subcase 2f: Starting in middle, ending in middle+N (start on ascii, end on utf8)",!
	set z=$extract(y,3,11)
	do verifyresult(z,"34567890"_$char(195))
;
; Subcase 2g: Starting in middle, ending in middle+N (start on utf8, end on ascii)
;
subcase2g
	do:('c2init) case2init
	write "  Subcase 2g: Starting in middle, ending in middle+N (start on utf8, end on ascii)",!
	set z=$extract(y,11,20)
	do verifyresult(z,$char(195)_"123456789")
;
; Subcase 2h: Starting in middle, ending in middle+N (start on utf8, end on ascii)
;
subcase2h
	do:('c2init) case2init
	write "  Subcase 2h: Starting in middle, ending in middle+N (start on utf8, end on utf8)",!
	set z=$extract(y,11,22)
	do verifyresult(z,$char(195)_"1234567890"_$char(196))
;
; Subcase 2i: Starting in middle ending at last char (start on ascii, end on ascii)
;
subcase2i
	do:('c2init) case2init
       	write "  Subcase 2i: Starting in middle ending at last char (start on ascii, end on ascii)",!
	set z=$extract(y,20,$length(y))
	do verifyresult(z,"90"_$char(196)_"1234567890")
;
; Subcase 2j: Starting in middle ending at last char (start on ascii, end on utf8)
;
subcase2j
	do:('c2init) case2init
       	write "  Subcase 2j: Starting in middle ending at last char (start on ascii, end on utf8)",!
	set z=$extract(y1,20,$length(y1))
	do verifyresult(z,"890"_$char(197)_"1234567890"_$char(198))
;
; Subcase 2k: Starting in middle ending at last char (start on utf8, end on ascii)
;
subcase2k
	do:('c2init) case2init
       	write "  Subcase 2k: Starting in middle ending at last char (start on utf8, end on ascii)",!
	set z=$extract(y,22,$length(y))
	do verifyresult(z,$char(196)_"1234567890")
;
; Subcase 2l: Starting in middle ending at last char (start on utf8, end on utf8)
;
subcase2l
	do:('c2init) case2init
       	write "  Subcase 2l: Starting in middle ending at last char (start on utf8, end on utf8)",!
	set z=$extract(y1,12,$length(y1))
	do verifyresult(z,$char(196)_"1234567890"_$char(197)_"1234567890"_$char(198))
;
; Case 3 - Detect BADCHAR and verify target string unchanged
;
case3
	write "Case 3: Detect BADCHAR and verify target string unchanged",!
	set saveetrap=$etrap
	set $etrap="do case3trap($zlevel)"
	set (z,zcopy)="this is the old string"
	set src="12345"_$zchar(255)_"7890"
	set z=$extract(src,5,7)
	write "  case fail - failed to detect BADCHAR",!
	goto case4
	;
	; Re-entry point when above $etrap trips - should be a BADCHAR error
	;
case3trap(lvl)
	if ($zstatus+0'=150381066) zwr $zstatus zshow "*" zhalt 1
	set $ecode=""				; Clear $ECODE
	set $etrap=saveetrap
	zgoto @("lvl:case3cont^"_$text(+0))
	;
	; Re-entry point after trap is handled and unwound.
	;
case3cont
	write:(zcopy=z) "  Success",!!
	write:(zcopy'=z) "  FAIL - z was changed to: ",$zwrite(z),!!
;
; Case 4 - Detect BADCHAR and verify target string unchanged (like case 3) except both src and target are
;          the same variable
;
case4
	write "Case 4: Detect BADCHAR and verify target string unchanged where src == target",!
	set saveetrap=$etrap
	set $etrap="do case4trap($zlevel)"
	set (src,srccopy)="12345"_$zchar(255)_"7890"
	set src=$extract(src,5,7)
	write "  case fail - failed to detect BADCHAR",!
	goto subcase5a
	;
	; Re-entry point when above $etrap trips - should be a BADCHAR error
	;
case4trap(lvl)
	if ($zstatus+0'=150381066) zwr $zstatus zshow "*" zhalt 1
	set $ecode=""				; Clear $ECODE
	set $etrap=saveetrap
	zgoto @("lvl:case4cont^"_$text(+0))
	;
	; Re-entry point after trap is handled and unwound.
	;
case4cont
	write:(src=srccopy) "  Success",!!
	write:(src'=srccopy) "  FAIL - z was changed to: ",$zwrite(z),!!
;
; Subcase 5a - Starting at first char (start on ascii)
;
subcase5a
	do:('c5init) case5init
       	write "  Subcase 5a: Starting at first char (start on ascii)",!
	set z=$extract(y,1,99999)
	do verifyresult(z,y)
;
; Subcase 5b - Starting at first char (start on utf8)
;
subcase5b
	do:('c5init) case5init
       	write "  Subcase 5b: Starting at first char (start on utf8)",!
	set z=$extract(y1,1,99999)
	do verifyresult(z,y1)
;
; Subcase 5c - Starting in middle char (start on ascii)
;
subcase5c
	do:('c5init) case5init
       	write "  Subcase 5c: Starting in middle char (start on ascii)",!
	set z=$extract(y,8,99999)
	do verifyresult(z,"890"_$char(195)_x_$char(196)_x)
;
; Subcase 5d - Starting in middle char (start on utf8)
;
subcase5d
	do:('c5init) case5init
       	write "  Subcase 5d: Starting in middle char (start on utf8)",!
	set z=$extract(y,11,99999)
	do verifyresult(z,$char(195)_x_$char(196)_x)
;
; Subcase 5e - Starting at last char (start on ascii - note contains no utf8 by definition)
;
subcase5e
	do:('c5init) case5init
       	write "  Subcase 5e: Starting at last char (start on ascii - note contains no utf8 by definition)",!
	set z=$extract(y,$length(y),99999)
	do verifyresult(z,"0")
;
; Subcase 5f - Starting at last char (start on utf8)
;
subcase5f
	do:('c5init) case5init
       	write "  Subcase 5f: Starting at last char (start on utf8)",!
	set z=$extract(y1,$length(y1),99999)
	do verifyresult(z,$char(198))
;
; Epilogue
;
epilogue
	write:(0=failures) !,"All subtests passed",!!
	write:(0'=failures) !,"Number of failing subtests: ",failures,!!
	quit

;
; Case 1 initialization: Extraction from a simple uncached string. Since no groups here, char type not important.
;
case1init
	set c1init=1
	write "Case 1: Extraction from a simple uncached string",!
	set x="1234567890"
	set y=x_$char(195)_x
	quit

;
; Case 2 initialization: Extraction from a fully cached string - all extractions should cross groups
;
case2init
	set c2init=1
	write "Case 2: Extraction from a fully cached string - all extractions should cross groups",!
casecommon
	set x="1234567890"
	set y=x_$char(195)_x_$char(196)_x
	set y1=$char(195)_x_$char(196)_x_$char(197)_x_$char(198)
	;
	; Sometimes set the starting point at the last character, sometimes at last character + 1
	;
	set zprime=$find(y,"x",$length(y)+$random(2))		; These $FIND() calls caches the strings except for
	set zprime=$find(y1,"x",$length(y1)+$random(2))		; .. the very last byte - which should be cached on
	    							; .. the first call that references the last char
	quit

;
; Case 5 initialization: Extraction from a fully cached string
;
case5init
	set c5init=1
	write "Case 5: Extraction from a fully cached string",!
	do casecommon
	quit

;
; Routine to verify result and print appropriate messages
;
verifyresult(result,expect)
	if ((expect=result)&($length(result)=$length(expect))) write "    Success",!!
	else  do
	. set failures=failures+1
	. write "    FAIL - expected ",$zwrite(expect)," [$length=",$length(expect),"] but received ",$zwrite(result)
	. write " [$length=",$length(result),"]",!!
	quit
