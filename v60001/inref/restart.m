;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
envdelta(iter);
	set ^myjob=$j
	; Each invocation of tprestart will cause one TP restart
	for i=1:1:iter do tprestart^restart
	quit
viewdelta(iter,flag,val);
	; iter = no of restarts.
	; flag = whether VIEW "LOGTPRESTART" has any value.
	; val  = value for VIEW "LOGTPRESTART" if flag is TRUE.
	set ^myjob=$j
	; Each invocation of tprestart will cause one TP restart
	if (1=flag) view "LOGTPRESTART":val
	else  view "LOGTPRESTART"
	for i=1:1:iter do tprestart^restart
	view "NOLOGTPRESTART"
	quit
tprestart;
	tstart ():serial
	set ^a($job)=1
	zsystem "mumps -r %XCMD ""set ^a("_$job_")=2"""
	tcommit
	quit
tpbitmaprestart;
	set numjobs=5,jmaxwait=0,^stop=0
	; Create globals beforehand to avoid directory tree block conflict
	for i=1:1:numjobs set @("^a"_i)=0
	do ^job("child^restart",numjobs,"""""")
	hang 15
	set ^stop=1
	do wait^job
	quit
child;
	set gname="^a"_jobindex
	for i=1:1 do  quit:^stop
	. ; We want to ensure the TP transaction restarts with a BITMAP conflict. For that, one needs to make
	. ; sure the TP transaction uses up at least half a bitmap in terms of space that way two processes that
	. ; converge on the same bitmap for allocation cannot both commit (i.e. at least one will have to restart).
	. ; Since there are 512 bytes in a bitmap block, allocate 300 blocks in the TP transaction.
	. ; This can be achieved by setting 300 nodes, each of which take up more than half a GDS block (size 4K)
	. ; so set the node size to be 3K.
	. tstart ():serial
	. for j=0:1:300 set @gname@(i*10+j)=$j(i,3000)
	. tcommit
	quit
