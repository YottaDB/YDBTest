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
quitalsinv ;
	;
	; Test that alias variable reference counts are maintained correctly even in case of a QUITALSINV error.
	; Not doing so would result in test failure due to memory leaks being detected.
	;
	set $etrap="goto err"
        for k=1:1:10000 do
        . new a
        . if k#1000=0 do
	. . if '$data(zrealstor) set zrealstor=$zrealstor
	. . else  if $zrealstor'=zrealstor  write "TEST-E-FAILED : $zrealstor is increasing",!  zshow "*"  halt
        . set y=$$funcals()	;QUITALSINV error
	write "Test : PASSED",!
	quit

funcals()
	new
	set a=1
	quit *a
err
	set $ecode=""
        zgoto 2
	quit
