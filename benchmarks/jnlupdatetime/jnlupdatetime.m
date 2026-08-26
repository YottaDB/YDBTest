;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jnlupdatetime	;
	; Journaled update throughput, for measuring the cost of the YDB#1258 change to
	; SET_GBL_JREC_TIME.  Reports NANOSECONDS PER UPDATE, so two builds can be compared
	; directly.  The change adds one clock_gettime(CLOCK_REALTIME) per transaction commit
	; in place of one time(), measured standalone at about 26 nanoseconds.
	;
	; Reports the MINIMUM over the trials, not the mean.  The minimum is the trial least
	; disturbed by whatever else the machine was doing, which is what is wanted when the
	; effect being looked for is around one percent.
	quit
	;
	; $ZCMDLINE is "<workload> <updates per trial> <trials>", workload "point" or "tree".
run	;
	new wkld,n,trials,i,t0,t1,trial,us,best,nsper
	set wkld=$piece($zcmdline," ",1)
	set n=$piece($zcmdline," ",2)
	set trials=$piece($zcmdline," ",3)
	set best=""
	for trial=1:1:trials do
	. kill ^bench
	. if wkld="point" do
	. . set t0=$zut
	. . for i=1:1:n set ^bench=i
	. . set t1=$zut
	. else  do
	. . set t0=$zut
	. . for i=1:1:n set ^bench(i)=i
	. . set t1=$zut
	. set us=t1-t0
	. if best=""!(us<best) set best=us
	set nsper=best*1000/n
	write wkld,",",n,",",trials,",",$justify(nsper,0,1),!
	quit
