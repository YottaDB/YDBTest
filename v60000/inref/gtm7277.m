;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2012-2015 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-7277 - Validate boolean expression evaluation
;
gtm7277
	set exprcnt=$select(($zversion'["x86_64"):1500,1:5000)	; Create this many expressions - each tested several ways
	set $etrap="Do Error^BooleanExprGen"
	do Init^BooleanExprGen
	do CreateRoutine^BooleanExprGen("btest.m")
	;
	; Generate expressions and put each one into three test cases.
	;
	For exprnum=1:1:exprcnt Do
	. set type=$random(2)				; Types are: 0 uses always0/1() and 1 uses retnot/same() routines
	. set expr=$$BooleanExprGen^BooleanExprGen	; Create expression for this set of tests
	. set initnaked=(0'=$zfind(expr,"^"))  		; Has a global ref in it so reinit naked for each phrase
	. write !,TAB,"write ""Expr#",exprnum,":""",!
	. write TAB,"if nextt",?29,"; SET $TEST to next progressive value",!
	. write TAB,"set t=$TEST",?29,"; Save so usage in each expression usage is repeatable",!
	. write:(lasttstnaked&('initnaked)) TAB,"set x=^dummy",?29,"; Init naked for all tests this expr",!
	. ;
	. ; Generate expression tests
	. ;
	. write TAB,"write ?12,"" Exp:"",(",expr,"),""/"",$reference",!
	. write TAB,"if (",expr,") write ?32,"" If:1/"",$reference",!
	. write TAB,"else  write ?32,"" if:0/"",$reference",!
	. write TAB,"set nextt=$test",?29,"; Save for restore next test so don't have same $TEST for all exprs",!
	. ;
	. ; Generate argument post conditional - determine which of 4 types to use (DO, GOTO, XECUTE, ZGOTO)
	. ;
	. set apctyp=$random(4)
	. write TAB,"if t",?29,"; Restore initial $TEST value",!
	. write TAB,"write ?52,"" APC:""",!
	. if (0=apctyp) do		; Generate DO type APC
	. . write TAB,"do Write1:(",expr,"),Write0:('(",expr,"))",!
	. . write TAB,"write ""/"",$reference",!
	. else  If (1=apctyp) do	; Generate Xecute type APC
	. . write TAB,"xecute ""do Write1"":(",expr,"),""do Write0"":('(",expr,"))",!
	. . write TAB,"write ""/"",$reference",!
	. else  do	      	   	; Generate GOTO and ZGOTO types of APC
	. . write TAB,$Select((2=apctyp):"goto ",1:"zgoto zl:"),"Lbl",exprnum,"A:(",expr,"),",$Select((3=apctyp):"zl:",1:""),"Lbl",exprnum,"B:('(",expr,"))",!
	. . write TAB,"write ""FAIL - neither condition tripped"",!",!
	. . write TAB,"goto Lbl",exprnum,"Done",!
	. . write "Lbl",exprnum,"A write 1",!
	. . write TAB,"goto Lbl",exprnum,"Done",!
	. . write "Lbl",exprnum,"B write 0",!
	. . write "Lbl",exprnum,"Done",!
	. . write TAB,"write ""/"",$Reference",!
	. ;
	. ; Generate post-conditional test - comes last due to propensity for broken boolean to eval both expressions
	. ; as TRUE printing two values. At the end, this doesn't interfere with anything.
	. ;
	. write TAB,"write:(",expr,") ?72,"" CPC:1/"",$reference",!
	. write TAB,"write:('(",expr,")) ?72,"" CPC:0/"",$reference",!
	. ;
	. ; Each test is one line long so write end of test newline
	. ;
	. write TAB,"write !",!
	. set lasttstnaked=initnaked
	;
	; Write the end of file extrinsics out and close the file
	;
	do GenEndOfFile^BooleanExprGen("GenExtrinsics^gtm7277")
	;
	; All done!
	;
	write "Test routine with ",exprcnt," expressions created",!
	quit

;
; Routine used as a callback from GenEndOfFile^BooleanExprGen to write out some additional extrinsics used in expressions above
;
GenExtrinsics
	use ofile
	write "Write0",!
	write TAB,"write 0",!
	write TAB,"quit",!
	write "Write1",!
	write TAB,"write 1",!
	write TAB,"quit",!
	quit
