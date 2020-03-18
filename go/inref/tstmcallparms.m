;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Simplistic parameter update routine. Update the two updatable parms after verifying the first input value
; (which is type IO) is properly "pre-populated".
updentry(parm1,parm2,parm3)
	write:"parm1 value              "'=parm1 "ERROR: parm1 expected to be ""parm1 value              "" but was: "_$zwrite(parm1),!
	set parm1="This-is-the-UPDATED-parm1"
	set parm3="This-is-the-UPDATED-parm3"
	quit

TestROParmTypes1(parm1,parm2)
	if parm1'=parm2 do
	. write "Expecting parm1/parm2 to be equal but they were not - parm1: ",parm1,"  parm2: ",parm2,!
	quit

rd32parms(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32)
	zwrite
	quit
