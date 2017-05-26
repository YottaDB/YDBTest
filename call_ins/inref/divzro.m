;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2003-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Use 0
    W !,"Value of $ET in divzro: ",$ET
    W !,"divzro: $ZLEVEL = ",$ZLEVEL
    W !,"divzro: $STACK = ",$STACK
    W !,"divzro: $ESTACK = ",$ESTACK
    w !,"$stack(1,""PLACE"") in divzro = ",$stack(1,"PLACE")
    w !,"$stack(1,""MCODE"") in divzro = ",$stack(1,"MCODE")
    w !,"$stack(1,""ECODE"") in divzro = ",$stack(1,"ECODE")
    W !,1/0
    Q
ERR
    W !,"Illegal-- attempt to divide by zero"
    Use 0
    Q
