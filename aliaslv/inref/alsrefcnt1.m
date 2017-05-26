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
alsrefcnt1	;
	;
	write "Test that reference counts are properly maintained in case of a NOTEXTRINSIC error (from a QUIT *)",!
	;
        set $etrap="do err"
        set a=0
        write "LV_CREF of a = ",$VIEW("LV_CREF","a"),!
        for i=1:1:3 do funcals()
        write "LV_CREF of a = ",$VIEW("LV_CREF","a"),!
        zwrite
        quit
funcals()
        set a=i
        quit *a
err
        write $zstatus,!
        set $ecode=""
        quit
