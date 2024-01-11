;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm9408 ;
	write "# JOB off child process that does the [HANG 3]",!
        job child
        set childpid=$zjob
	write "# Wait for child process to reach the [HANG 3] point",!
        for  lock ^hang:0  quit:'$test
	write "# Now that we know the child process is in the middle of [HANG 3], reset system date back by 100 seconds",!
	write "# and send it a [mupip intrpt] to exercise the faulty code path fixed by GTM-9408.",!
        set zsystr="sudo date -s '-100 seconds' > date.out; $gtm_dist/mupip intrpt "_childpid_" >& intrpt.out"
        zsystem zsystr
	write "# Wait for child process to terminate",!
        do ^waitforproctodie(childpid)
	write "# Print the elapsed time during the [HANG 3] in the child process",!
	write "# We expect a value of 3 in the ^difftime global below",!
	write "# In case of system load, it is possible the elapsed time is more than 3 seconds so we allow",!
	write "# anywhere from 3 to 5 seconds to show up as the value of ^difftime global below.",!
        zwrite ^difftime
        quit

child   ;
	; Do a [HANG 3] and note down the elapsed time and store it in the [^difftime] global that is read by the parent
	;
        set begintime=$horolog
        lock ^hang($job)
        hang 3
        set endtime=$horolog
        set ^difftime=$$^difftime(endtime,begintime)
        quit

