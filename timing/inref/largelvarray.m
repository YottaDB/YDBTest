;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test that local array performance does not deteriorate exponentially with large # of nodes
;
largelvarray	; Local Array Scalability Test.
	;
	; We expect the Average $zut for node creation to be more or less constant even with large # of nodes in local array
	; We test this by noting down the average $zut for 2**10 nodes. And expect that the average stays within twice of
	; this value even with 2**22 nodes.
	;
	; Creating 2**10 nodes takes only tens of microseconds, so a single preemption or page fault while it runs can double
	; the average for that size. So each size is timed several times (more often for the smaller sizes, which are faster),
	; and the lowest average is used. A real increase with the number of nodes shows in every repetition, so it shows in
	; the lowest average too.
	;
	new Cycle,Iter,Size,Then,Span,Average,Reps,Rep,Avg
	set errcnt=0
	set Reps(10)=32,Reps(14)=16,Reps(18)=4,Reps(22)=3
	for Cycle=10,14,18,22 do
	.	set Size=2**Cycle
	.	for Rep=1:1:Reps(Cycle) do
	.	.	new Array
	.	.	set Then=$zut
	.	.	for Iter=1:1:Size set Array(Iter)=Iter
	.	.	set Span=$zut-Then
	.	.	set Avg=Span/Size
	.	.	set Avg(Cycle,Rep)=Avg
	.	.	if (1=Rep)!(Avg<Average(Cycle)) set Average(Cycle)=Avg
	.	if (Cycle'=10)&(Average(Cycle)>(2*Average(10))) do
	.	.	if $incr(errcnt)
	.	.	write "TEST-E-FAIL : Average(10) = ",Average(10)," but Average(",Cycle,") = ",Average(Cycle)," (more than 2x)",!
	if errcnt=0  write "PASS from largelvarray : Average node creation time remained within limits from 2**10 to 2**22 nodes",!
	else         do
	.	write "FAIL from largelvarray : Average node creation time increased more than 2x from 2**10 to 2**22 nodes",!
	.	zshow "*"
	quit
