;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sigproc(sig); JOB a mumps process which will send the parent process TERM or TSTP signal.
        set ^myjob=$JOB
	set ^signal=sig
        write ^myjob,!
	write "started",!
        set jmaxwait=0,jobid=$increment(^currentjob)
        lock +^dontshootme
	set cmd="shootme^sigproc"
        do ^job(cmd,1,"""""")
        lock -^dontshootme
        zsy
        quit
shootme
        lock +^dontshootme
        zsy "kill -"_^signal_" "_^myjob
        lock -^dontshootme
	write "DONE",!
        quit
