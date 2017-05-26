;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alslvgcol;
	;
	; Test that VIEW "LV_GCOL" works when there is LOTS of orphaned data
	; Not doing so would result in test failure due to memory leaks being detected.
	;
	set startrealstor=0
        for j=1:1:100 do
	.	for i=1:1:10000 do
	.	.	; create orphaned alias data
        .	.	set *a(1)=b,*b(1)=c,*c(1)=a
        .	.	kill *
	.	write "j = ",j," : LV_GCOL = ",$view("LV_GCOL"),!
	.	if j=1 set startrealstor=$zrealstor
	.	else   if startrealstor<$zrealstor  write "TEST-E-FAIL : $zrealstor is increasing",! zshow "*" halt
        quit
