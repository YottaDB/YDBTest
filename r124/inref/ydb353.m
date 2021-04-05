;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb353	;
	kill ^x
	set ^cmdline=$zcmdline,^max=10000,^njobs=5
	do ^job("child^ydb353",^njobs,"""""")
	zwr ^x
	if ^cmdline'="NOISOLATION" do
	. if ^x=((^max*^njobs)/2) write ^cmdline," : PASS : ^x is equal to (^max*^njobs)/2 as expected",!
	. else                    write ^cmdline," : FAIL : ^x is NOT equal to (^max*^njobs)/2",!
	else  do
	. if ^x=((^max*^njobs)/2) write ^cmdline," : FAIL : ^x is equal to (^max*^njobs)/2",!
	. else                    write ^cmdline," : PASS : ^x is NOT equal to (^max*^njobs)/2 as expected",!
	quit

child	;
	new i,istp,postincr,incr2args,actual,expect
	if ^cmdline="NOISOLATION" view "NOISOLATION":"^x"
	for i=1:1:^max do
	. if i#2'=0 do
	. . set actual=$get(^x(jobindex)),expect=$select(i=1:"",1:(i-1)/2)
	. . if (actual'=expect) write "TEST-E-FAIL : $get(^x(",jobindex,")) : Actual = ",$zwrite(actual)," : Expected = ",$zwrite(expect),! zshow "*" halt
	. . set ^x(jobindex)=actual_"abcdefgh"
	. else      do
	. . ; Test that $INCREMENT works inside and outside of TP hence the $random call below
	. . set istp=$random(2)
	. . tstart:istp ():(serial:transaction="BATCH")
	. . ; Test $INCREMENT with 1 argument and 2 arguments. Both produce same result hence the $random call below.
	. . set incr2args=$random(2)
	. . set postincr=$select(0=incr2args:$increment(^x(jobindex)),1:$increment(^x(jobindex),1))
	. . tcommit:istp
	. . if (postincr'=(i/2)) write "TEST-E-FAIL : $increment(^x(",jobindex,")) : Actual = ",$zwrite(postincr)," : Expected = ",i/2,! zshow "*" halt
	. . tstart ():(serial:transaction="BATCH")	; use BATCH to avoid test slowdown due to jnl hardening for every TCOMMIT
	. . set postincr=$increment(^x)
	. . tcommit
	. . ; Validate that $INCREMENT(^x) is always a number even if ^x is concurrently updated by multiple processes
	. . ; even though it has NOISOLATION turned ON (it was seen to be the empty string before the YDB#711 fixes).
	. . if (postincr'=+postincr) write "TEST-E-FAIL : $increment(^x) : Actual = ",$zwrite(postincr)," : Expected = Integer",! zshow "*" halt
	quit
