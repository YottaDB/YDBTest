;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
start	;
	; Start background process that sends mupip intrpts
	set jmaxwait=0
	set ^stop=0
	do ^job("child^readcmdrecallhist",1,"""""")
	quit

child	;
	; Find out signal # for SIGUSR1 from posix plugin
	if $&ydbposix.signalval("SIGUSR1",.sigval)
	; Send SIGUSR1 to parent process with random sleep in between until parent signals us to stop interrupting
	for  quit:^stop=1  hang (0.01)*$random(10) if $zsigproc(^parent,sigval)
	quit

stop	;
	; Wait for child process to terminate
	set ^stop=1
	do wait^job
	quit
