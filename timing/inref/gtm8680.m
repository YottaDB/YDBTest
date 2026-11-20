;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
manylocks
	set ^stop=0
	set jmaxwait=0
	if $ZTRNLNM("proc")  do ^job("mlockschild^gtm8680",1,"""""")
	else  do ^job("mprocesseschild^gtm8680",100,"""""")
	set max=100000
	set maxit=0
	set minit=0
	set its($increment(it))=0
	set start=$h,cur=start,prev=start,previ=0,t=$$^difftime(cur,start)
	; Count LOCK commands per second of CPU time used by this process, not per second of elapsed time.
	; On a loaded system this process gets a varying share of each elapsed second, so a count per elapsed second
	; can more than halve from one second to the next even though the cost of each LOCK command is unchanged.
	; $ZGETJPI(,"CPUTIM") is in units of 1/100 second. Compute a rate only after at least 50 such units of CPU time
	; were used since the previous rate, and keep going past 30 seconds until at least 5 rates are computed.
	set prevcpu=$zgetjpi($job,"CPUTIM")
	for i=1:1 do  quit:(t>30)&(it>5)
	. lock ^a(i#max):0
	. set cur=$h,diff=$$^difftime(cur,prev)
	. quit:diff'>0
	. set prev=cur,t=$$^difftime(cur,start)
	. set cpu=$zgetjpi($job,"CPUTIM")
	. quit:(cpu-prevcpu)<50
	. set rate=(i-previ)*100\(cpu-prevcpu),prevcpu=cpu,previ=i
	. set its($increment(it))=rate
	. if rate<minit set minit=rate
	. if rate>maxit set maxit=rate,minit=rate
	write "# Max Iterations in a CPU second=",maxit,!
	write "# Min Iterations after max=",minit,!
	if (maxit<(minit*2))  write "# No Significant Slowdown Experienced",!
	else  do
	. write "# Significant Slowdown Experienced",!
	. zwrite its
	zsystem "$LKE SHOW |& $grep LOCKSPACEINFO"
	set ^stop=1
	do wait^job
	quit

mlockschild   ;
	lock ^a
	for  quit:^stop=1  hang 1
	lock
	quit

mprocesseschild   ;
	for i=(jobindex*1000+1):1:((jobindex+1)*1000) quit:^stop=1  lock +^a(i)  if $incr(^locks)
	for  quit:^stop=1  hang 1
	lock
	quit
