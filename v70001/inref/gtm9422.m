;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
; Script to do some database filling by multiple processes and show statistic changes
;
gtm9422
	view "STATSHARE"	; Enable global stat sharing
	set $etrap="set ^shutdown=1 write $zstatus,!!! zshow ""*"""
	set maxKids=12		; Max worker bee children
	set maxTime=20		; Max time (in seconds) for test
	set interval=4		; Monitor interval
	set ^shutdown=0		; Initialize
	kill ^a
	set ^a(1)=1
	;
	; The following is the set of stats that were added in V63014 as "toggle stats" but in V70001, they
	; became regular counter stats.
	;
	set collectStats="DEXA,GLB,JNL,MLK,PRC,TRX,ZAD,JOPA,AFRA,BREA,MLBA,TRGA"
	set collectStatsCnt=$zlength(collectStats,",")
	;
	; The following set of stats are those that we typically see being non-zero. This set of stats are those
	; which we verify had at least one non-zero stat during the run. These are the "monitored" stats.
	;
	; Note - The following stats are those that this test is capable of getting non-zero values out of
	;	 over the 20 second run time of the test. The following stats did not reliably have a non-zero
	;	 value: "PRC,ZAD"
	;
	set statIncrementeds="DEXA,GLB,JNL,MLK,TRX,JOPA,AFRA,BREA,MLBA,TRGA"	; Stats to be "monitored"
	write !,"# Unmonitored stats: PRC,ZAD (to be added in a future commit)",!
	write !,"# Monitored stats for test: ",statIncrementeds,!!
	;
	; Initialize "previous" stat values for each of the stats we see with the current value
	;
	for i=1:1:collectStatsCnt do
	. set stat=$zpiece(collectStats,",",i)
	. set statName=$zpiece(stat,":",1)
	. set statPrevVal(statName)=$zpiece(stat,":",2)
	;
	; First order of business is to spawn some worker bees
	;
	write $zdate($horolog,"24:60:SS")," Starting ",maxKids," workers",!
	set jmaxwait=0		; Want to return immediately from ^job() so we can run checks while the jobs run
	do ^job("workerBee^gtm9422",maxKids,"""""")
	;
	; Now that the children are playing, lets start watching some stats. Look at each stat line generated.
	; At the end of the day, we need at least one non-zero stat for SOME toggle value.
	;
	write $zdate($horolog,"24:60:SS")," Statistics @ ",interval," second intervals for ",maxTime," seconds",!
	for time=0:interval:maxTime hang interval do
	. write "%YGBLSTAT: "
	. set start=$zut
	. set statLine=$$STAT^%YGBLSTAT("*",collectStats)
	. set end=$zut				; Compute ^%YGBLSTAT() execution time - no test purpose - just interesting
	. write statLine,"  (compute time ",(end-start)/(1000)," milliseconds)",!
	. ;
	. ; Now parse the stat line we got and check each value for both <= to number of processes and that
	. ; we saw the required non-zero stat value.
	. ;
	. for i=1:1:$zlength(collectStats,",") do
	. . set stat=$zpiece(statLine,",",i)	; Look at individual stat
	. . set statName=$zpiece(stat,":",1)	; Get the stat name
	. . set statVal=$zpiece(stat,":",2)	; Get the individual stat value
	. . if (statVal>statPrevVal(statName)) do
	. . . if $increment(statIncremented(statName))	; Bump non-zero counter for this stat if non-zero
	. . . set statPrevVal(statName)=statVal
	;
	; Shutdown the workers
	;
	write $zdate($horolog,"24:60:SS")," Shutting down now",!
	set ^shutdown=1
	do wait^job				; Wait for workers to exit
	;
	; Print final failure/success message (see if all our monitored stats had a non-zero event)
	;
	set seenIncrementedStats=1
	for i=1:1:$zlength(statIncrementeds,",") do	 ; Check all stats so we mention any that were always zero
	. set stat=$zpiece(statIncrementeds,",",i)
	. if 0=$get(statIncremented(stat),0) do
	. . set seenIncrementedStats=0
	. . write "FAILURE - Monitored stat '",stat,"' was zero in all records",!
	;
	write !
	if 'seenIncrementedStats write "FAILURE - At least one monitored count statistic value had no incremented value",!
	else  write "SUCCESS - Saw at least one increment for each monitored counter stat above",!
	write !,$zdate($horolog,"24:60:SS")," Complete",!
	quit

;
; Routine run by each child/worker-bee to do various operations (M Locks, DB updates both singular and inside a
; transaction) that stand a good chance of causing some non-zero toggle statistic values.
;
workerBee
	view "STATSHARE"			; Enable global stat sharing
	write $zdate($horolog,"24:60:SS")," Worker/laborer #",jobindex," reporting for duty",!
	set $etrap="zwrite $zstatus zshow ""*"" zhalt 1"
	for tr=1:1 quit:^shutdown  do
	. set ^a(tr,$job)=jobindex
	. lock ^a(1)
	. set ^a(1)=^a(1)+1
	. lock
	. ;
	. ; The merge done below (with ^a as the RHS) is needed to induce non-zero value of BREA (which the test expects).
	. ; It will cause a disk read of all blocks of ^a and with the minimum global buffers (64) set in the caller script
	. ; dbcreate.csh call, this should cause reads of ^a from disk since ^a will over the course of this test occupy
	. ; 4x or 5x times the number of blocks than the 64 global buffers can hold.
	. kill twin merge twin=^a
	. ;
	. tstart ():(serial:transaction="BATCH")	; Use batch transactions for better throughput to see non-zero stats
	. for j=1:1:25 set ^a(tr,$job,j)=$justify(j,10)
	. tcommit
	. view "FLUSH"				; Cause JOPA stats to increment
	write $zdate($horolog,"24:60:SS")," Worker/laborer #",jobindex," shutting down",!!
	zshow "G"
	quit

