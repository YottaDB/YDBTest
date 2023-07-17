;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2004-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Usage:
;	1) Test system mostly calls imptp.csh or imptp.com to run this routine. Caller sets the environment as appropriate
;	2) To run it in background, just call ^imptp(number of jobs)
;	3) To run in foreground with fixed number of tranasactions,
;		set ^%imptp("top") to desired value, and set jmaxwait for timeout
;	Known limitations:
;	-----------------
;	1) checkdb will error out if gtcm and crash test is used
;	2) for non-tp and crash this will still do some TP updates
;	3) skipreg is allowed only for crash test. For now it skips only HREG. imptp.m will still fill HREG.
;		checkdb/extract/dbcheck need to take care of skipping the region.
;	4) can be invoked concurrently with different gtm_test_dbfillid but checkdb should be called once for each value
;
imptp(jobcnt); Infinite multiprocess TP or non-TP database fill program
	;
	new gblprefix,i
	set $ETRAP="goto ERROR^imptp"
	if $ztrnlnm("gtm_test_onlinerollback")="TRUE" do incretrap^orlbkresume set $ETRAP="do ^incretrap"
	;
	w "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	w "$zro=",$zro,!
	; Note that we immediately return from parent.
	; So no need to kill it for crash tests. So, imptp.mjo0 is not created.
        w "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
	if $zv["VMS" w "Process Name: ",$ZGETJPI("","PRCNAM"),!
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Start processing test system paramters
	;
	; istp = 0 non-tp
	; istp = 1 TP
	; istp = 2 ZTP
	set fillid=+$ztrnlnm("gtm_test_dbfillid")
	if $ztrnlnm("gtm_test_tp")="NON_TP"  do
	.  set istp=0
	.  write "It is Non-TP",!
	else  do
	.  if $ztrnlnm("gtm_test_dbfill")="IMPZTP" set istp=2  write "It is ZTP",!
	.  else  set istp=1  write "It is TP",!
	set ^%imptp(fillid,"istp")=istp
	;
	if $ztrnlnm("gtm_test_tptype")="ONLINE" set ^%imptp(fillid,"tptype")="ONLINE"
	else  set ^%imptp(fillid,"tptype")="BATCH"
	;
	; Randomly 50% time use noisolation for TP if gtm_test_noisolation not defined, and only if not already set.
	if '$data(^%imptp(fillid,"tpnoiso")) do
	.  if (istp=1)&(($ztrnlnm("gtm_test_noisolation")="TPNOISO")!($random(2)=1)) set ^%imptp(fillid,"tpnoiso")=1
	.  else  set ^%imptp(fillid,"tpnoiso")=0
	;
	; Randomly 50% time use optimization for redundant sets, only if not already set.
	if '$data(^%imptp(fillid,"dupset")) do
	.  if ($random(2)=1) set ^%imptp(fillid,"dupset")=1
	.  else  set ^%imptp(fillid,"dupset")=0
	;
	set ^%imptp(fillid,"crash")=+$ztrnlnm("gtm_test_crash")
	;
	set ^%imptp(fillid,"gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
	;
	set ^%imptp(fillid,"skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
	;
	set jobid=+$ztrnlnm("gtm_test_jobid")
	;
	set ^%imptp("fillid",jobid)=fillid
	; Grab the key and record size from DSE
	do get^datinfo("^%imptp("_fillid_")")
	set ^%imptp(fillid,"gtm_test_spannode")=+$ztrnlnm("gtm_test_spannode")
	;
	; if triggers are installed, the following will invoke the trigger
	; for ^%imptp(fillid,"trigger") defined in test/com_u/imptp.trg and set
	; ^%imptp(fillid,"trigger") to 1
	set ^%imptp(fillid,"trigger")=0
	;
	if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
	else  if ^%imptp(fillid,"totaljob")'=jobcnt  w "IMPTP-E-MISMATCH: Job number mismatch",!  zwr ^%imptp  h
	;
	;
	; End of processing test system paramters
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;   This program fills database randomly using primitive root of a field.
	;   Say, w is the primitive root and we have 5 jobs
	;   Job 1 : Sets index w^0, w^5, w^10 etc.
	;   Job 2 : Sets index w^1, w^6, w^11 etc.
	;   Job 3 : Sets index w^2, w^7, w^12 etc.
	;   Job 4 : Sets index w^3, w^8, w^13 etc.
	;   Job 5 : Sets index w^4, w^9, w^14 etc.
	;   In above example nroot = w^5
	;   In above example root =  w
	;   Precalculate primitive root for a prime and set them here
	set ^%imptp(fillid,"prime")=50000017	;Precalculated
	set ^%imptp(fillid,"root")=5		;Precalculated
	set ^endloop(fillid)=0	;To stop infinite loop
	if $data(^cntloop(fillid))=0 set ^cntloop(fillid)=0	; Initialize before attempting $incr in child
	if $data(^cntseq(fillid))=0 set ^cntseq(fillid)=0	; Initialize before attempting $incr in child
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;
	set ^%imptp(fillid,"jsyncnt")=0		; To count number of processes are ready to be killed by crash scripts
	; If test is running with gtm_test_spanreg'=0, we want to make sure the *xarr global variables continue to
	; cover ALL regions involved in the updates as this is relied upon in Stage 11 of imptp updates.
	; See <GTM_2168_imptp_dbcheck_verification_fail> for details. An easy way to achieve this is by
	; unconditionally (gtm_test_spanreg is 0 or not) excluding all these globals from random mapping to multiple regions.
	set gblprefix="abcdefgh"
	for i=1:1:$length(gblprefix) set ^%sprgdeExcludeGbllist($extract(gblprefix,i)_"ndxarr")=""
	;
	; When rsh command exits after starting remote jobs, non-detached child processes will also die
	; So for gtcm_gnp test or multi_machine VMS tests we must use detach
	; If the terminal is gone after starting child processes, all child can also die
	; So it is safer to start detached job always
	set jdetach=1		; VMS will start detached jobs
	if ($data(jmaxwait))=0 set jmaxwait=0	; Child process will continue in background. So do not wait, just return.
	do ^job("impjob^imptp",jobcnt,"""""")
	; Wait until the first update on all regions happen
	set start=$horolog
	for  set stop=$horolog quit:^cntloop(fillid)  quit:($$^difftime(stop,start)>300)  hang 1
	write:$$^difftime(stop,start)>300 "TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!",!
	;
	; Wait for all M child processes to start and reach a point when it is safe to simulate crash
	set timeout=600	; 10 minutes to start and reach the sync point for kill
	for i=1:1:600 hang 1 quit:^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"totaljob")
	if ^%imptp(fillid,"jsyncnt")<^%imptp(fillid,"totaljob") do
	. write "TEST-E-imptp.m time out for jobs to start and synch after ",timeout," seconds",!
	. zwrite ^%imptp
	;
	do writeinfofileifneeded
	write "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	quit
	;
impjob;
	; use incretrap only when the test needs it, otherwise use the default that halts
	set $ETRAP="goto ERROR^imptp"
	write "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	write "$zro=",$zro,!
	if $ztrnlnm("gtm_test_onlinerollback")="TRUE" merge %imptp=^%imptp
	;
	set jobno=jobindex	; Set by job.m ; not using $job makes imptp resumable after a crash!
	set jobid=+$ztrnlnm("gtm_test_jobid")
	set fillid=^%imptp("fillid",jobid)
	set jobcnt=^%imptp(fillid,"totaljob")
	set prime=^%imptp(fillid,"prime")
	set root=^%imptp(fillid,"root")
	set top=+$GET(^%imptp(fillid,"top"))
	if top=0 set top=prime\jobcnt
	set istp=^%imptp(fillid,"istp")
	set tptype=^%imptp(fillid,"tptype")
	set tpnoiso=^%imptp(fillid,"tpnoiso")
	set dupset=^%imptp(fillid,"dupset")
	set skipreg=^%imptp(fillid,"skipreg")
	set crash=^%imptp(fillid,"crash")
	set gtcm=^%imptp(fillid,"gtcm")
	; ONLINE ROLLBACK - BEGIN
	; Randomly 50% when in TP, switch the online rollback TP mechanism to restart outside of TP
	;	orlbkintp = 0 disable online rollback support - this is the default
	;	orlbkintp = 1 use the TP rollback mechanism outside of TP, should be true for only TP
	;	orlbkintp = 2 use the TP rollback mechanism inside of TP, should be true for only TP
	set orlbkintp=0
	new ORLBKRESUME
	if $ztrnlnm("gtm_test_onlinerollback")="TRUE" do init^orlbkresume("imptp",$zlevel,"ERROR^imptp") if istp=1 set orlbkintp=($random(2)+1)
	; ONLINE ROLLBACK -  END
	; Node Spanning Blocks - BEGIN
	set keysize=^%imptp(fillid,"key_size")
	set recsize=^%imptp(fillid,"record_size")
	set span=+^%imptp(fillid,"gtm_test_spannode")
	; Node Spanning Blocks - END
	; TRIGGERS - BEGIN
	; The triggers section MUST be the last update to ^%imptp during setup. Online Rollback tests use this as a marker to detect
	; when ^%imptp has been rolled back
	set trigger=^%imptp(fillid,"trigger"),ztrcmd="ztrigger ^lasti(fillid,jobno,loop)",ztr=0,dztrig=0
	if trigger do
	. set trigname="triggernameforinsertsanddels"
	. set fulltrig="^unusedbyothersdummytrigger -commands=S -xecute=""do ^nothing"" -name="_trigname
	. set ztr=(trigger#10)>1  ; ZTRigger command testing
	. set dztrig=(trigger>10) ; $ZTRIGger() function testing
	; TRIGGERS -  END
	set zwrcmd="zwr jobno,istp,tptype,tpnoiso,orlbkintp,dupset,skipreg,crash,gtcm,fillid,keysize,recsize,trigger"
	write zwrcmd,!
	xecute zwrcmd
	;
        write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),!
	if $zv["VMS" do ^jobname(jobno)
	;
	lock +^%imptp(fillid,"jsyncnt")  set ^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"jsyncnt")+1  lock -^%imptp(fillid,"jsyncnt")
	;
	; lfence is used for the fence type of last segment of updates of *ndxarr at the end
	; For non-tp and crash test meaningful application checking is very difficult
	; So at the end of the iteration TP transaction is used
	; For gtcm we cannot use TP at all, because it is not supported.
	; We cannot do crash test for gtcm.
	set lfence=istp
	if (istp=0)&(crash=1) set lfence=1	; TP fence
	if gtcm=1 set lfence=0			; No fence
	;
	if tpnoiso do tpnoiso^imptp
	if dupset view "GVDUPSETNOOP":1
	;
	set fltconst=3.14
	set nroot=1
	for J=1:1:jobcnt set nroot=(nroot*root)#prime
orlbkres; Online Rollback handling needs this to stay here
	if ($ztrnlnm("gtm_test_onlinerollback")="TRUE")&(trigger) do
	.	tstart (orlbkcycle) do:orlbkintp>0 ifneeded^orlbkresume(istp)
	.	new imptprolled			; the last subscript set for ^%imptp is "trigger". If it doesn't exist then part or all of ^%imptp has been rolled back
	.	set imptprolled=($data(^%imptp(fillid,"trigger"))=0)
	.	set ^%imptp(fillid,"trigger")=0	; if triggers are active, this will result in a non-zero number
	.	set trigger=^%imptp(fillid,"trigger")	; if not, this will disable trigger testing
	.	set ztr=(trigger#10)>1  ; ZTRigger command testing
	.	set dztrig=(trigger>10) ; $ZTRIGger() function testing
	.	kill:imptprolled ^%imptp(fillid,"trigger") ; if ^%imptp was rolled away, do not leave this around or checkdb won't know to reload ^%imptp from a file
	.	tcommit
	; imptp can be restarted at the saved value of lasti
	set lasti=+$get(^lasti(fillid,jobno))
	zwrite lasti
	;
	; Initially we have followings:
	; 	Job 1: I=w^0
	; 	Job 2: I=w^1
	; 	Job 3: I=w^2
	; 	Job 4: I=w^3
	; 	Job 5: I=w^4
	;	nroot = w^5 (all job has same value)
	set I=1
	for J=2:1:jobno  set I=(I*root)#prime
	for J=1:1:lasti  set I=(I*nroot)#prime
	;
	set vms=$zv["VMS"
	write "Starting index:",lasti+1,!
	for loop=lasti+1:1:top do  quit:$get(^endloop(fillid),0)
	. ; Go to the sleep cycle if a ^pause is requested. Wait until ^resume is called
	. do pauseifneeded^pauseimptp
	. do:orlbkintp=1 ifneeded^orlbkresume(istp)
	. if vms do
	. . set subs=$$^genstr(I)		; I to subs  has one-to-one mapping
	. . set val=$$^genstr(loop)		; loop to val has one-to-one mapping
	. else  do
	. . set subs=$$^ugenstr(I)		; I to subs  has one-to-one mapping
	. . set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
	. . do:dztrig ^imptpdztrig(1,istp<2)
	. . set ztwormstr="set $ztwormhole=subs"
	. set recpad=recsize-($$^dzlenproxy(val)-$length(val))				; padded record size minus UTF-8 bytes
	. set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
	. set valMAX=$j(val,recpad)
	. set valALT=$select(span>1:valMAX,1:val)
	. set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))	; padded key size minus UTF-8 bytes. ZTP uses no padding
	. set subsMAX=$j(subs,keypad)
	. if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
	. ; Stage 1
	. if istp=1 tstart *:(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. if istp=2 ztstart
	. set ^arandom(fillid,subsMAX)=val
	. if ((istp=1)&(crash)) do
	. . set rndm=$r(10)
	. . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
	. . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time
	. . if $TRESTART set ^zdummy($TRESTART)=jobno	; In case of restart cause different TP transaction flow
	. set ^brandomv(fillid,subsMAX)=valALT
	. if 'trigger do
	. . set ^crandomva(fillid,subsMAX)=valALT
	. set ^drandomvariable(fillid,subs)=valALT
	. if 'trigger do
	. . set ^erandomvariableimptp(fillid,subs)=valALT
	. . set ^frandomvariableinimptp(fillid,subs)=valALT
	. set ^grandomvariableinimptpfill(fillid,subs)=val
	. if 'trigger do
	. . set ^hrandomvariableinimptpfilling(fillid,subs)=val
	. . set ^irandomvariableinimptpfillprgrm(fillid,subs)=val
	. if trigger xecute ztwormstr	; fill in $ztwormhole for below update that requires "subs"
	. set ^jrandomvariableinimptpfillprogram(fillid,I)=val
	. if 'trigger do
	. . set ^jrandomvariableinimptpfillprogram(fillid,I,I)=val
	. . set ^jrandomvariableinimptpfillprogram(fillid,I,I,subs)=val
	. if istp'=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ; Stage 2
	. set rndm=$random(10)
	. if (5>rndm)&(0=$tlevel)&trigger do  ; $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add
	. . set rndm=$random(10),trig=$select(0=rndm:"-"_fulltrig,1=rndm:"-"_trigname,1:"+"_fulltrig)
	. . set ztrigstr="set ztrigret=$ztrigger(""item"",trig)"	; xecute needed so it compiles on non-trigger platforms
	. . xecute ztrigstr
	. . if (trig=("-"_trigname))&(ztrigret=0) set ztrigret=1	; trigger does not exist, ignore delete-by-name error
	. . goto:'ztrigret ERROR
	. set ^antp(fillid,subs)=val
        . if 'trigger do
	. . set ^bntp(fillid,subs)=val
	. . set ^cntp(fillid,subs)=val
	. . set ^dntp(fillid,subs)=valALT
	. else  do
	. . set ^dntp(fillid,subs)=valALT
	. ; Stage 3
	. if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
	. if istp=2 ztstart
	. do:dztrig ^imptpdztrig(2,istp<2)
	. set ^entp(fillid,subs)=val
	. if 'trigger do
	. . set ^fntp(fillid,subs)=val
	. if trigger do
	. . set ^fntp(fillid,subs)=$extract(^fntp(fillid,subs),1,$length(^fntp(fillid,subs))-$length("suffix"))
	. set ^gntp(fillid,subsMAX)=valMAX
	. if 'trigger do
	. . set ^hntp(fillid,subsMAX)=valMAX
	. . set ^intp(fillid,subsMAX)=valMAX
	. . set ^bntp(fillid,subsMAX)=valMAX
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ; Stage 4
	. for J=1:1:jobcnt D
	. . set valj=valALT_J
	. . ;
        . . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. . if istp=2 ztstart
	. . set ^arandom(fillid,subs,J)=valj
	. . if 'trigger do
	. . . set ^brandomv(fillid,subs,J)=valj
	. . . set ^crandomva(fillid,subs,J)=valj
	. . . set ^drandomvariable(fillid,subs,J)=valj
	. . . set ^erandomvariableimptp(fillid,subs,J)=valj
	. . . set ^frandomvariableinimptp(fillid,subs,J)=valj
	. . . set ^grandomvariableinimptpfill(fillid,subs,J)=valj
	. . . set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj
	. . . set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj
	. . do:dztrig ^imptpdztrig(1,istp<2)
	. . if istp=1 tcommit
	. . if istp=2 ztcommit
	. . ;
	. ; Stage 5
        . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. if istp=2 ztstart
	. do:dztrig ^imptpdztrig(2,istp<2)
	. if ((istp=1)&(crash)) do
	. . set rndm=$random(10)
	. . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time
	. . if rndm=2 if $TRESTART>2  hang $random(10)	; Just randomly hold crit for long time
	. kill ^arandom(fillid,subs,1)
	. if 'trigger do
	. . kill ^brandomv(fillid,subs,1)
	. . kill ^crandomva(fillid,subs,1)
	. . kill ^drandomvariable(fillid,subs,1)
	. . kill ^erandomvariableimptp(fillid,subs,1)
	. . kill ^frandomvariableinimptp(fillid,subs,1)
	. . kill ^grandomvariableinimptpfill(fillid,subs,1)
	. . kill ^hrandomvariableinimptpfilling(fillid,subs,1)
	. . kill ^irandomvariableinimptpfillprgrm(fillid,subs,1)
	. do:dztrig ^imptpdztrig(1,istp<2)
	. do:dztrig ^imptpdztrig(2,istp<2)
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ; Stage 6
        . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. if istp=2 ztstart
	. zkill ^jrandomvariableinimptpfillprogram(fillid,I)
	. if 'trigger do
	. . zkill ^jrandomvariableinimptpfillprogram(fillid,I,I)
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ; Stage 7 : delimited spanning nodes to be changed in Stage 10
	. ; At the end of ithis transaction, ^aspan=^espan and $tr(^aspan," ","")=^bspan
	. ; Partial completion due to crash results in: 1. ^aspan is defined and ^[be]span are undef
	. ;				 		2. ^aspan=^espan and ^bspan is undef
        . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
	. if istp=2 ztstart
	. ; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char
	. set piecesize=7
	. set valPIECE=valMAX
	. set totalpieces=($length(valPIECE)/piecesize)+1
	. for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|" ; $extract beyond $length returns a null character
	. set totalpieces=$length(valPIECE,"|")
	. set ^aspan(fillid,I)=valPIECE
        . if 'trigger do
	. . set ^espan(fillid,I)=$get(^aspan(fillid,I))
	. . set ^bspan(fillid,I)=$tr($get(^aspan(fillid,I))," ","")
        . if istp=1 tcommit
	. if istp=2 ztcommit
	. ; Stage 8
	. kill ^arandom(fillid,subs,1)	; This results nothing
	. kill ^antp(fillid,subs)
	. if 'trigger do
	. . kill ^bntp(fillid,subs)
	. . zkill ^brandomv(fillid,subs,1)	; This results nothing
	. . zkill ^cntp(fillid,subs)
	. . zkill ^dntp(fillid,subs)
	. kill ^bntp(fillid,subsMAX)
	. if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP.
	. ; Stage 9
	. ; $incr on ^cntloop and ^cntseq exercize contention in CREG (regions > 3) or DEFAULT (regions <= 3)
	. set flag=$random(2)
	. if flag=1,lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. if flag=1,lfence=2 ztstart
	. set cntloop=$incr(^cntloop(fillid))
	. set cntseq=$incr(^cntseq(fillid),(13+jobcnt))
	. if flag=1,lfence=1 tcommit
	. if flag=1,lfence=2 ztcommit
	. ; Stage 10 : More SET $piece
	. ; At the end of ithis transaction, $tr(^aspan," ","")=^bspan and $p(^aspan,"|",targetpiece)=$p(^espan,"|",targetpiece)
	. ; NOTE that ZKILL ^espan means that the SET $PIECE of ^espan will only create pieces up to the target piece
	. ; Partial completion due to crash results in: 1. ^espan is undef and $tr(^aspan," ","")=^bspan
	. ;				   		2. ^espan is undef and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
	. ;				   		3. $p(^aspan,"|",targetpiece)=$tr($p(^espan,"|",targetpiece) and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X")
        . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp)
	. if istp=2 ztstart
	. set targetpiece=(loop#(totalpieces))
	. set subpiece=$tr($piece($get(^aspan(fillid,I)),"|",targetpiece)," ","X")
	. zkill ^espan(fillid,I)
	. set $piece(^aspan(fillid,I),"|",targetpiece)=subpiece
        . if 'trigger do
	. . set $piece(^espan(fillid,I),"|",targetpiece)=subpiece
	. . set $piece(^bspan(fillid,I),"|",targetpiece)=subpiece
        . if istp=1 tcommit
	. if istp=2 ztcommit
	. ; Stage 11
	. if lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp)
	. if lfence=2 ztstart
	. do:dztrig ^imptpdztrig(1,istp<2)
	. xecute:ztr "set $ztwormhole=I ztrigger ^andxarr(fillid,jobno,loop) set $ztwormhole="""""
	. set ^andxarr(fillid,jobno,loop)=I
	. if 'trigger do
	. . set ^bndxarr(fillid,jobno,loop)=I
	. . set ^cndxarr(fillid,jobno,loop)=I
	. . set ^dndxarr(fillid,jobno,loop)=I
	. . set ^endxarr(fillid,jobno,loop)=I
	. . set ^fndxarr(fillid,jobno,loop)=I
	. . set ^gndxarr(fillid,jobno,loop)=I
	. . set ^hndxarr(fillid,jobno,loop)=I
	. . set ^indxarr(fillid,jobno,loop)=I
	. if istp=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop
	. if lfence=1 tcommit
	. if lfence=2 ztcommit
	. set I=(I*nroot)#prime
	;
	; End For Loop
	;
	write "End index:",loop,!
	write "Job completion successful",!
	write "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	quit
noop;
	; Just to stress memory
	new index,var
	set ^dummynoop(fillid,jobno,loop,"start",$job,$h)=$ZGETJPI(0,"CPUTIM")
	for index=1:1:1000 do
	. set var(index)=$j(index,2048)_$h
	kill index,var
	hang 1
	set ^dummynoop(fillid,jobno,loop,"end",$job,$h)=$ZGETJPI(0,"CPUTIM")
	write "TEST-I-INFO : did noop",!
	quit
tpnoiso;
	if (""=$ztrnlnm("ydb_app_ensures_isolation")) do
	. view "NOISOLATION":"^arandom,^brandomv,^crandomva,^drandomvariable,^erandomvariableimptp,^frandomvariableinimptp,^grandomvariableinimptpfill,^hrandomvariableinimptpfilling,^irandomvariableinimptpfillprgrm,^jrandomvariableinimptpfillprogram"
	; else imptp.csh has already set the env var to the above list of globals
	;
	write "$view(""NOISOLATION"",""^arandom"")=",$view("NOISOLATION","^arandom"),!
	write "$view(""NOISOLATION"",""^brandomv"")=",$view("NOISOLATION","^brandomv"),!
	write "$view(""NOISOLATION"",""^crandomva"")=",$view("NOISOLATION","^crandomva"),!
	write "$view(""NOISOLATION"",""^drandomvariable"")=",$view("NOISOLATION","^drandomvariable"),!
	write "$view(""NOISOLATION"",""^erandomvariableimptp"")=",$view("NOISOLATION","^erandomvariableimptp"),!
	write "$view(""NOISOLATION"",""^frandomvariableinimptp"")=",$view("NOISOLATION","^frandomvariableinimptp"),!
	write "$view(""NOISOLATION"",""^grandomvariableinimptpfill"")=",$view("NOISOLATION","^grandomvariableinimptpfill"),!
	write "$view(""NOISOLATION"",""^hrandomvariableinimptpfilling"")=",$view("NOISOLATION","^hrandomvariableinimptpfilling"),!
	write "$view(""NOISOLATION"",""^irandomvariableinimptpfillprgrm"")=",$view("NOISOLATION","^irandomvariableinimptpfillprgrm"),!
	write "$view(""NOISOLATION"",""^jrandomvariableinimptpfillprogram"")=",$view("NOISOLATION","^jrandomvariableinimptpfillprogram"),!
	quit
	; attempt to recover ^%imptp from a file after online rollback rolled it away
writeinfofileifneeded
	new needinfo,file
	set needinfo=($ztrnlnm("gtm_test_onlinerollback")="TRUE")
	quit:needinfo=0
	set file="gtm_test_imptp_info"
	open file:newversion
	use file
	zwrite ^%imptp
	close file
	use $p
	quit
loadinfofileifneeded(fillid)
	new file,needinfo,line,i
	set needinfo=(($data(^%imptp(fillid,"trigger"))=0)!($data(^endloop)=0))
	quit:needinfo=0
	set file="gtm_test_imptp_info"
	open file:readonly
	use file
	for i=1:1  read line xecute:$length(line) "set "_line quit:$zeof
	close file
	use $p
	quit
	;
ERROR	ZSHOW "*"
	do:$zstatus["TRIGDEFBAD"
	. for  set fillid=$order(^endloop($get(fillid))) quit:fillid=""  set ^endloop(fillid)=1
	. tcommit:$TLEVEL
	if $TLEVEL TROLLBACK
	quit

imptpflavor	;
	; $zcmdline contains a list of imptp flavors that are disabled.
	; This function randomly picks a imptp flavor excluding the choices in the disabled list.
	; Randomly pick from the following choices for flavors of imptp
	;	M (rand=0),
	;	C simpleAPI (rand=1),
	;	C simpleThreadedAPI (rand=2),
	;	Python (rand=3),
	;	Golang (rand=4),
	;	Rust (rand=5)
	new disable
	for i=1:1  set arg=$piece($zcmdline," ",i)  quit:arg=""  set disable(arg)=""
	for  set rand=$random(6) quit:'$data(disable(rand))
	write rand,!
	quit

