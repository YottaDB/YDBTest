;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
d002779	;
	quit

init	;
	set dashstr="-----------------------------------------------"
	new $ztrap
	set $etrap="do etr"
	quit

etr	;
	write $zstatus,!
	quit

test1	;
	do init
	write "Test that TRESTART outside of TP does not SIG-11",!
	write dashstr,!
	trestart
	quit

test2	;
	do init
	write "Test that $trestart stays positive AND indefinite # of TRESTART commands are disallowed",!
	write dashstr,!
        set restartcnt=0
	set ^rand(1)=$r(2),^rand(2)=$r(2)
        tstart ():serial
        set restartcnt=restartcnt+1
        write "$trestart=",$trestart,!
        if ^rand(2)  set ^a(restartcnt)=$j
	TRestart:(restartcnt<100)
	Write "TP restarts occurred more than 100. Test fail",!
	tcommit
	quit
