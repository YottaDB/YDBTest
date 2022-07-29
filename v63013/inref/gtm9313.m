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
; GTM-9313 - test that $ORDER() with a first argument that contains subscript with both Boolean expression
; and a global referece with the second argument being a literal. Create an array with extra elements in it
; so we don't have to handle a null string return from $ORDER().
;
gtm9313
	;
	; Load up the DB with values to $ORDER through
	;
	kill ^td
	for i=0:1:10 do
	 . set ^td(i)=$select(0=(i#2):1,1:0)			; 1 if sum of subscripts is even, else 0
	;
	; Initialize boolean expression generator
	;
	do Init^BooleanExprGen
	;
	; Run the array in the reverse order that we generated it in. Since the $ORDER() call we will be doing is
	; in a forward direction, start the run at 9 instead of 10 so if the boolean expression resolves to 9, we
	; can find the 10 subscript.
	;
	for i=9:-1:0 do
	. set expr=$$BooleanExprGen^BooleanExprGen()		; Create a boolean expression
	. set @("rslt="_expr)					; Evaluate here first
	. set @("newl=$order(^td(i-("_expr_")),1)")		; Substitute in the expression in the $ORDER() command
	. if ((i-rslt+1)'=newl) do
	. . write !,"Unexpected results: i: ",i,"  rslt: ",rslt,"  newl: ",newl,"  i-rslt+1: ",i-rslt+1,!
	. . write "                    expr: ",expr,!!
	. . zshow "*"
	. . zhalt 1
	write !,"Test completed",!!
	quit

;
; Routines used by the generated boolean expressions
;
Always0()
	quit 0
Always1()
	quit 1
RetSame(x)
	quit x
RetNot(x)
	quit '(x)
