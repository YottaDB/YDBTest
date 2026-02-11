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

ydb1178	;
	quit

startbg	;
	set ^stop=0
	set jmaxwait=0
	do ^job("updates^ydb1178",1,"""""")
	; Wait for statsdb to be opened for regions AREG, BREG, and DEFAULT before DSE -DUMP is run by the calling script
	; See https://gitlab.com/YottaDB/DB/YDBTest/-/issues/893#note_3070059015 for more details.
	for i=1:1  quit:$data(^c(1))'=0  hang 0.01
	quit

stopbg	;
	set ^stop=1
	do wait^job
	quit

updates	;
	; Update all 3 regions AREG (^a), BREG (^b) and DEFAULT (^c)
	for i=1:1 quit:^stop=1  set ^a(i)=$j(i,20),^b(i)=$j(i,20),^c(i)=$j(i,20) hang $random(10)*0.001
	quit

getMutexType;
	set reg="" for  set reg=$view("GVNEXT",reg)  quit:reg=""  do
	. set mutextype=$$^%PEEKBYNAME("mutex_struct.curr_mutex_type",reg)
	. write "Mutex Manager Type for region [",reg,"] = ",$select(mutextype=0:"ADAPTIVE",mutextype=2:"YDB",1:"PTHREAD"),!
	if $ztrnlnm("gtm_statshare") set reg="" for  set reg=$view("GVNEXT",reg)  quit:reg=""  do
	. set statsdbreg=$$FUNC^%LCASE(reg)
	. set mutextype=$$^%PEEKBYNAME("mutex_struct.curr_mutex_type",statsdbreg)
	. write "Mutex Manager Type for region [",statsdbreg,"] = ",$select(mutextype=0:"ADAPTIVE",mutextype=2:"YDB",1:"PTHREAD"),!
	quit

