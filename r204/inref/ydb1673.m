;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

litlab
	set max=1000
	set fn="test.m"
	set prev=$zut
	; Set shortest to 10 to ensure this variable gets set in the below loop,
	; since we do not expect a runtime in excess of 10 seconds for any set of iterations.
	set total=0
	for cnt=1:1:max do
	. open fn:(NewVersion)
	. use fn
	. write "lab"_cnt_"()",!
	. write " set lit"_cnt_"=""",cnt,"""",!
	. write " quit lit"_cnt,!
	. close fn
	. zlink fn
	. set x=$$^test
	. if '(x#100) do
	. . set curr=$zut
	. . set elapsed(cnt)=(curr-prev)/(10**6)
	. . set total=total+elapsed(cnt)
	. . write "Iteration = ",$justify(cnt,4)," : Elapsed time = ",$fnumber(elapsed(cnt),"",2),!
	. . set prev=curr

	; Compute standard deviation
	set n=(max\100)
	set elapsedMean=total/n
	set iter="",sum=0 for  set iter=$order(elapsed(iter)) quit:""=iter  do
	. set sum=sum+((elapsed(iter)-elapsedMean)**2)
	set mean=(sum/n)
	set stdev=(mean**0.5)	; Square root

	set maxStdev=0.3	; A value slightly higher than the highest observed (0.25) with the YDB#1673 fixes, but an order of magnitude lower than what observed before the fixes
	write "# Check the standard deviation of each 100 iterations is less than a maximum allowed value ("_maxStdev_").",!
	write "# This will ensure that all iterations complete within a sufficiently similar time period.",!
	if stdev>maxStdev do
	. write "FAIL: Standard deviation for each 100 iterations ["_stdev_" seconds] was greater than the max standard deviation allowed ["_maxStdev_" seconds]",!
	else  do
	. write "PASS: All iterations completed within an acceptable time period.",!
	quit
