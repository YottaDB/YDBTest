;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2009, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Check circular container references with one or both specified in a TP restart list
	; under varying conditions. Note there are additional TP tests in the exclusive NEW
	; subsuite and in the spectests.
	;
normal
	;
	; Regular entry point -- do regular testing excepting the auto lv_val garbage collection
	; (aka AutoLVGC) which needs to run for a LONG time so is typically only driven in the
	; manually_started test suite (as alsmemleak).
	;
	set autolvgc=0
	;
	; fall through avoids goto
	;
autolvgc
	;
	; This autolvgc version (which only runs the condition 5 tests) runs a LOT of tests so
	; only runs in the manually_started test cycle.
	;
	kill * kill (autolvgc)
	if $data(autolvgc) set memleakruns=1000
	else  set autolvgc=1,memleakruns=500000,primeruns=5000
	;
	; fall into main
	;
main
	set subtestlist="stst1 stst2 stst3 stst4 stst5 stst6 stst7 stst8 stst9 stst10 stst11"
	; check for dbg version. In Unix check tst_image env var and in VMS test gtm$exe logical.
	if ($ztrnlnm("tst_image")="dbg")!($ztrnlnm("gtm$exe")["DBG") do
	. ; If dbg image we cannot expect deterministic VIEW "LV_GCOL" return values (due to VIEW "LV_GCOL" called
	. ; randomly from gtm_fetch). To avoid changing reference file in lots of places we modify the output for
	. ; dbg to match the pro output.
	. set isdbg=1
	. set lvgcol=2			; default for the number of lv_vals pro recovers with $view("LV_COL") in most tests
	. set lvgcol("stst11")=0	; exception - in stst11 pro recovers only 0
	else  set isdbg=0
	set startmem=0,endmem=0,iter=0,lvsrecoverd=0	; Define so get lvvals allocated early
	set unix=$zv'["VMS"
	;
	; Note one of the conditions we test under is to test the various forms of lv_val garbage collection. Several
	; of the subtests below create "dead data" where two data blobs have container vars that point to each other
	; keeping their reference counts non-zero hence they are not deleted yet all methods of accessing the data
	; have been removed. The lv_val garbage collection deals with this situation by periodically recovering such
	; lv_vals. This LVGC is invoked both through VIEW/$VIEW and can be invoked automatically. The 5th parameter
	; of the "subtests" routine deals with whether we are using $VIEW or automatic LVGC invocation.
	;
	if autolvgc=0 do
	. ;
	. ; Condition 1 -- check with one restart, subtest ends with TROLLBACK, io and NOautoLVGC
	. ;
	. do subtests(1,2,"trollback",1,0)
	. ;
	. ; Condition 2 -- check with two restarts, subtest ends with TROLLBACK, io and NOautoLVGC
	. ;
	. do subtests(2,3,"trollback",1,0)
	. ;
	. ; Condition 3 -- check with two restarts, subtest ends with TCOMMIT, io and NOautoLVGC. ZWRITE what's left
	. ;
	. do subtests(3,3,"tcommit",1,0)
	. ;
	. ; Condition 4 -- memory leak check .. each of the above several times with no output checking allocations. For this
	. ;                condition, we use NOautoLVGC.
	. write !!,"********** Start of memory leak tests *************",!
	. write !,"Begin NOautoLVGC memory tests",!
	. set endmem=0,startmem=$ZREALSTOR
	. for iter=1:1:memleakruns do subtests(4,2,"trollback",0,0)
	. set endmem=$ZREALSTOR
	. if startmem'=endmem write !!,"*** FAIL *** Condition 4a memory usage:  startmem: ",startmem,"  endmem: ",endmem,!!
	. if startmem=endmem write !!,"PASS condition 4a",!
	. ;
	. set endmem=0,startmem=$ZREALSTOR
	. for iter=1:1:memleakruns do subtests(4,3,"trollback",0,0)
	. set endmem=$ZREALSTOR
	. if startmem'=endmem write !!,"*** FAIL *** Condition 4b memory usage:  startmem: ",startmem,"  endmem: ",endmem,!!
	. if startmem=endmem write !!,"PASS condition 4b",!
	. ;
	. set endmem=0,startmem=$ZREALSTOR
	. for iter=1:1:memleakruns do subtests(4,3,"tcommit",0,0)
	. set endmem=$ZREALSTOR
	. if startmem'=endmem write !!,"*** FAIL *** Condition 4c memory usage:  startmem: ",startmem,"  endmem: ",endmem,!!
	. if startmem=endmem write !!,"PASS condition 4c",!
	if autolvgc=1 do
	. ;
	. ; Condition 5 -- Now repeat memory tests with autoLVGC
	. ;	 	   but first prime the pump with one run that causes the number of lv_vals allocated to
	. ;		   expand like it will in the first run we do..
	. ;
	. for iter=1:1:primeruns do subtests(5,2,"trollback",0,1)
	. for iter=1:1:primeruns do subtests(5,3,"trollback",0,1)
	. for iter=1:1:primeruns do subtests(5,3,"tcommit",0,1)
	. ;
	. write !!,"Begin autoLVGC cleanup tests",!
	. set endmem=0,startmem=$ZREALSTOR
	. for iter=1:1:memleakruns do subtests(5,2,"trollback",0,1)
	. set endmem=$ZREALSTOR
	. if startmem'=endmem write !!,"*** FAIL *** Condition 5a memory usage:  startmem: ",startmem,"  endmem: ",endmem,!!
	. if startmem=endmem write !!,"PASS condition 5a",!
	. ;
	. set endmem=0,startmem=$ZREALSTOR
	. for iter=1:1:memleakruns do subtests(5,3,"trollback",0,1)
	. set endmem=$ZREALSTOR
	. if startmem'=endmem write !!,"*** FAIL *** Condition 5b memory usage:  startmem: ",startmem,"  endmem: ",endmem,!!
	. if startmem=endmem write !!,"PASS condition 5b",!
	. ;
	. set endmem=0,startmem=$ZREALSTOR
	. for iter=1:1:memleakruns do subtests(5,3,"tcommit",0,1)
	. set endmem=$ZREALSTOR
	. if startmem'=endmem write !!,"*** FAIL *** Condition 5c memory usage:  startmem: ",startmem,"  endmem: ",endmem,!!
	. if startmem=endmem write !!,"PASS condition 5c",!
	quit

;
; Drive each of the subtests with the passed-in test parameters
;
; Parameters:
;
;   cond     - Identify of the "condition set" (numerically increasing)
;   restarts - How many restarts to perform before allowing it to commit or rollback
;   tendcmd  - either "tcommit" or "trollback" to end the commits in the test
;   io       - flag on whether the test is noisy or silent (1=noisy)
;   autoLVGC - whether LV_GCOL is done as part of the test to see how many lv_vals get recovered
;
subtests(cond,restarts,tendcmd,io,autoLVGC)
	write:io !!,"*********************************** Start new subtest run condition ",cond," ************************************",!
	if 5'>restarts write "Cannot run test with more than 4 restarts (max value of $TRESTART)",! ZShow "*" quit
	for i=1:1:$length(subtestlist," ") do
	. set subtest=$piece(subtestlist," ",i)
	. write:io !,"Starting memory usage: ",$ZREALSTOR,!
	. do @subtest
	. if 'autoLVGC do
	. . set lvsrecovered=$view("LV_GCOL")
	. . ; if dbg, override the actual results with the expected pro results because dbg invokes random extra LV_COLs
	. . if isdbg set lvsrecovered=lvgcol if $data(lvgcol(subtest)) set lvsrecovered=lvgcol(subtest)
	. . write:io "Total of ",lvsrecovered," lv_vals recovered",!
	. ;
	. ; For autoLVGC, chew up some stringpool to cause frequent stringpool garbage collections. Also the amount
	. ; of stringpool chew varies by platform due to differences in sizes/quantities of lv_vals.
	. ;
	. if autoLVGC set zot="" for k=1:1:$select(unix:9,1:8) set zot=zot_k_zot
	. write:io "Ending memory usage: ",$zrealstor,!
	quit

;
; Tests two vars with containers pointing at each other, first var specified in TSTART list, transaction does KILL *
;
stst1
	write:io !!,"********* subtest 1 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varA) ZWRITE follows:",!
	tstart (varA)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB",$select($trestart=0:"3/2",1:"1/0"))
	write:io "------------------",!,"KILL *  ZWRITE follows:",!
	kill *
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, second var specified in TSTART list, transaction does KILL *
;
stst2
	write:io !!,"********* subtest 2 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varB) ZWRITE follows:",!
	tstart (varB)
	zwrite:io ?1"var"1A
	do refcntchk("varA",$select($trestart=0:"3/2",1:"1/0"))
	do refcntchk("varB","3/2")
	write:io "------------------",!,"KILL *  ZWRITE follows:",!
	kill *
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, both vars specified in TSTART list, first var KILL *'d
;
stst3
	write:io !!,"********* subtest 3 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varA,varB) ZWRITE follows:",!
	tstart (varA,varB)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	write:io "------------------",!,"KILL *varA  ZWRITE follows:",!
	kill *varA
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","4/3")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","2/1")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, both vars specified in TSTART list, second var KILL *'d
;
stst4
	write:io !!,"********* subtest 4 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varA,varB) ZWRITE follows:",!
	tstart (varA,varB)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	write:io "------------------",!,"KILL *varB  ZWRITE follows:",!
	kill *varB
	zwrite:io ?1"var"1A
	do refcntchk("varA","4/3")
	do refcntchk("varB","1/0")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","2/1")
	do refcntchk("varB","1/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, both vars specified in TSTART list (reverse order),
; first var KILL *'d
;
stst5
	write:io !!,"********* subtest 5 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varB,varA) ZWRITE follows:",!
	tstart (varB,varA)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	write:io "------------------",!,"KILL *varA  ZWRITE follows:",!
	kill *varA
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","4/3")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","2/1")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, both vars specified in TSTART list (reverse order),
; second var KILL *'d
;
stst6
	write:io !!,"********* subtest 6 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varB,varA) ZWRITE follows:",!
	tstart (varB,varA)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	write:io "------------------",!,"KILL *varB  ZWRITE follows:",!
	kill *varB
	zwrite:io ?1"var"1A
	do refcntchk("varA","4/3")
	do refcntchk("varB","1/0")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","2/1")
	do refcntchk("varB","1/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, both vars specified in TSTART list, all vars KILL *'d
;
stst7
	write:io !!,"********* subtest 7 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varA,varB) ZWRITE follows:",!
	tstart (varA,varB)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	write:io "------------------",!,"KILL *  ZWRITE follows:",!
	kill *
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests two vars with containers pointing at each other, both vars specified in TSTART list, containers changed to
; point to own base.
;
stst8
	write:io !!,"********* subtest 8 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,foo,i
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "------------------",!,"TSTART (varA,varB) ZWRITE follows:",!
	tstart (varA,varB)
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	write:io "------------------",!,"container reset  ZWRITE follows:",!
	set *varA(1)=varA,*varB(1)=varB
	zwrite:io ?1"var"1A
	do refcntchk("varA","4/3")
	do refcntchk("varB","4/3")
	write:io "------------------",!
	if $increment(foo)<restarts do
	. write:io "TRESTART ZWRITE follows:",!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Tests TSTART * with a new variable added during the transaction .. if the transaction restarts,
; the variable should not exist.
;
stst9
	write:io !!,"********* subtest 9 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,varC,varD
	set varA=1,varB=2,*varA(1)=varB,*varB(1)=varA
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	do refcntchk("varC","1/0")
	do refcntchk("varD","1/0")
	write:io "------------------",!,"TSTART * ZWRITE follows:",!
	tstart *
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	do refcntchk("varC","2/1")
	do refcntchk("varD","2/1")
	write:io "------------------",!,"Definition of varC/varD and container reset follows:",!
	set varC=42,*varD=varC
	zwrite:io ?1"var"1A
	do refcntchk("varA","3/2")
	do refcntchk("varB","3/2")
	do refcntchk("varC","3/1")
	do refcntchk("varD","3/1")
	write:io "------------------",!
	if $trestart<restarts do
	. write:io "TRESTART ZWRITE follows: ",$TRESTART,!
	. trestart
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	do refcntchk("varC","2/0")
	do refcntchk("varD","2/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Test nested TSTARTs with different (overlapping) save sets. The arrays being saved are also pointing
; to other arrays that should also be saved and restored. Reference counts are verified at every step.
;
stst10
	write:io !!,"********* subtest 10 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new varA,varB,varC,varD,varE,varF,varG,varH
	set varA="a",varA(1)="a1",*varA(2)=varE
	set varB="b",varB(1)="b1",*varB(2)=varF
	set varC="c",*varC(1)=varG,varC(2)="c2"
	set varD="d",varD(1)="d1",*varD(2)=varH
	set varE="e",varE(1)="e1"
	set varF="f",varF(3)="f3"
	set varG="g",varG(1)="g1",*varG(2)=varE
	set varH="h",varH(1)="h1",*varH(3)=varF
	do refcntchk("varA","1/0")
	do refcntchk("varB","1/0")
	do refcntchk("varC","1/0")
	do refcntchk("varD","1/0")
	do refcntchk("varE","3/2")
	do refcntchk("varF","3/2")
	do refcntchk("varG","2/1")
	do refcntchk("varH","2/1")
	write:io "------------------",!,"TSTART (varA,varB) [*** first ***] ZWRITE follows:",!
	tstart (varA,varB)
	zwrite:io ?1"var"1A
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	do refcntchk("varC","1/0")
	do refcntchk("varD","1/0")
	do refcntchk("varE","4/3")
	do refcntchk("varF","4/3")
	do refcntchk("varG","2/1")
	do refcntchk("varH","2/1")
	; make some changes to varA/varB but no reference counts change
	write:io "------------------",!,"Making some changes to varA/varB",!
	set varA(1)="a1-1",varA(3)="a3-1"
	set varB="b-1",varB(3)="b3-1"
	; but verify reference counts anyway
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	do refcntchk("varC","1/0")
	do refcntchk("varD","1/0")
	do refcntchk("varE","5/4")
	do refcntchk("varF","5/4")
	do refcntchk("varG","2/1")
	do refcntchk("varH","2/1")
	; Create a nested stackframe for nested TSTART
	do
	. tstart (varB,varC,varD)
	. write:io "------------------",!,"TSTART (varB,varC,varD) ZWRITE follows:",!
	. zwrite:io ?1"var"1A
	. do refcntchk("varA","2/1")
	. do refcntchk("varB","2/1")
	. do refcntchk("varC","2/1")
	. do refcntchk("varD","2/1")
	. do refcntchk("varE","5/4")
	. do refcntchk("varF","5/4")
	. do refcntchk("varG","3/2")
	. do refcntchk("varH","3/2")
	. write:io "------------------",!,"Making some changes to all but varA",!
	. set varB(2)="b2-2",varB(4)="b4-2"	  ; replaces a container -> varF
	. set varC="c-2",varC(3)="c3-2"
	. set *varE(1)=varA
	. set *varF(2)=varB
	. set varG(3)="g3-2"
	. set varH(2)="h2-2"
	. kill varD				  ; kills container -> varH
	. zwrite:io ?1"var"1A
	. do refcntchk("varA","3/2")
	. do refcntchk("varB","3/2")
	. do refcntchk("varC","2/1")
	. do refcntchk("varD","2/1")
	. do refcntchk("varE","6/5")
	. do refcntchk("varF","5/4")
	. do refcntchk("varG","4/3")
	. do refcntchk("varH","3/2")
	. write:io "------------------",!
	. if $trestart<restarts do
	. . write:io "TRESTART ******** ZWRITE follows: ",$TRESTART,!
	. . trestart
	. tcommit
	write:io tendcmd," command to end transaction - ZWRITE follows",!
	xecute tendcmd
	zwrite:io ?1"var"1A
	do refcntchk("varA","2/1")
	do refcntchk("varB","2/1")
	do refcntchk("varC","1/0")
	do refcntchk("varD","1/0")
	do refcntchk("varE","3/2")
	do refcntchk("varF","2/1")
	do refcntchk("varG","2/1")
	do refcntchk("varH","1/0")
	write:io "Return will now pop NEWs and clean alias var test results",!
	quit

;
; Added for GTM-8064 and simulates a failure encountered in PROFILE code with nested transactions with an interveening exclusive NEW.
; Although this test could live in the xnewtest suite, this test offered a better environment to test multiple flavors so was added
; here.
;
; Test has a passed-through exclusive NEW, then an outer and inner transaction. The inner transaction is adding alias containers to
; the passed-through scalar with multiple iterations of the inner transaction inside the outer transaction
;
; Note this test is not real useful in the memory leak checking part so just return when !io.
;
stst11
	quit:'io
	write:io !!,"********* subtest 11 condition ",cond," ********* restarts: ",restarts," transaction end cmd: ",tendcmd,!
	new idx,iter,i,a,n1,n2,n3,n4,n5,fetchstmt,dbg
	set dbg=0						; Set to 1 to enable debugging lines (come out in trace)
	set:("trollback"=tendcmd) tendcmd=tendcmd_" -1"		; So only unroll one level at a time
	for iter=1:1:3 do
	. set fetchstmt=$select(1=iter:"do sts11newvar1(.a,41+i)",2=iter:"do sts11newvar2(.a,41+i)",3=iter:"set *a(""newvar"",""F""_$zahandle(val),$increment(idx))=$$sts11newvar3(41+i)")
	. write:io !!,"Start of iteration ",iter," using fetchrtn sts11newvar",iter," and fetchstmt: ",fetchstmt,!
	. do sts11rtn
	quit
sts11rtn
	new a
	set idx=0
	for i=1:1:4 set a(i)=i
	do refcntchk("a","1/0")
	new (a,fetchstmt,tendcmd,dbg)
	write:dbg !,"**** Exclusive NEW passing through a ****",!
	do refcntchk("a","2/1")
	do
	. write !,"*** Starting TP transaction preserving nothing ***",!
	. tstart ():serial
	. do refcntchk("a","2/1")
	. for i=1:1:3 do
	. . write:dbg !,"** Starting nested TP transaction (",i,") preserving everything ***",!
	. . tstart *:serial
	. . do refcntchk("a","3/2")
	. . write:dbg !,"** Starting to modify a to add containers - first show what it looks like now:",!
	. . zwrite:dbg a
	. . xecute fetchstmt
	. . write !,"** New container added - Current value(s) of a:",!
	. . zwrite a
	. . write:dbg !,"** committing inner transaction",!
	. . xecute tendcmd
	. . write:dbg !,"** Inner tstart committed - allocate a bunch of new vars to chew up any released lv_vals",!
	. . new n1,n2,n3,n4,n5
	. . write:dbg !,"** Result of commit on scalar ""a"":",!
	. . zwrite:dbg a
	. xecute tendcmd
	write !,"**** Final result after ",tendcmd," of entire transaction",!
	do refcntchk("a","2/1")					; Expect 2/1 since still under XNEW where a was passed thru
	zwrite a
	quit
sts11newvar1(scalar,val)
	set *scalar("newvar","F"_$zahandle(val))=val		; "F" prefix so is always alpha-numeric - so it always has quotes in output
	quit
sts11newvar2(scalar,val)
	new newval
	set newval=val
	set *scalar("newvar","F"_$zahandle(val),$increment(idx))=val
	write "* In newvar after adding new container: scalar tref/cref: ",$view("LV_REF","scalar"),"/",$view("LV_CREF","scalar")
	write "  val tref/cref: ",$view("LV_REF","val"),"/",$view("LV_CREF","val")
	write "  newval tref/cref: ",$view("LV_REF","newval"),"/",$view("LV_CREF","newval"),"  $TLEVEL=",$tlevel,!
	quit
sts11newvar3(val)
	quit *val


refcntchk(var,refs)
	; Routine to check total and container reference counts and compare against expected.
	new rfs
	set rfs=$view("LV_REF",var)_"/"_$view("LV_CREF",var)
	if rfs'=refs write !,"*** FAIL *** ",$stack($stack(-1)-1,"PLACE"),": Var '",var,"' has refcnts ",rfs," but refcnts of ",refs," were expected",!
	quit
