;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set $etrap="write $zstatus,! zshow ""*"" halt"
        set maxdepth=1+$r(100)
	set maxlines0=$$getsrclinelen^gtm8290("gtm8290x0","label0")
	set maxlines1=$$getsrclinelen^gtm8290("gtm8290x1","label1")
	set maxlines2=$$getsrclinelen^gtm8290("gtm8290x2","label2")
        do copyandlink^gtm8290("gtm8290x0","gtm8290x")
        do ^gtm8290x
	do verifyzbreak^gtm8290
	write "Test DONE",!
        quit
copyandlink(source,dest)
        new errno
        if $&ydbposix.cp(source_".m",dest_".m",.errno)  write "Error using ydbposix.cp. errno = ",errno,!  zshow "*" halt
        zcompile dest_".m"
        zlink dest
        quit
setzbreak(label,offset)
	; Ideally we need to use this to set breakpoints in gtm8290x{0,1,2}.m but since we want to test
	; relative breakpoints (i.e. zbreak commands which dont have a routine name in them) we cannot
	; use this. But this is kept just in case.
	new zbstr
	set zbstr="zbreak "_label_"+"_rand1_":""zcontinue"""
	set zbreakarray(label,offset)=""
	xecute zbstr
	quit
verifyzbreak
	new i,x,cmp1,cmp2,subs
	zshow "b":x
	if $data(x) for i=1:1  set subs=$get(x("B",i))  quit:subs=""  if $incr(cmp1(subs))
	if $data(zbreakarray) for i=1:1:cntr do
	. set label=$order(zbreakarray(i,"")),offset=$order(zbreakarray(i,label,""))
	. if $incr(cmp2(label_$select(offset:"+"_offset,1:"")_"^gtm8290x"))
	if ($data(cmp1)'=$data(cmp2)) do halt
	set subs="" for  set subs=$order(cmp1(subs),1)  quit:subs=""  do
	. if $get(cmp2(subs))'=$get(cmp1(subs))  do halt
	. kill cmp1(subs),cmp2(subs)
	if $data(cmp2) do halt
	quit
getsrclinelen(rtnname,label)
	new i
	for i=1:1  quit:(""=$text(@label+i^@rtnname))
	quit i-1
halt	;
	write "ZBREAK verification failed",!  zshow "*" halt
	quit
