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
;
;
; Script to do some database filling by multiple processes and show statistic changes
;
gtm8863b
	view "STATSHARE"	; Enable global stat sharing
	set $etrap="set ^shutdown=1 write $zstatus,!!! zshow ""*"""
	set maxKids=12		; Max worker bee children
	set maxTime=15		; Max time (in seconds) for test
	set interval=3		; Monitor interval
	set ^shutdown=0		; Initialize
	kill ^a
	set ^a(1)=1
	set collectStats="AFRA,BREA,DEXA,GLB,JNL,JOPA,MLBA,MLK,PRC,TRGA,TRX,ZAD"	; Toggle stats to collect
	;
	; The following set of stats are those that we typically see being non-zero. This set of stats are those
	; which we verify had at least one non-zero stat during the run. These are the "monitored" stats.
	;
	; Note - Initially we were also monitoring TRX and TRGA, which also often appear as non-zero values, but
	;        we were not able to depend on this as doing so caused failures about 6% of the time when one or
	;	 both of these values were zero in each line of the test so they were removed from monitor list.
	;
	set nonZeroStats="MLK,MLBA"		; Stats to be "monitored"
	write !,"Monitored stats for test: ",nonZeroStats,!!
	;
	; First order of business is to spawn some worker bees
	;
	write $zdate($horolog,"24:60:SS")," Starting ",maxKids," workers",!
	set jmaxwait=0		; Want to return immediately from ^job() so we can run checks while the jobs run
	do ^job("workerBee^gtm8863b",maxKids,"""""")
	;
	; Now that the children are playing, lets start watching some stats. Look at each stat line generated.
	; At the end of the day, we need at least one non-zero stat for SOME toggle value and that value needs
	; to be less than or equal to the number of workerBee jobs created.
	;
	set seenTooHighValue=0
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
	. set stats=$zextract(statLine,12,99)	; Isolate stat line from prefix
	. for i=1:1:$zlength(collectStats,",") do
	. . set stat=$zpiece(stats,",",i)	; Look at individual stat
	. . set statName=$zpiece(stat,":",1)	; Get the stat name
	. . set statVal=$zpiece(stat,":",2)	; Get the individual stat value
	. . if statVal>maxKids do
	. . . write "FAILURE - Value for stat ",statName," (",statVal,") exceeds the maximum value of ",maxKids,!
	. . . set seenTooHighValue=1
	. . if (statVal>0)&$increment(nonZeroStat(statName))	; Bump non-zero counter for this stat if non-zero
	;
	; Shutdown the workers
	;
	write $zdate($horolog,"24:60:SS")," Shutting down now",!
	set ^shutdown=1
	do wait^job				; Wait for workers to exit
	;
	; Print final failure/success message (see if all our monitored stats had a non-zero event)
	;
	set seenAllNonZeroStats=1
	for i=1:1:$zlength(nonZeroStats,",") do	; Check all stats so we mention any that were always zero
	. set stat=$zpiece(nonZeroStats,",",i)
	. if 0=$get(nonZeroStat(stat),0) do
	. . set seenAllNonZeroStats=0
	. . write "FAILURE - Monitored stat '",stat,"' was zero in all records",!
	;
	write !
	if 'seenAllNonZeroStats write "FAILURE - At least one monitored toggle statistic value had no non-zero values",!
	else  if seenTooHighValue write "FAILURE - Too high value detected",!
	else  write "SUCCESS - Saw at least one non-zero value for each monitored toggle stat and no too-high values for ANY stats above",!
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
	. tstart ():(serial:transaction="BATCH")	; Use batch transactions for better throughput to see non-zero stats
	. for j=1:1:25 set ^a(tr,$job,j)=$justify(j,10)
	. tcommit
	write $zdate($horolog,"24:60:SS")," Worker/laborer #",jobindex," shutting down",!!
	zshow "G"
	quit

