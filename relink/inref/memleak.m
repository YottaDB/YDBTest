;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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

; A collection of functions collectively exercising scenarios that could potentially lead to memory leak.

; Start a number of jobs, of which all but one randomly link zero or more routines (out of the same number
; of routines available as there are processes trying to link them). Once all linking jobs are done, allow
; the last remaining job to continue and link a special routine, whose object is big enough to cause the
; rtnobj shared memory expansion *if* any of the routines linked by the now-gone processes were not wiped.
; Just before termination the last job saves the output of a MUPIP RCTLDUMP for further verification.
memleak
	new i,jobCount,allStarted,jobPid,jobPids,holderPid,jobDone

	set jobCount=+$zcmdline
	set ^startCount=0
	lock +^jobExitLock
	lock +^finalZlink

	job holder^memleak(jobCount) set holderPid=$zjob
	for i=1:1:jobCount job job^memleak(jobCount) set jobPids($zjob)=1

	set allStarted=0
	for i=1:1:600 set:((jobCount+1)=^startCount) allStarted=1 quit:allStarted  hang 0.5
	if ('allStarted) write "TEST-E-FAIL, "_(jobCount+1)_" processes failed to start in 300 seconds.",! zhalt 1

	lock -^jobExitLock

	set jobPid=""
	for  set jobPid=$order(jobPids(jobPid)) quit:(""=jobPid)  do
	.	set jobDone=0
	.	for i=1:1:120 set jobDone=$zsigproc(jobPid,0) quit:jobDone  hang 0.5
	.	if ('jobDone) write "TEST-E-FAIL, Job "_jobPid_" (of "_jobCount_" total processes) failed to terminate in 60 seconds.",! zhalt 1

	lock -^finalZlink
	lock +^finalZlinkDone:300
	if ('$test) write "TEST-E-FAIL, Job "_holderPid_" (the final process) failed to terminated in 300 seconds.",! zhalt 1

	quit

job(jobCount)
	new i
	for i=1:1:jobCount zlink:($random(2)) "rtn"_i
	if $increment(^startCount)
	lock +^jobExitLock
	quit

holder(jobCount)
	lock +^finalZlinkDone
	if $increment(^startCount)
	lock +^finalZlink
	zlink "rtn"_(jobCount+1)
	zsystem "$MUPIP rctldump . >&! mupip_rctl3.log"
	quit

; Do a series of relinks of a changing routine (relinks are on the source so causing compilations). Take a
; ZSHOW "A" dump in the end for further verification that no rtnobj shared memory was wasted.
relinks
	set file="rtn.m"
	for i=1:1:100 do
	.	open file:newversion
	.	use file
	.	write "rtn",!
	.	for j=1:1:32 do
	.	.	write " ;"_$justify(i,1000),!
	.	write " quit"
	.	close file
	.	zlink "rtn.m"
	.	hang 0.01
	set file="zshow_a.logx"
	open file:newversion
	use file
	zshow "A"
	close file
	quit

; Do 10 ZRUPDATEs of a constantly recompiled (i.e., changing) object file for priming and make sure the memory
; usage does not go up after 100 more.
zrupdates
	set rtnString="rtn"
	set quitString=" quit "
	set file="rtn.m"
	set object="rtn.o"
	set (alloc1,alloc2)=$zusedstor
	for i=1:1:10 do
	.	open file:newversion
	.	use file
	.	write rtnString,!
	.	write quitString,i
	.	close file
	.	zcompile file
	.	zrupdate object
	view "STP_GCOL"
	set alloc1=$zusedstor
	for i=1:1:100 do
	.	open file:newversion
	.	use file
	.	write rtnString,!
	.	write quitString,i
	.	close file
	.	zcompile file
	.	zrupdate object
	view "STP_GCOL"
	set alloc2=$zusedstor
	if (alloc2>alloc1) write "TEST-E-FAIL, Case 5 failed. Process-private memory usage went up from "_alloc1_" after 10 ZRUPDATEs to "_alloc2_" after 100.",!
	quit

; Recursively link 50 versions of the same routine on the stack, making sure that more than 50% of the memory allocated
; at the time the stack reached its maximum has been freed by the time we unwound all the way to the base frame.
recursive
	view "link":"recursive"
	set (alloc1,alloc2,alloc3)=$zusedstor
	set alloc1=$zusedstor
	do recurse(0)
	set alloc3=$zusedstor
	set allocated=alloc2-alloc1
	set freed=alloc2-alloc3
	if (freed/allocated<0.5) do
	.	set ratio=freed*100\allocated
	.	write "TEST-E-FAIL, Case 6 failed. Process-private memory usage went up from "_alloc1_" to "_alloc2_" (at maximum stack) to "_alloc3_" when fully unwound.",!
	.	write "             That means that only "_ratio_" % of memory allocated was freed."
	quit

recurse(index)
	if (index<50) do
	.	do grow(index)
	.	zlink "memleak.m"
	.	do recurse^memleak(index+1)
	else  set alloc2=$zusedstor
	quit

grow(index)
	new file
	set file="memleak.m"
	open file:append
	use file
	write "label"_index,!
	write " quit",!
	close file
	quit

; Create a relinkctl file by setting $zroutines appropriately. Then make that file inaccessible and have another
; process attempt to open it; ensure that it does not leak memory doing so.
ctlopen
	set $zroutines=".*"
	zshow "A":zshow
	set ctlfile=$piece(zshow("A",2),": ",2)
	if $&ydbposix.chmod(ctlfile,0,.errno)
	zsystem "$gtm_dist/mumps -run ctlopensub^memleak"
	quit

ctlopensub
	; Allocate memory for both alloc1 and alloc2, so that we would not need more memory later.
	set (alloc1,alloc2)=$zusedstor
	for i=1:1:10 do
	.	new $etrap
	.	set $etrap="set $ecode="""""
	.	set $zroutines=".*"
	set alloc1=$zusedstor
	for i=1:1:10 do
	.	new $etrap
	.	set $etrap="set $ecode="""""
	.	set $zroutines=".*"
	set alloc2=$zusedstor
	do:(alloc2>alloc1)
	.	write "TEST-E-FAIL, GT.M process leaked memory on errors while trying to open the relinkctl file:",!
	.	zwrite alloc1,alloc2
	quit
