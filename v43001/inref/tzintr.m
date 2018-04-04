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
tzintr	;
	; Routine to test job interrupt functionality and its interaction with $ZTRAP
	;
	; The following definitions govern the number of inner and outer loop iterations
	; and thus how long the test runs.
	set maxi=2000
	set maxj=500
	;
	; we want our interrupt line to cause a ztrap every zintr interrupts
	set zintrini=4
	;
	set i=0,j=0 ; incase get into a ztrap early
	set zintr=zintrini
	set unix=$ZVersion'["VMS"

	set ztcnt=0
	set $Ztrap="d ztrprtn^tzintr"
	;
	; This $ZINTERRUPT handler tracks how many times and where it got invoked, increments local
	; and global variables (which are checked later to make sure they are in step), resets $test
	; and the naked indicator and every zintr iterations causes a divide by zero exception that
	; we handle and recover from.
	set $Zint="set b=b+1 set d(b)=i_""_""_j_""_""_lasti_""_""_lastj set b(i)=$get(b(i))+1 set b(j)=$get(b(j))+1 if 1=1 set ^(0)=^b(0)+$ZINI+$test set xx=100/zintr set zintr=zintr-1 set c=c+1"

	kill ^a,^b,^cnt,a,b,c,d
	set ztidxlst=""
	set ^done=0
	set ^drvactive=0
	set b=0,c=0
	set ^cnt=0
	set ^b(0)=0

	; We have an external job to be our processus interruptus
	write "Spawning interrupter job",!
	if unix job @("intrdrv^tzintr($j,unix):(output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	else    job @("intrdrv^tzintr($j,unix):(nodetached:startup=""startup.com"":output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	write "waiting for job to set ^drvactive",!
	for wait=1:1:360 quit:^drvactive=1  hang 1
	if '(wait<360) write "waiting for job to set ^drvactive timed out",!
	set ^drvactive=2 ; let the child know that we are ready
	write !,"Beginning database transactions",!

	set lasti=0,lastj=0
	set ^a(0)=0	; set the naked reference
	if 1=3		; $test to 0
	;
	;   This loop (and the interrupts that occur during it) do(es) the following checks:
	;   1) That the job loop does not get restarted in the handling of a ztrap within a $zint string
	;   2) That the naked indicator is preserved by $zinterrupt
	;   3) That the $test value is preserved by $zinterrupt
	;   4) That $ZINI is always 0 while not in interrupt
	;   5) That $ZINI is always 1 while in interrupt
	;   6) That $ZTRAP works when driven from an interrupt handler
	;
	for i=1:1:maxi do
	. for j=1:1:maxj do
	. . if (j'>lastj)&(i=lasti) write "repeating index j",! set ^done=1 zshow "*" halt
	. . set ^(0)=^(0)+1+$test
	. . set a(j)=$get(a(j))+1+$ZINI
	. . set ^(j)=$get(^(j))+1+$ZINI
	. . set lastj=j,lasti=i


	write "Exiting interrupt stage -- waiting for interrupter to shutdown",!

	set ^done=1
	write "waiting for job to unset ^drvactive",!
	for wait=1:1:360 quit:^drvactive=0  hang 1
	if '(wait<360) write "waiting for job to unset ^drvactive timed out",!

	write !,"Shutdown complete",!
	write !,"Stats: ",!,^a(0)," transactions were done",!,^cnt," interrupts were sent",!
	write b," interrupt handlers were started or restarted",!,ztcnt," interrupts generated ztraps that were handled",!
	write c," interrupts ran to completion",!!

	write "Entering validation phase",!
	set err=0
	if ^a(0)'=(maxi*maxj) do
	. write "Transaction tally is incorrect. Should be ",maxi*maxj," but is ",^a(0),! set err=err+1
	. set sum=0
	. for k=1:1:maxj set sum=sum+^a(k)
	. if sum=^a(0) write "However ^a(0) does agree with the aggregate sum of the transaction array itself",!
	. else  write ".. and ^a(0) does not agree with the aggregate sum of the transaction array: ",sum,! set err=err+1

	set sum=0
	for k=1:1:($select(maxj>maxi:maxj,1:maxi)) set sum=sum+$get(b(k))
	if (b*2)'=sum write "The interrupt*2 count (",b*2,") is not the same as the sum'd interrupt vecotr: ",sum,! set err=err+1
	else  write "The interrupt count and summed interrupt count array are in agreement",!

	for k=1:1:maxj do
	. if ^a(k)'=maxi write "Individual trans count for ^a(",k,") is wrong at ",^a(k),". Should be ",maxi,! set err=err+1
	. if a(k)'=maxi write "Individual trans count for a(",k,") is wrong at ",a(k),". Should be ",maxi,! set err=err+1

	if $get(^a(maxj+1))'="" write "too many ^a elements exist. Found ^a(",maxj+1,")",! set err=err+1

	if (b*2)'=^b(0) write "interrupt tally is not correct. b=",b," ^b(0)=",^b(0),". b*2 should be same as ^b(0)",! set err=err+1

	if err=0 do
	. write "Test Passed",!
	else  do
	. write "Test Failed",!
	. zshow "*"
	quit

intrdrv(pid,unix)
	;
	; if we are doing a unix test, then we can use mupip intrpt to do the interruptions but
	; if we are on VMS, that is not an option because the ZSYSTEM we would use to invoke
	; mupip tries to do IO to the same .mjo file that this process is sending it to and can't
	; and thus creates a new .mjo file for each ZSYSTEM command and contains only the error message
	; that the file is in use by another process. Because of this, we use the $ZSIGPROC function to
	; send the interrupt. Note that with this function you can send any signal but that the signal
	; we are interested in (SIGUSR1) has different values on different platforms. On VMS, it is 16.
	set $ZTRAP="set $ZT="""" set ^drvactive=0 zshow ""*"" halt"
	; let the parent know that we are ready
	set ^drvactive=1
	; wait for the parent to be ready
	for wait=1:1:360 quit:^drvactive=2  hang 1
	if '(wait<360) write "waiting for parent to set ^drvactive=2 timed out",!
	write "Interrupt job beginning for process ",pid,!
	if unix set cmd="$gtm_dist/mupip intr "_pid

	; Interrupt until we are requested to shutdown or we reach an outer limit of 100,000 interrupts
	; which probably means we were orphaned and are just chewing up cpu time.
	for x=1:1:100000 quit:(^done=1)  do
	. if unix do
	. . ZSystem cmd
	. . if $zsystem'=0 set ^done=1 quit
	. else  do
	. . if $ZSigproc(pid,16) set ^done=1 quit
	. set ^cnt=^cnt+1
	. do slowdown
	set ^drvactive=0
	write "Interrupt job ",pid," complete",!
	quit

slowdown quit:unix
	; Spin some cycles so we don't bomb the process so hard it can't get anything done.
	; don't need to do this on Unix. Normal process create takes enough time to
	; keep us from saturating the target.
	for y=1:1:1200 set wastetime(y)=$justify(y,10)
	quit

ztrprtn new $ZT set $ZTRAP="set $ZT="""" set ^drvactive=0 zshow ""*"" halt"
	; Record various info, reset (repair) zintr count. When we go back, the entire $zint
	; handler will be rerun from the beginning because that's what $ZTRAP does.. restart the
	; line that was executing when it got broke.
	set ztcnt=ztcnt+1
	set ztidxlst(ztcnt)=i_","_j
	if ($piece($zs,",",5)="-YDB-E-DIVZERO")&($zini=1) set zintr=zintrini quit  ; return back to $zinterrut
	;
	; Either the ztrap was not a divide by zero we expect or we weren't in an interrupt
	; which we also did not expect
	set $ZT=""
	set ^done=1
	zshow "*"
	halt
