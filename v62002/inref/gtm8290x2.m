;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Do not have comment lines after "label2" as that would mean two breakpoints with different line #s
	; could be treated as the same breakpoint and poses problems with "verifyzbreak^gtm8290".
label2	if $zlevel>maxdepth  quit
	new x,xstr,rand1,rand2
	set rand1=$random(maxlines2),rand2=$random(maxlines2)
	zbreak label2+rand1:"zcontinue"  set zbreakarray($incr(cntr),"label2",rand1)=""
	do verifyzbreak^gtm8290
        do copyandlink^gtm8290("gtm8290x1","gtm8290x")
        do ^gtm8290x
	zbreak label2+rand2:"zcontinue"  set:(rand2'=rand1) zbreakarray($incr(cntr),"label2",rand2)=""
	do verifyzbreak^gtm8290
	if (rand2'=rand1) kill zbreakarray(cntr) if $incr(cntr,-1) ; remove breakpoints that will pop off as the routine unwinds
	kill zbreakarray(cntr) if $incr(cntr,-1)
        quit
