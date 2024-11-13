;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This test verifies that $$IN^%YGBLSTAT returns a value of TRUE(1) or FALSE(0)
; to confirm if there is sharing or not in the region and returns an empty string if
; the pid is invalid or there is no sharing for the a specified region.
gtm9092
	; Test for $$IN^%YGBLSTAT() by spawning two child processes, one of
	; which shares statistics and the other does not.
	new childpid,i,tmp
	lock +done
	for i=1:-1:0 do
	. job child(i):(input="/dev/null":output="/dev/null":error="/dev/null")
	. if $zjob set childpid(i)=$zjob
	. else  set $ecode=",U255,"
	; wait for child process to have gone past the "view statshare"
	for i=0:1:1 for  quit:$data(^started(childpid(i)))  hang 0.01
	set childpid(2)=1
	write "Testing with empty region parameter",!
	write "Verifying that a process with sharing statistics returns TRUE",!
	write $$IN^%YGBLSTAT(childpid(1)),!
	write "Verifying that a process with no sharing statistics returns FALSE",!
	write $$IN^%YGBLSTAT(childpid(2)),!
	write "Verifying that an empty string is returned from an invalid pid",!
	write $$IN^%YGBLSTAT("temp.pid","",""),!

	write "Testing YGBLSTAT in a different region",!
        for i=-1:-1:-2 do
        . job child2(i):(input="/dev/null":output="/dev/null":error="/dev/null")
        . if $zjob set childpid(i)=$zjob
        . else  set $ecode=",U255,"
	; wait for child process to have gone past the "view statshare"
	for i=-1:-1:-2 for  quit:$data(^started(childpid(i)))  hang 0.01
        set childpid(2)=1
        write "Verifying that a process with sharing statistics returns TRUE",!
        write $$IN^%YGBLSTAT(childpid(1)),!
        write "Verifying that a process with no sharing statistics returns FALSE",!
        write $$IN^%YGBLSTAT(childpid(2)),!

	write "Testing YGBLSTAT with different region parameters",!
	write "Using * for region parameter with a process using sharing statistics",!
	write $$IN^%YGBLSTAT(childpid(1),"","*"),!
	write "Using random region name with a process using sharing statistics",!
	write $$IN^%YGBLSTAT(childpid(1),"","a"),!
	lock -done
	for i=1:-1:-2 do ^waitforproctodie(childpid(i))
	quit


child(shrflag)
	; child process that shares statistics if shrflag is 1
	view:shrflag "statshare"
	set ^started($job)=1
	for  set ^x($job,$zut)=$random(2**32-1) hang .001 lock +done($job) quit:$test
	lock -done($job)
	quit
child2(shrflag)
        view:shrflag "statshare"
	set ^started($job)=1
        for  set ^a($job,$zut)=$random(2**32-1) hang .001 lock +done($job) quit:$test
        lock -done($job)
        quit

