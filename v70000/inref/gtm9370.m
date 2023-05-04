;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Create several boolean expressions but create each of the exprs in a separate file because
; if they fail (which they mostly will on versions prior to a version with V70000 merged
; aka r2.00), they stop execution. See full description at the top of u_inref/gtm9370.csh or
; in the reference file.
;
gtm9370
	set maxExprCnt=10
	;
	; Drive initialization with the script
	;
	do Init^BooleanExprGen("DIV0")
	;
	; Now create a different file for each generated expression
	;
	write "# -- Generating ",maxExprCnt," expressions and a routine for each",!
	for exprStmt=1:1:maxExprCnt do
	. do CreateRoutine^BooleanExprGen("gtm9370expr"_exprStmt_".m",$text(+0))	; Resets $io to new file
	. write TAB,";",!
	. write TAB,"; Set a different ETRAP to verify the error is a DIVZERO error - else FAIL",!
	. write TAB,";",!
	. write TAB,"set $etrap=""do gtm9370VerifyDIVZERO""",!
	. set expr=$$BooleanExprGen^BooleanExprGen()
	. write TAB,";",!
	. write TAB,"; Test expression: set x=",expr,!
	. write TAB,";",!
	. write TAB,"set x=",expr,!
	. write TAB,";",!
	. write TAB,"; If we come back here instead of to the error handler, then we must have hit some short circuit",!
	. write TAB,"; issue - just ignore that and pretend it pseudo-passed but we'll make sure they aren't ALL like this!",!
	. write TAB,";",!
	. write TAB,"write ""PASS"",!",!
	. write TAB,"halt",!
	. write !
	. write ";",!
	. write "; Error routine to verify got DIVZERO error and not something else.",!
	. write ";",!
	. write "gtm9370VerifyDIVZERO",!
	. write TAB,"if $zstatus[""-E-DIVZERO"" do",?40,"; If this error is a DIVZERO, this is easy",!
	. write TAB,". write ""PASS"",!",!
	. write TAB,". zhalt 1",!
	. write TAB,";",!
	. write TAB,"; Else report the error in full",!
	. write TAB,";",!
	. write TAB,"zshow ""*"" zhalt 1",!
	. do GenEndOfFile^BooleanExprGen("")			; Unsets $io
	;
	; Now drive each one as an independent routine
	;
	use $p
	set (compfailcnt,runfailcnt)=0				; Count failures of each type
	for i=1:1:maxExprCnt do
	. write !
	. write "Running gtm9370expr",i,".m",!
	. zsystem "$gtm_dist/mumps gtm9370expr"_i_".m"
	. if $zsystem'=0 do
	. . write "Routine gtm9370expr",i,".m failed to compile",!
	. . if $increment(compfailcnt)
	. else  do
	. . zsystem "$gtm_dist/mumps -run gtm9370expr"_i	; We expect this run to fail
	. . if $zsystem=0 if $increment(runfailcnt)		; Increment runfailcnt if the execution succeeded
	;
	; If ANY of our compiles failed, we consider that a failed test as that is what we are testing - that we've
	; pushed the failures to runtime from compile time.
	;
	if compfailcnt'=0 do
	. write "FAIL - compile failures ",compfailcnt," out of ",maxExprCnt,!
	else  do
	. ;
	. ; If ALL of our run succeeded, we also consider that a fail as they should be pushing up DIVZERO errors but it is
	. ; possible (though less likely with larger numbers of maxExprCnt) to have all expressions generated such that all
	. ; expressions have a short circut that bypasses the divide-by-zero expressions. We still track this condition by
	. ; writing the fail counts to a file.
	. ;
	. zsystem "echo 'Tests which were expected to fail but did not: "_runfailcnt_"' > runfailcnt.txt"
	. if runfailcnt=maxExprCnt do
	. . write "FAIL - all runs completed without the expected errors",!	; Chance can be mitigated by increasing maxExprCnt
	. else  do
	. . write !,"PASS from gtm9370",!
	quit
