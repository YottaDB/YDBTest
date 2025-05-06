;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
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
	set longest=0,shortest=10
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
	. . set elapsed=(curr-prev)/(10**6)
	. . set:elapsed<shortest shortest=elapsed
	. . set:elapsed>longest longest=elapsed
	. . write "Iteration = ",$justify(cnt,4)," : Elapsed time = ",$fnumber(elapsed,"",2),!
	. . set prev=curr
	write "# Check that the longest running iteration takes no more than twice as long as the shortest running iteration to complete.",!
	write "# This will ensure that all iterations complete within a sufficiently similar time period.",!
	if longest>(shortest*2) do
	. write "FAIL: Longest iteration time ["_longest_" seconds] was greater than twice the shortest iteration time ["_shortest_" seconds]",!
	else  do
	. write "PASS: All iterations completed within an acceptable time period.",!
	quit
