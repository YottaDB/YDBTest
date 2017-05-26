;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitlkeshow(nblocked);
	;
	; Routine that keeps doing LKE SHOW WAIT and returns only after we see at least "nblocked" lines of the following form
	;	in the LKE SHOW -WAIT output
	; -----------------------------------------------------------
	; ^gvn(...) Request  PID= 32480 which is an existing process
	; -----------------------------------------------------------
	;
	new dev,command,cmdop,nwaiters
        set dev="gtmProc"
        open dev:(command="$gtm_exe/lke":exception="goto done")::"PIPE"
	use dev
	for  do  quit:(nblocked<=nwaiters)  hang 0.1
	. write "SHOW -WAIT",!
	. set nwaiters=0
	. for  read showout quit:(showout["LOCKSPACEUSE")  do
	. . if showout["Request  PID= " if $incr(nwaiters)
done    if '$zeof write !,$zstatus
        close dev
        quit
