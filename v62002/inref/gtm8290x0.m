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
	; Do not have comment lines after "label0" as that would mean two breakpoints with different line #s
	; could be treated as the same breakpoint and poses problems with "verifyzbreak^gtm8290".
label0	view "LINK":"RECURSIVE"
	do verifyzbreak^gtm8290
	new x,xstr,rand0,rand1,rand2
	set rand0=1+$random(20),rand1=$random(maxlines0),rand2=$random(maxlines0)
        for i=1:1:rand0 do
	. zbreak label0+rand1:"zcontinue"  set:(i=1) zbreakarray($incr(cntr),"label0",rand1)=""
	. do verifyzbreak^gtm8290
        . do copyandlink^gtm8290("gtm8290x1","gtm8290x")
        . do ^gtm8290x
	. zbreak label0+rand2:"zcontinue"  set:(i=1)&(rand2'=rand1) zbreakarray($incr(cntr),"label0",rand2)=""
	. do verifyzbreak^gtm8290
        . do copyandlink^gtm8290("gtm8290x2","gtm8290x")
        . do ^gtm8290x
	if (rand2'=rand1) kill zbreakarray(cntr) if $incr(cntr,-1) ; remove breakpoints that will pop off as the routine unwinds
	kill zbreakarray(cntr) if $incr(cntr,-1)
        quit
