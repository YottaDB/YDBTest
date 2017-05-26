;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
d002636	;
	; Routine to test job interrupt functionality and its interaction with terminal I/O
	; Based on v43001/inref/tzintr.m for D9G12-002636
	;
	s ^drvactive=0,^cnt=0,^done=0
	Set unix=$ZVersion'["VMS"
	; Check that $PRINCIPAL is TERMINAL
	s priorio=$io u 0
	s $zinterrupt="zshow ""D"":zshowdev"
	Write "Spawning interrupter job to check zshow ""D"" zinterrupt",!
	If unix J @("intrdrv^d002636($j,unix,1):(output=""intrdrv1.mjo"":error=""intrdrv1.mje"")")
	Else    J @("intrdrv^d002636($j,unix,1):(nodetached:startup=""startup.com"":output=""intrdrv1.mjo"":error=""intrdrv1.mje"")")
	for i=1:1 Q:^drvactive  Hang 1
	read "wait 15 seconds for interrupt: ",throwaway
	for i=1:1 Q:^cnt>0  Hang 1
	hang 5
	if $d(zshowdev)=0 zshow "D":zshowdev zwrite zshowdev	;just in case
	s indx="" f  s indx=$o(zshowdev("D",indx)) q:indx=""  do
	. s dev=zshowdev("D",indx)
	. if $piece(dev," ",1)=$ZIO,$piece(dev," ",3)'="TERMINAL"
	. . W !,"FAIL $PRINCIPAL is not a TERMINAL",!
	. else  if $find(dev,"ZINTERRUPT")=0 w !,"FAIL no ZINTERRUPT in zshow ""D""",!
	;u priorio
	w !,"TERM = ",$ztrnlnm("TERM"),!
	; The following definitions govern the number of inner and outer loop iterations
	; and thus how long the test runs.
	s maxi=2000
	s maxj=500
	;
	; we want our interrupt line to cause a ztrap every zintr interrupts
	s zintrini=4
	;
	s i=0,j=0 ; incase get into a ztrap early
	s zintr=zintrini

	s ztcnt=0
	S $Ztrap="d ztrprtn^d002636"
	k ^a,^b,^cnt,a,b,c,d
	s ztidxlst=""
	s ^done=0
	s ^drvactive=0
	s b=0,c=0
	s ^cnt=0
	s ^b(0)=0
	s lasti=0,lastj=0
	s ^a(0)=0
	;
	; This $ZINTERRUPT handler tracks how many times and where it got invoked, increments local
	; and global variables (which are checked later to make sure they are in step), resets $TEST
	; and the naked indicator and every zintr iterations causes a divide by zero exception that
	; we handle and recover from.
	set $zinterrupt="set b=b+1,d(b)=i_""_""_j_""_""_lasti_""_""_lastj,b(i)=$get(b(i))+1,b(j)=$get(b(j))+1"
	set $zinterrupt=$zinterrupt_" if 1=1 set ^(0)=^b(0)+$ZINI+$T,xx=100/zintr,zintr=zintr-1,c=c+1"

	; We have an external job to be our processus interruptus
	Write "Spawning interrupter job",!
	If unix J @("intrdrv^d002636($j,unix,100000):(output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	Else    J @("intrdrv^d002636($j,unix,100000):(nodetached:startup=""startup.com"":output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	if 1=3		; $T to 0
	w "."
	for i=1:1 Q:^drvactive=1  if ^a(0)'=^a(0)  W "."  Hang 1	; $T to 0, $REFERENCE to "^a"
	if ^a(0)'=^a(0)							; $T to 0, $REFERENCE to "^a"
	Write !,"Beginning database transactions",!

	;
	;   This loop (and the interrupts that occur during it) do(es) the following checks:
	;   1) That the j loop does not get restarted in the handling of a ztrap within a $zint string
	;   2) That the naked indicator is preserved by $zinterrupt
	;   3) That the $T value is preserved by $zinterrupt
	;   4) That $ZINI is always 0 while not in interrupt
	;   5) That $ZINI is always 1 while in interrupt
	;   6) That $ZTRAP works when driven from an interrupt handler
	;
	for i=1:1:maxi do
	. for j=1:1:maxj do
	. . if (j'>lastj)&(i=lasti) W "repeating index j",! S ^done=1 ZSHOW "*" Halt
	. . s ^(0)=^(0)+1+$T
	. . s a(j)=$get(a(j))+1+$ZINI
	. . s ^(j)=$get(^(j))+1+$ZINI
	. . s lastj=j,lasti=i

	s ^alphabetcnt(0)=^cnt,^alphabettime(0)=$H
	r !,"enter the alphabet: ",alphabet
	s ^alphabetcnt(1)=^cnt,^alphabettime(1)=$H
	if ^alphabetcnt(1)'>^alphabetcnt(0) w !,"FAIL no interrupts entering the ALPHABET",!
	else  w !,"PASS tt read was interrupted",!
	if $get(^showcounts) w !,"interrupts during terminal input = ",^alphabetcnt(1)-^alphabetcnt(0),!
	w !
	zwrite alphabet
	if alphabet'="abcdefghijklmnopqrstuvwxyz" w "FAIL iott_read",!
	else  w "PASS iott_read",!
	; remove divide by zero from $zinterrupt before entering direct mode
	S $Zint="s b=b+1 s d(b)=i_""_""_j_""_""_lasti_""_""_lastj s b(i)=$get(b(i))+1 s b(j)=$get(b(j))+1 if 1=1 s ^(0)=^b(0)+$ZINI+$T s c=c+1"
	s ^dmcnt(0)=^cnt,^dmtime(0)=$H
	w !,"Entering direct mode, zcontinue to leave",!
	break
	s ^dmcnt(1)=^cnt,^dmtime(1)=$H
	if ^dmcnt(1)'>^dmcnt(0) w !,"FAIL no interrupts during direct mode",!
	else  w !,"PASS direct mode was interrupted",!
	if $get(^showcounts) w !,"interrupts during direct mode = ",^dmcnt(1)-^dmcnt(0),!


	W "Exiting interrupt stage -- waiting for interrupter to shutdown",!

	S ^done=1
	w "."		; to have at least one .
	for k=1:1 Q:^drvactive=0  W "." Hang 1

	W !,"Shutdown complete",!
	W !,"Stats: ",!,^a(0)," transactions were done",!,^cnt," interrupts were sent",!
	W b," interrupt handlers were started or restarted",!,ztcnt," interrupts generated ztraps that were handled",!
	W c," interrupts ran to completion",!!

	W "Entering validation phase",!
	s err=0
	if ^a(0)'=(maxi*maxj) Do
	. Write "Transaction tally is incorrect. Should be ",maxi*maxj," but is ",^a(0),! s err=err+1
	. s sum=0
	. for k=1:1:maxj s sum=sum+^a(k)
	. if sum=^a(0) Write "However ^a(0) does agree with the aggregate sum of the transaction array itself",!
	. Else  Write ".. and ^a(0) does not agree with the aggregate sum of the transaction array: ",sum,! s err=err+1

	s sum=0
	for k=1:1:($S(maxj>maxi:maxj,1:maxi)) s sum=sum+$get(b(k))
	if (b*2)'=sum W "The interrupt*2 count (",b*2,") is not the same as the sum'd interrupt vecotr: ",sum,! s err=err+1
	Else  W "The interrupt count and summed interrupt count array are in agreement",!

	for k=1:1:maxj do
	. if ^a(k)'=maxi Write "Individual trans count for ^a(",k,") is wrong at ",^a(k),". Should be ",maxi,! s err=err+1
	. if a(k)'=maxi Write "Individual trans count for a(",k,") is wrong at ",a(k),". Should be ",maxi,! s err=err+1

	if $get(^a(maxj+1))'="" Write "too many ^a elements exist. Found ^a(",maxj+1,")",! s err=err+1

	if (b*2)'=^b(0) Write "interrupt tally is not correct. b=",b," ^b(0)=",^b(0),". b*2 should be same as ^b(0)",! s err=err+1

	if err=0 Do
	. Write "Test Passed",!
	Else  Do
	. Write "Test Failed",!
	. ZSHOW "*"
	Q

intrdrv(pid,unix,times)
	;
	; If we are doing a unix test, then we can use mupip intrpt to do the interruptions but
	; if we are on VMS, that is not an option because the ZSYSTEM we would use to invoke
	; mupip tries to do IO to the same .mjo file that this process is sending it to and can't
	; and thus creates a new .mjo file for each ZSYSTEM command and contains only the error message
	; that the file is in use by another process. Because of this, we use the $ZSIGPROC function to
	; send the interrupt. Note that with this function you can send any signal but that the signal
	; we are interested in (SIGUSR1) has different values on different platforms. On VMS, it is 16.
	Set $ZTRAP="S $ZT="""" s ^drvactive=0 ZSHOW ""*"" Halt"
	s ^drvactive=1
	Hang 3 ; Chill while parent gets going
	W "Interrupt job beginning for process ",pid,!
	if unix S cmd="$gtm_dist/mupip intr "_pid

	; Interrupt until we are requested to shutdown or we reach an outer limit of times interrupts
	; which probably means we were orphaned and are just chewing up cpu time
	; unless times is 1 if we just want one.
	for x=1:1:times Q:(^done=1)  Do
	. if unix Do
	. . ZSystem cmd
	. . If $zsystem'=0 S ^done=1 Quit
	. Else  Do
	. . If $ZSigproc(pid,16) S ^done=1 Quit
	. S ^cnt=^cnt+1
	. s ^interrupttime(^cnt)=$H
	. d slowdown
	S ^drvactive=0
	W "Interrupt job ",pid," complete after ",^cnt," interrupts",!
	Q

slowdown Q:unix
	; Spin some cycles so we don't bomb the process so hard it can't get anything done.
	; Don't need to do this on Unix. Normal process create takes enough time to
	; keep us from saturating the target.
	for y=1:1:1200 s wastetime(y)=$j(y,10)
	Q

ztrprtn New $ZT Set $ZTRAP="S $ZT="""" s ^drvactive=0 ZSHOW ""*"" Halt"
	; Record various info, reset (repair) zintr count. When we go back, the entire $zint
	; handler will be rerun from the beginning because that's what $ZTRAP does.. restart the
	; line that was executing when it got broke.
	s ztcnt=ztcnt+1
	s ztidxlst(ztcnt)=i_","_j
	if ($P($zs,",",5)="-GTM-E-DIVZERO")&($zini=1) S zintr=zintrini Quit ; return back to $zinterrut
	;
	; Either the ztrap was not a divide by zero we expect or we weren't in an interrupt
	; which we also did not expect
	S $ZT=""
	s ^done=1
	ZSHOW "*"
	Halt
