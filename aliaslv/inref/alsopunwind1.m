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
alsopunwind1	;
	;
	write "Test QUIT * while in a frame where a primary error already occurred (i.e. $ecode is non-NULL).",!
	;
        set $etrap="goto err"
        Set *y=$$funcals()               ;QUITALSINV
        quit
funcals()
        New
        set x=1/0
xy      ;
        Set a=1
        Quit *a
err
        goto xy
        quit
