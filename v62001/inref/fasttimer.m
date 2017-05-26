;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper script for the fast_timer test. It issues a specified number of 1ms and 10ms HANGs and
; ensures that they result in appropriate sleep durations.
fasttimer
	new i,j,tvSec1,tvSec2,tvUsec1,tvUsec2,errNum,diff,fail1,fail2,fail
	new countOf1ms,countOf10ms,passFor1ms,passFor10ms

	set countOf1ms=$piece($zcmdline," ",1)
	set countOf10ms=$piece($zcmdline," ",2)
	set passFor1ms=$piece($zcmdline," ",3)
	set passFor10ms=$piece($zcmdline," ",4)

	set (fail,fail1,fail2)=0
	for i=1:1:10 do
	.	set start=$zut
	.	for j=1:1:countOf1ms hang 0.001
	.	set diff(i)=$zut-start\1000
	.	if (diff(i)>passFor1ms) set fail1=fail1+1 zsystem "ps -ef >& pslistfail1ms-"_fail1
	do:(fail1>3)
	.	write "TEST-E-FAIL, "_countOf1ms_" of 1ms HANGs took over "_passFor1ms_"usec at least three times:",!
	.	zwrite diff
	.	set fail=1
	for i=1:1:10 do
	.	set start=$zut
	.	for j=1:1:countOf10ms hang 0.01
	.	set diff(i)=$zut-start\1000
	.	if (diff(i)>passFor10ms) set fail2=fail2+1 zsystem "ps -ef >& pslistfail10ms-"_fail2
	do:(fail2>3)
	.	write "TEST-E-FAIL, "_countOf10ms_" of 10ms HANGs took over "_passFor10ms_"usec at least three times:",!
	.	zwrite diff
	.	set fail=1
	zhalt fail
	quit
