;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
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
	if ^cmdline="NOISOLATION" view "NOISOLATION":"^x"
	for i=1:1:^max do
	. if i#2'=0 set ^x(jobindex)=$get(^x(jobindex))_"abcdefgh"
	. else      do
	. . if $incr(^x(jobindex))
	. . tstart ():(serial:transaction="BATCH")	; use BATCH to avoid test slowdown due to jnl hardening for every TCOMMIT
	. . if $incr(^x)
	. . tcommit
	quit
