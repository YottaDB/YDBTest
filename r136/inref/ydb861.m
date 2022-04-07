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
; Drive a number of parameters to $zatransform() to both validate that they give the expected
; result but that they don't explode. Prior to issue YDB#861, all of the calls where an expression
; was used in the first parameter would sometimes get a sig-11. In addition most of the calls with
; either 2 or -2 in the 3rd parameter would get incorrect return values when the input value was
; arithmetically computed and thus had no existing string component.
ydb861
	set a=1,b=1
	for parm1="0&1","a-b","1=2","1-1","0","1","$zchar(248)",""":""","""/""" do
	. for parm3=2,-2 do
	. . for parm4=0,1 do
	. . . set cmd="$zwrite($zatransform("_parm1_",0,"_parm3_","_parm4_"))"
	. . . write cmd," : "			; Write the expression we'll be evaluating
	. . . xecute "set x="_cmd
	. . . write x," : ("			; Write the 1 character computed value out as text
	. . . xecute "write $ascii("_x_")"	; Write the value out as an ASCII decimal value
	. . . write ")",!
