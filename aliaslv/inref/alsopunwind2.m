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
alsopunwind2	;
	;
	; Test QUIT * maintains reference counts correctly even in case of nested runtime errors
	; Not doing so would result in test failure due to memory leaks being detected.
	;
        for k=1:1:10000 do
        . new a
        . if k#1000=0 do
	. . if '$data(zrealstor) set zrealstor=$zrealstor
	. . else  if $zrealstor'=zrealstor  write "TEST-E-FAILED : $zrealstor is increasing",!  zshow "*"  halt
        . do a
	write "Test : PASSED",!
        quit
a       ;
        set $etrap="goto err1"
        set y=$$b()
        quit
b()
        set x=1/0	; DIVZERO is primary error
        quit
err1
        set $etrap="goto err2"
        set a=1
        quit *a		; QUITALSINV is secondary error
err2
        set $ecode=""
        zgoto 2
        quit
