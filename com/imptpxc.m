;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; These are collection of helper M routines used by simpleapi_imptp.c
;
dupsetnoop;
	view "GVDUPSETNOOP":1
	quit

getdatinfo;
	 do get^datinfo("^%imptp("_fillid_")")
	 quit

tpnoiso;
	view "NOISOLATION":"^arandom,^brandomv,^crandomva,^drandomvariable,^erandomvariableimptp,^frandomvariableinimptp,^grandomvariableinimptpfill,^hrandomvariableinimptpfilling,^irandomvariableinimptpfillprgrm,^jrandomvariableinimptpfillprogram"
	write "$view(""NOISOLATION"",""^arandom"")=",$view("NOISOLATION","^arandom"),!
	write "$view(""NOISOLATION"",""^brandomv"")=",$view("NOISOLATION","^brandomv"),!
	write "$view(""NOISOLATION"",""^crandomva"")=",$view("NOISOLATION","^crandomva"),!
	write "$view(""NOISOLATION"",""^drandomvariable"")=",$view("NOISOLATION","^drandomvariable"),!
	write "$view(""NOISOLATION"",""^erandomvariableimptp"")=",$view("NOISOLATION","^erandomvariableimptp"),!
	write "$view(""NOISOLATION"",""^frandomvariableinimptp"")=",$view("NOISOLATION","^frandomvariableinimptp"),!
	write "$view(""NOISOLATION"",""^grandomvariableinimptpfill"")=",$view("NOISOLATION","^grandomvariableinimptpfill"),!
	write "$view(""NOISOLATION"",""^hrandomvariableinimptpfilling"")=",$view("NOISOLATION","^hrandomvariableinimptpfilling"),!
	write "$view(""NOISOLATION"",""^irandomvariableinimptpfillprgrm"")=",$view("NOISOLATION","^irandomvariableinimptpfillprgrm"),!
	write "$view(""NOISOLATION"",""^jrandomvariableinimptpfillprogram"")=",$view("NOISOLATION","^jrandomvariableinimptpfillprogram"),!
	quit

helper1	;
	do pauseifneeded^pauseimptp
	set subs=$$^ugenstr(I)
	set val=$$^ugenstr(loop)
	do:dztrig ^imptpdztrig(1,istp<2)
	set ztwormstr="set $ztwormhole=subs"
	set recpad=recsize-($$^dzlenproxy(val)-$length(val))				; padded record size minus UTF-8 bytes
	set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
	set valMAX=$j(val,recpad)
	set valALT=$select(span>1:valMAX,1:val)
	set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))	; padded key size minus UTF-8 bytes. ZTP uses no padding
	set subsMAX=$j(subs,keypad)
	if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
	quit

