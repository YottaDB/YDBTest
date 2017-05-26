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
alsrefcnt2	;
	;
	; Test that reference counts are properly maintained in case of a NOTEXTRINSIC error (from a QUIT *)
	; Not doing so would result in test failure due to memory leaks being detected.
	;
        set $etrap="do err"
        for k=1:1:10000 do
        . new a
        . do
        . . set a=k  quit *a
        . if k#1000=0 do
	. . if '$data(zrealstor) set zrealstor=$zrealstor
	. . else  if $zrealstor'=zrealstor  write "TEST-E-FAILED : $zrealstor is increasing",!  zshow "*"  halt
	write "Test : PASSED",!
        quit
err
        set $ecode=""
        quit
