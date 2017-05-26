;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lkewait2; second process to lock on a ^a, which is acquired by main
	set $zt="s $zt="""" g ERROR"
	new unix,i
        set unix=$zv'["VMS"
        if unix set ^pid2=$job
        else  set ^pid2=$$FUNC^%DH($job,0)
	;
	lock ^a:120
	if $t=0 write "TEST-E-lkewait2-Time out, waited too long for ^a",!  quit
	;	
	set ^flag2=^pid2_" got ^a"
	;
	; Do not quit immediately
	; Wait for response from main process
	;
	set ^waitstarttime=$horolog ; Save wait start time in case we get long delays
	for i=1:1:600 quit:$get(^q2)="quit2"  hang 1
	if i=600 write "TEST-E-Time out, parent did not signal me to continue: I am 2nd job ",^pid2,!
	quit
ERROR   ;
	zshow "*"
	quit
			
