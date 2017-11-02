;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    S $ZT="G ERR"
    W !,"M2: $ZLEVEL = ",$ZLEVEL
    W !,"M2: $STACK = ",$STACK
    W !,"M2: $ESTACK = ",$ESTACK
    w !,"$stack(0,""PLACE"") in divzro3 = ",$stack(0,"PLACE")
    w !,"$stack(0,""MCODE"") in divzro3 = ",$stack(0,"MCODE")
    w !,"$stack(0,""ECODE"") in divzro3 = ",$stack(0,"ECODE")
    W !,1/0
    Q
ERR
    W !,"Illegal-- attempt to divide by zero"
    Use 0
    Q
