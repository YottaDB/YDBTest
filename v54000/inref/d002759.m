;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Based on test from Iselin report for bug D9K03-002759, setting invalid subscripts.
; Known to fail on V5.3-001 through V5.4-000
;
	; Failure expectation grid:
	;
	Set expect("UNDEF","NOLVNULLSUBS")="LVUNDEF"
	Set expect("UNDEF","LVNULLSUBS")="LVUNDEF"
	Set expect("UNDEF","NEVERLVNULLSUBS")="LVUNDEF"
	Set expect("NOUNDEF","NOLVNULLSUBS")="LVNULLSUBS"
	Set expect("NOUNDEF","LVNULLSUBS")=""
	Set expect("NOUNDEF","NEVERLVNULLSUBS")="LVNULLSUBS"

	Write !
	Set $ETrap="Do errortrap"

	For def="UNDEF","NOUNDEF" Do
	. For subs="NOLVNULLSUBS","LVNULLSUBS","NEVERLVNULLSUBS" Do
	. . Kill (def,subs,expect)
	. . View def
	. . View subs
	. . Set error=0
	. . Do prime4
	. . Do SimpleTest(.xdawarr)
	. . If ('error) Do	 ; Did not get an error - check if this is expected or not
	. . . If (expect(def,subs)'="") Write "FAIL -- Case ",def,"/",subs," VAR was defined",!
	. . . Else  Write "PASS -- Case ",def,"/",subs," VAR was defined",!
	. . Write !
	Quit

prime4
	New fake,fake2,fake3,fake4
	Set fake="hello"
	Set fake2="philadelphia"
	Set fake3="pennsylvania"
	Set fake4="eagles"
	Quit

SimpleTest(inputArr) ;,expectfail)
	New count
	Set inputArr(count)="null subscript value"
	Quit

errortrap
	; Isolate error
	Write $ZStatus,!
	Set err=$Piece($ZStatus,",",3)
	Set err=$Piece(err,"-",3)
	Set err=$Piece(err,",",1)
	If err=expect(def,subs) Write "PASS - Case ",def,"/",subs,!
	Else  Write "FAIL - Case ",def,"/",subs," got a ",err," error instead of the expected ",expect(def,subs),!
	Set error=1	  ; Tell main an error did occur
	Set $ECode=""
	Quit
