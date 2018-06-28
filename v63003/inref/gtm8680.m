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
manylocks
        set ^stop=0
        set jmaxwait=0
	if $ZTRNLNM("proc")  do ^job("mlockschild^gtm8680",1,"""""")
	else  do ^job("mprocesseschild^gtm8680",100,"""""")
        set max=100000
	set maxit=0
	set minit=0
        set start=$h,cur=start,prev=start,previ=0,t=$$^difftime(cur,start)
        for i=1:1 do  quit:(t>15)
        . lock ^a(i#max):0
        . set cur=$h,diff=$$^difftime(cur,prev)  do
        . if diff>0 do  set prev=cur,previ=i,t=$$^difftime(cur,start)
	. . if t=2 set maxit=i-previ,minit=i-previ
	. . if t>=2 do
	. . . if i-previ>maxit set maxit=i-previ
	. . . if i-previ<minit set minit=i-previ
	write "# Max Iterations in a second=",maxit,!
	write "# Min Iterations in a second=",minit,!
	set delta=maxit-minit
	set avg=(maxit+minit)/2
	if delta<avg*.5 write "# No Significant Slowdown Experienced",!
	else  write "# Significant Slowdown Experienced",!
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
