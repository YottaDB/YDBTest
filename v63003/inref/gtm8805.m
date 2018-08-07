;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8805
	;^A global nodes used to dictate order in which jobs execute, ^B global nodes used as an event log
	set ^a(1)=1,^a(2)=0,^a(3)=0,^a(4)=0,^a(5)=0,^B($increment(^b))="# Sequence of Events in Subtest"
	do ^job("child^gtm8805",3,"""""")
	zwrite ^B
	quit

child

	for  quit:^a(jobindex)  hang 0.1
	; Lock ^x, await a signal to trigger an ungraceful shutdown
	if jobindex=1 do
	. lock +^x
	. set:($test) ^B($increment(^b))="# Process 1: Currently holds ^x"
	. set ^a(2)=1
	. for  quit:^a(4)  hang 0.1
	. set ^B($increment(^b))="# Process 1: Issuing a kill -9"
	. zsystem "kill -9 "_$j


	; Seizing Critical Resources
	if jobindex=2 do
	. set p="process2"
	. open p:(command="$ydb_dist/dse")::"PIPE"
	. use p
	. write "find -region=DEFAULT",!
	. write "crit -seize",!
	. for  read x($incr(x))  quit:(x(x)["Seized")  hang 0.1
	. set ^B($increment(^b))="# Process 2: "_x(x)
	. set ^a(3)=1

	; Attempting to seize ^x (should fail until job 1 is shutdown)
	if jobindex=3 do
	. set ^B($increment(^b))="# Process 3: Attempting to get ^x:1. Should time out"
	. lock ^x:1
	. if $test  set ^B($increment(^b))="# Process 3: Lock inapporpriately seized"
	. else  set ^B($increment(^b))="# Process 3: Lock ^x:1 timed out as expected"
	. for  lock ^x:1  quit:$test  set ^a(4)=1
	. set ^B($increment(^b))="# Process 3: Lock successfully acquired by Process 3 after ungraceful shutdown of process 1"
	. set ^a(5)=1

	for  quit:^a(5)  hang 0.1

	quit
