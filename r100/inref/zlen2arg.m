;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test to validate $[Z]LENGTH() with 2 arguments with a single char delimiter specified and its creation/use of the same
; look-aside cache that $[Z]PIECE() use.
;
; Methodology:
;   Create a string that looks like "1/2/3/4/5..." where each piece is delimited by the character '/' and each piece has the value
;   of the piece index. After adding each piece, and again after adding each delimiter, check the values returned by both $LENGTH and
;   $ZLENGTH then also using $[Z]PIECE() to pull off each token comparing it with the expected value in the list to make sure there
;   are no cache problems.
;
zlen2arg()
	write "Test two argument $[Z]LENGTH() interaction with $[Z]PIECE() cache",!
	set strbase=""
	set delim="/"
	set errcnt=0
	set maxpcs=100				; Should be larger than FNPC_ELEM_MAX in fnpc.h
	for tpcnt=1:1:maxpcs do			; Make sure we overflow the cache with pieces
	. ;
	. ; Step 1 this iteration is to add a new piece - in this case add the current total piece count (tpcnt) as a piece and
	. ; using $ZLENGTH().
	. ;
	. set strbase=strbase_tpcnt
	. do CheckPieces(.strbase,delim,1,.zcpc)
	. do CheckPieces(.strbase,delim,2,.cpc)
	. ;
	. ; Verify both methods yield same result
	. ;
	. if (zcpc'=tpcnt) write "FAIL -- [1] $ZLENGTH() expected to be ",tpcnt," but was ",zcpc," instead",! set errcnt=errcnt+1
	. if (cpc'=tpcnt) write "FAIL -- [1] $LENGTH() expected to be ",tpcnt," but was ",cpc," instead",! set errcnt=errcnt+1
	. ;
	. ; Now add a delimiter and retest (should be one higher)
	. ;
	. set strbase=strbase_delim
	. do CheckPieces(.strbase,delim,1,.zcpc)
	. do CheckPieces(.strbase,delim,2,.cpc)
	. ;
	. ; Verify both methods yield same result
	. ;
	. if (zcpc'=(tpcnt+1)) write "FAIL -- [2] $ZLENGTH() expected to be ",tpcnt+1," but was ",zcpc," instead",! set errcnt=errcnt+1
	. if (cpc'=(tpcnt+1)) write "FAIL -- [2] $LENGTH() expected to be ",tpcnt+1," but was ",cpc," instead",! set errcnt=errcnt+1
	;
	; Check for errors
	;
	if (0=errcnt) write !,"PASS - no errors detected",!!
	else  write !,"FAIL -- total of ",errcnt," error(s) detected",!!
	;
	; This next test is primarily a UTF8 test (and will run differently in UTF8 and M modes) but we'll run in both anyway to
	; be consistent. Start with a string that exceeds the number of pieces that can be kept in cache - the strbase string
	; created in the previous step is handy but we need to do 2 things:
	;   1. Turn off BADCHAR so we can have illegal UTF8 chars.
	;   2. Translate the current '/' delimiter to $zchar(132).
	; This allows us to append $char(196) to the end of the string. Note this is a 2 byte UTF8 character $zchar(195,132). Note the
	; 2nd byte is the same as the delimiter but should not be recognized as such by $LENGTH() since it is part of a valid
	; character.
	;
	write "Testing trailing UTF8 char whose last char is same as delimiter",!!
	view "NOBADCHAR"
	set newdelim=$zchar(132)
	set str1=$translate(strbase,delim,newdelim)
	set len1=$length(str1,newdelim)
	set str2=str1_$zchar(196)
	set len2=$length(str2,newdelim)
	write:(len1=len2) "PASS - trailing UTF8 char was not taken as a delimiter",!
	write:(len1'=len2) "FAIL - lengths of strings not as expected - length(str1): ",len1,"  length(str2): ",len2,!
	write !
	quit

;
; Routine to check the pieces in a string are what was originally built.
; Method 1 - $ZLENGTH/$ZPIECE
; Method 2 - $LENGTH/$PIECE
;
CheckPieces(str,delim,method,pcret)
	new plen,pidx,pc
	set plen=$select(1=method:$zlength(str,delim),2=method:$length(str,delim))
	set pcret=plen
	;
	; Validate each piece except for last piece if doing trailing delimiters
	;
	set traildelim=(delim=$zextract(str,$select(1=method:$zlength(str),2=method:$length(str))))
	for pidx=1:1:$select(traildelim:plen-1,'traildelim:plen) do
	. set pc=$select(1=method:$zpiece(str,delim,pidx),2=method:$piece(str,delim,pidx))
	. if (pc'=pidx) do
	. . write "FAIL -- ",$select(1=method:"$ZLENGTH()/$ZPIECE()",2=method:"$LENGTH/$PIECE()")," extraction - expected ",pidx
	. . write " but got ",pc," instead",!
	. . set errcnt=errcnt+1
	. . zshow "*"
	quit

