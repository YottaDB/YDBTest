;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
; Test that local array performance does not deteriorate exponentially with large # of nodes
;
largelvarray	; Local Array Scalability Test.
	;
	; We expect the Average $zut for node creation to be more or less constant even with large # of nodes in local array
	; We test this by noting down the average $zut for 2**10 nodes. And expect that the average stays within twice of
	; this value even with 2**22 nodes.
	;
	new Cycle,Iter,Size,Then,Span,Average
	set errcnt=0
	for Cycle=10,14,18,22 do
	.	new Array
	.	set Size=2**Cycle
	.	set Then=$zut
	.	for Iter=1:1:Size set Array(Iter)=Iter
	.	set Span=$zut-Then
	.	set Average(Cycle)=Span/Size
	.	if (Cycle'=10)&(Average(Cycle)>(2*Average(10))) do
	.	.	if $incr(errcnt)
	.	.	write "TEST-E-FAIL : Average(10) = ",Average(10)," but Average(",Cycle,") = ",Average(Cycle)," (more than 2x)",!
	if errcnt=0  write "PASS from largelvarray : Average node creation time remained within limits from 2**10 to 2**22 nodes",!
	else         do
	.	write "FAIL from largelvarray : Average node creation time increased more than 2x from 2**10 to 2**22 nodes",!
	.	zshow "*"
	quit
