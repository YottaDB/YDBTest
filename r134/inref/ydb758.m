;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start
	; Starts 10 concurrent jobs
	set jmaxwait=0
	set ^child=0
	set ^stop=0
	do ^job("child^ydb758",10,"""""")
	; Wait for all child jobs to start and access the database
	for  quit:^child=10  hang 0.001
	; Now that all child jobs have started and accessed the database, signal them to stop
	set ^stop=1
	do wait^job
	quit

child	;
	if $increment(^child) do
	. ; The loop below hangs for up to 500 seconds to ensure all 10 processes have started.
	. for i=1:1:5000 hang 0.1 quit:^stop
	quit
