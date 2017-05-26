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
gtm8116	;
	;
	; Test that $TEXT returns silently in case of error (no incorrect TPQUIT errors etc.)
	;
	quit

test1	;
	set writestr=$translate($justify("-",40)," ","-")
	write !,"Test case 1 : $TEXT at $tlevel=0",!
	write writestr,!
	write "$tlevel before $TEXT = ",$tlevel,!
	write "$text(^trigger#) = ",$text(^trigger#),!
	write "$tlevel after  $TEXT = ",$tlevel,!
	quit
test2	;
	set writestr=$translate($justify("-",40)," ","-")
	write !,"Test case 2 : $TEXT at $tlevel=1",!
	write writestr,!
	tstart ():serial
	write "$tlevel before $TEXT = ",$tlevel,!
	write "$text(^trigger#) = ",$text(^trigger#),!
	write "$tlevel after $TEXT = ",$tlevel,!
	tcommit
	quit
test3	;
	set writestr=$translate($justify("-",40)," ","-")
	write !,"Test case 3 : $TEXT at $tlevel=2",!
	write writestr,!
	tstart ():serial
	set ^x=1
	tstart ():serial
	set ^y=2
	write "$tlevel before $TEXT = ",$tlevel,!
	write "$text(^trigger#) = ",$text(^trigger#),!
	write "$tlevel after $TEXT = ",$tlevel,!
	trollback -1
	tcommit
	if ($get(^x)'=1)!($data(^y)'=0) write "TEST-E-FAIL",!
	quit
