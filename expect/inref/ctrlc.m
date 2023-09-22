;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2004-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ctrlc	;
	; Create some data for the zwrite and zshow "v"
	set a=0,i=0,x=0
	if $zsyslog("This is the active expect/ctrlc test M routine")
	set $ETRAP="set x=$zjobexam() halt"
	for i=1:1:100000 set a(i)=$j(i,100)
	; Start the main body of the test
	do sstep^ctrlc
	for i=1:1:20000000  SET x=x+1
	quit
gbl	;
	for i=1:1:20000000  SET ^x=i
	zwrite i
	quit
sstep   ; Modified from sstep.m to just zprint the line for expect's targetting
	set $zstep="zprint @$zpos  zstep into"
	zbreak sstep+3^ctrlc:"zstep i"
	write !,"Stepping STARTED",!
	quit
validate;
	do sstop	; Before executing anything, stop single-stepping (started in an earlier "do ^ctrlc" call)
			; This is needed so we don't print the "FAIL" string in the M code below as that would be
			; misinterpreted by "ctrlc.exp" as a test failure.
	write "Checking test status",!
	set z=$order(y("V",""),-1)
	if (z=100002)!($data(x)[0)!(x=20000000) set status="FAIL" zshow "*"
	else  set status="PASS"
	write status
	quit
; Test the interruption of ZSHOW "V"
zshow
	set $ETRAP="set x=$zjobexam() halt"
	write "Testing interrupt of zshow V",!
	zshow "v"
	quit
; Test the interruption of ZWRITE
zwrite
	set $ETRAP="set x=$zjobexam() halt"
	write "Testing interrupt of zwrite a",!
	zwrite a
	quit
; Test the interruption of an XECUTEd ZWRITE
xzwrite
	set $ETRAP="set x=$zjobexam() halt"
	write "Testing interrupt of xecuted zwrite a",!
	xecute "zwrite a"
	quit
; Hold a large number of locks to ensure that LKE SHOW -ALL is hit by a control-C
lockjob
	new start,i
	set start=$horolog
	write $text(+0)," startin at ",$zdate(start,"24:60:SS"),!
	for i=1:1:10000 lock +a(i)
	set ^lockjob=$job
	; Wait for stop or 10 minutes. Use hang to avoid spinning in a tight loop
	for  quit:$get(^stop,0)  hang 1 do:(600<$$^difftime($horolog,start))
	.	set ^stop=1 write "TEST-F-FAIL:lockjob:",start,":",$$^difftime($horolog,start),!
	write $text(+0)," exiting at ",$zdate($horolog,"24:60:SS"),!
	quit
; Job off a process to hold lots of locks so that we can interrupt LKE SHOW -ALL. Wait for 5 minutes
startlockjob
	new start
	set start=$horolog
	job lockjob^ctrlc:(output="lockjob.mjo":error="lockjob.mje":cmdline="lockjob")
	for  quit:$get(^stop,0)  quit:$data(^lockjob)  hang .5 do:(300<$$^difftime($horolog,start))
	.	set ^stop=1 write "TEST-F-FAIL:startlockjo:",start,":",$$^difftime($horolog,start),!
	quit
; Stop the lock holder and wait for it to die
stoplockjob
	set ^stop=1
	do ^waitforproctodie(^lockjob,600)
	quit
sstop   ;
	set $zstep=""
	set %zsaveio=$io use $p write !,"Stepping STOPPED",!  use %zsaveio
	quit

