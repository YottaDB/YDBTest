;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb775	;
	quit

singleproc	;
        ; --------------------------------------------------------------------------------------------------------------
        ; Check that LOCKs obtained inside of TP are released properly as part of a TP restart using single process
        ; --------------------------------------------------------------------------------------------------------------
	write "# Acquire lock on ^a when $TLEVEL is 0",!
	lock ^a
	write "# Do ZSHOW ""L"" to verify that the only lock we hold is on ^a LEVEL=1",!
	zshow "L"
	write "# Start outer TP transaction : $TLEVEL = 1",!
	tstart ()
	if $trestart do
	. write "# Do ZSHOW ""L"" after TRESTART to verify that the only lock we hold is on ^a LEVEL=1",!
	. zshow "L"
	write "# Acquire lock on ^b when $TLEVEL is 1",!
	lock +^b
	write "# Start inner TP transaction : $TLEVEL = 2",!
	tstart ()
	if $trestart=0 do
	. write "# Force a TRESTART",!
	. trestart
	write "# Do ZSHOW ""L"" to verify that the only locks we hold are on ^a LEVEL=1 and ^b LEVEL=1",!
	zshow "L"
	trollback
	quit

multiproc	;
        ; --------------------------------------------------------------------------------------------------------------
        ; Check that LOCKs obtained inside of TP are released properly as part of a TP restart using multiple processes
        ; --------------------------------------------------------------------------------------------------------------
        set ^stop=0
        set ^njobs=8
        set ^cntr=^njobs
        ; Start ^njobs child processes
        for i=1:1:^njobs do
        . set jobstr="job child^ydb775:(output=""child_ydb775.mjo"_i_""":error=""child_ydb775.mje"_i_""")"
        . xecute jobstr
        . set ^job(i)=$zjob
        ; Let child processes run for a max of 5 seconds. Stop before that if at least one process fails and sets ^stop=1
        for i=1:1:50  hang 0.1  quit:^stop=1
        ; Signal child processes to stop
        set ^stop=1
        ; Wait for child processes to terminate.
        for i=1:1:^njobs set pid=^job(i) for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.1
        ; Check if all child processes finished cleanly
        if ^cntr do
        . write "TEST-E-FAIL : multiproc test : ^cntr : Expected=0 : Actual=",^cntr,!
        . write "# cat child_ydb775.mjo* child_ydb775.mje* output follows",!
        . zsystem "cat child_ydb775.mjo* child_ydb775.mje*"
	else  write "PASS : multiproc test",!
        quit

child   ;
        for i=1:1  quit:^stop=1  do  hang 0.01
        . tstart ():serial
        . do lockcheck
        . lock +^x($job)	; get lock inside TSTART
        . tstart ():transactionid="batch"
        . set ^x=$j_i	; this is expected to induce a TP restart with multiple processes
        . tcommit
        . lock -^x($job)
        . tcommit
        ; Record that this child finished cleanly (i.e. did not "halt" in a prior "lockcheck" call).
        if $increment(^cntr,-1)
        quit

lockcheck       ;
        new zshl
        zshow "L":zshl
        if $data(zshl("L",1)) write "TEST-E-FAIL : Unexpected locks held after tstart/trestart",! do
        . write "# zshow L output follows",!
        . zshow "L"
        . write "# zwrite output follows",!
        . zwrite
        . trollback:$tlevel
        . ; Set ^stop=1 as part of failure to terminate test right away since we know at least one child failed
        . set ^stop=1
        . halt
        quit

