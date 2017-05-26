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
; Test exclusive new operations
;

	Write !,!,"******* Start of ",$Text(+0)," *******",!,!

	Write !,"--------------------------",!
	For i=1:1:21 do docase("txnew"_i)
	; Following tests are for interactions between TP and exclusive NEW
	For i=1:1:5 do docase("txtp"_i)
	Write !,!,"******* Finish ",$Text(+0)," *******",!,!
	Quit
docase(casename)
	Write "Test case: ",casename,!
	Kill *	; Rid the world of aliases prior to new case
	Do @casename
	Write !,"--------------------------",!
	Quit
;
; txnew 1: test basic xnew creation and unwind
;
txnew1
	New
	Set a=1,b=2
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do
	. New (a)
	. ZWrite
	. Set a="1a"
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Quit

;
; txnew 2: test basic passing of alias through exclusive new.
;          set other half of alias (no effect) in xnew env.
;
txnew2
	New
	Set a=1,b=2
	Set *g=a
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Do
	. New (g)
	. ZWrite
	. Set a="2a"	; Note this should have no effect on g or a in original symtab
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Quit

;
; txnew 3: pass alias through exclusive new
;      	   set value of passed through alias
;
txnew3
	New
	Set a=1,b=2
	Set *g=a
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Do
	. New (g)
	. ZWrite
	. Set g="3g"
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Quit

;
; txnew 4: Create alias with exlusive new passthru data
;      	   Since g is created locally in new symtab, its data
;      	   must be copied back to earlier symtab to be visible.
;	   The old g should be restored.
;
txnew4
	New
	Set a=1,b=2
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do
	. New (a)
	. Set g="4g"
	. Set *a=g
	. ZWrite
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Quit

;
; txnew 5: pass thru two aliases, set value, verify result
;
txnew5
	New
	Set a=1,b=2
	Set *g=a
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Do
	. New (a,g)
	. ZWrite
	. Set a="5a"
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Quit

;
; txnew 6: pass thru two aliases, create some new data in
;          a local var and alias it to one of the two. Should
;	   cause data copy and verify reference counts.
;
txnew6
	New
	Set a=1,b=2
	Set *g=a
	Write "Initial values",!
	ZWrite
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","2/0")
	Do
	. New (a,g)
	. Write "... After NEW",!
	. ZWrite
	. Do refcntchk("a","4/2")
	. Do refcntchk("g","4/2")
	. Write "... Setting new alias characteristics",!
	. Set h="6h"
	. Set *a=h
	. ZWrite
	. Do refcntchk("a","2/0")
	. Do refcntchk("g","3/2")
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("g","1/0")
	Quit

;
; txnew 7: Create container var in passed through var to point
;          to another passed through var - verify counts and
;	   pointer.
;
txnew7
	New
	Set a=1,b=2,c=3
	Set *g=a
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do refcntchk("g","2/0")
	Do
	. New (a,g,b)
	. ZWrite
	. Set *a(1)=b
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","2/0")
	Do refcntchk("b","2/1")
	Do refcntchk("c","1/0")
	Do refcntchk("g","2/0")
	Write "... Var a(1) ",$S($ZData(a(1))>99:"is",1:"(**FAIL**) IS NOT")," an alias container",!
	Quit

;
; txnew 8: Create container var in passed thru data to point
;          to data. Verify it gets copied.
;
txnew8
	New
	Set a=1,b=2,c=3
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do
	. New (a)
	. Set b="8b"
	. Set *a(1)=b
	. Do refcntchk("a","2/1")
	. Do refcntchk("b","2/1")
	. ZWrite
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Write "... pull data from container var into z",!
	Set *z=a(1)
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do refcntchk("z","2/1")
	Quit

;
; txnew 9: Create aliases and containers pointing to passed
;          thru data to confirm reference counts correct
;	   at exit.
;
txnew9
	New
	Set a=1,b=2,c=3
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do
	. New (b)
	. Set *k=b
	. Set *m(1)=b
	. Write "... Alias and alias container set to ""b""",!
	. ZWrite
	. Do refcntchk("b","4/2")
	. Do refcntchk("k","4/2")
	. Do refcntchk("m","1/0")
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Quit

;
; txnew 10: Pass an aliased var through an xnew then kill * it.
;
txnew10
	New
	Set a=42,*b=a
	Do refcntchk("a","2/0")
	Do refcntchk("b","2/0")
	Do
	. New (b)
	. Kill *b
	Write "Vars after xnew/kill* of b",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Write "Adding aliases",!
	; create an alias for each of a and b then get the reference counts again. If goes up
	; by more than 1, the two vars are still aliased which should NOT be true.
	Set *c=a,*d=b
	Do refcntchk("a","2/0")
	Do refcntchk("b","2/0")
	Do refcntchk("c","2/0")
	Do refcntchk("d","2/0")
	Quit

;
; txnew 11: Pass 2 aliased (to each other) vars through an xnew then kill * them.
;
txnew11
	New
	Set a=42,*b=a
	Do refcntchk("a","2/0")
	Do refcntchk("b","2/0")
	Do
	. New (a,b)
	. Kill *a,*b
	Write "Vars after xnew/kill* of a/b",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Write "Adding aliases",!
	; create an alias for each of a and b then get the reference counts again. If goes up
	; by more than 1, the two vars are still aliased which should NOT be true.
	Set *c=a,*d=b
	Do refcntchk("a","2/0")
	Do refcntchk("b","2/0")
	Do refcntchk("c","2/0")
	Do refcntchk("d","2/0")
	Quit

;
; txnew 12: Use container to create a var in a var not passed through xnew.
;
txnew12
	New
	Set a=1,b=2,*a(1)=b
	Do refcntchk("a","1/0")
	Do refcntchk("b","2/1")
	Do
	. New (a)
	. Set *z=a(1)
	. Set c=42
	. Set *z(1)=c
	. Kill *z
	. ZWrite
	. W "zap -----------",!
	. Set a(1)=11
	. Zwrite
	W "pop-------------",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Quit

;
; txnew 13: Set containers in passed through var to point to local vars then kill * var
;
txnew13
	New
	Set *a=c
	Do refcntchk("a","2/0")
	Do refcntchk("c","2/0")
	Do
	. New (a)
	. Set *a(1)=b,b=2
	. Set *a(2)=c,c=3
	. Kill *a
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("c","1/0")
	Quit

;
; txnew 14: Specify the passed through vars more than once
;
txnew14
	New
	Set a=1,b=2
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do
	. New (a,a,a)
	. ZWrite
	. Set *a=b
	. Set b=20,b(1)=21,b(2)=22
	. Write "... Popping xnew",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Quit

;
;txnew 15: Nested exclusive NEW tests
;
txnew15
	New
	Do txnew15a(1)	; Provides access to this test for txnew16 also
	Quit
txnew15a(io)
	Set a=1,b=2,*a(1)=a,*a(2)=b
	Do refcntchk("a","2/1")
	Do refcntchk("b","2/1")
	Do
	. New (a)
	. Do refcntchk("a","3/2")
	. Set b="lvl2",*a(3)=b
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","2/1")
	. Do
	. . New (a)
	. . Do refcntchk("a","4/3")
	. . Set b="lvl3",*a(4)=b
	. . Do refcntchk("a","4/3")
	. . Do refcntchk("b","2/1")
	Write:io "Values from nested vars:",!
	ZWrite:io
	Do refcntchk("a","2/1")
	Do refcntchk("b","2/1")
	Quit

;
; txnew 16: Memory leak test - run txnew15a thousands of times and verify our memory consumption
;           hasn't grown out of proportion.
txnew16
	New
	Set tstcnt=3000
	; First "prime the pump" so the extensions it needs to do happen. Then we make sure it
	; doesn't grow further.
	For i=1:1:tstcnt Do txnew15a(0)
	Set endmem=0,startmem=$ZREALSTOR
	For i=1:1:tstcnt*2 Do txnew15a(0)
	Set endmem=$ZREALSTOR
	If startmem'=endmem Write !!,"*** FAIL *** txnew16 memory consumption violation:  startmem: ",startmem,"  endmem: ",endmem,!!
	Quit

;
; txnew 17: Validate C9L04-003400 no longer occurs. Caused sig-11 in V5.4-002 and earlier.
;           Verify xnew cleanup runs correctly when vars KILL *'d with no other alias access.
;
txnew17
	New
        For i=1:1:3 Set a(i)=i
        Do txnew17rtn
	Write "ZWrite after return from txnew17rtn follows:",!
        ZWrite
        Quit
txnew17rtn
        New (a)
        Set a(4)=4
	Write "txnew17rtn: ZWrite just before KILL * follows:",!
        ZWrite
        Kill *
	Write "txnew17rtn: ZWrite just after KILL * follows:",!
        ZWrite
        Quit

;
; txnew 18: Similar to txnew 17 but goes an addition level of nesting.
;
txnew18
	New
        For i=1:1:3 Set a(i)=i
        Do txnew18rtnA
	Write "ZWrite after return from txnew18rtnA follows:",!
        ZWrite
        Quit
txnew18rtnA
        New (a)
        For i=4:1:6 Set a(i)=i*2
        ZWrite
	Write "txnew18rtnA: ZWrite just before call to txnew18rtnB follows:",!
	Do txnew18rtnB
	Write "txnew18rtnA: ZWrite just after call to txnew18rtnB follows:",!
	ZWrite
	Quit
txnew18rtnB
        New (a)
        For i=7:1:9 Set a(i)=i*3
        ZWrite
        Kill *
	Write "txnew18rtnB: ZWrite just after KILL * follows:",!
        ZWrite
        Quit

;
; txnew 19: Similar to txnew18 but with multiple vars (some passed thru, some not) and multi-level KILL *
;
txnew19
	New
        For i=1:1:2 Set a(i)=(i*1),aa(i)=(i*10),aaa(i)=(i*100)
        ZWrite
	Write "ZWrite before call to txnew19rtnA follows:",!
        Do txnew19rtnA
	Write "ZWrite after call to txnew19rtnA follows:",!
        ZWrite
        Quit
txnew19rtnA
        New (a,aa)
        For i=3:1:4 Set b(i)=(i*2),aa(i)=(i*10),bbb(i)=(i*100)
        ZWrite
	Write "txnew19rtnA: ZWrite just before call to txnew19rtnB follows:",!
	Do txnew19rtnB
	Write "txnew19rtnA: ZWrite just after call to txnew19rtnB and before KILL * follows:",!
	ZWrite
	Kill *
	Write "txnew19rtnA: ZWrite just after KILL * follows:",!
	ZWrite
	Quit
txnew19rtnB
        New (a,b)
        For i=5:1:6 Set a(i)=i*3
        For i=7:1:8 Set b(i)=i*4
	Write "txnew19rtnB: ZWrite just before KILL * follows:",!
	ZWrite
        Kill *
	Write "txnew19rtnB: ZWrite just after KILL * follows:",!
        ZWrite
        Quit

;
; txnew 20: Similar to txnew19 but adds aliases
;
txnew20
	New
        For i=1:1:2 Set a(i)=(i*1),aa(i)=(i*10),aaa(i)=(i*100)
	Write "ZWrite before call to txnew20rtnA follows:",!
        ZWrite
        Do txnew20rtnA
	Write "ZWrite after call to txnew20rtnA follows:",!
        ZWrite
        Quit
txnew20rtnA
        New (a,aa)
        For i=3:1:4 Set b(i)=(i*2),aa(i)=(i*10),bbb(i)=(i*100)
	Set *c=a
	Write "txnew20rtnA: ZWrite just before call to txnew20rtnB follows:",!
        ZWrite
	Do txnew20rtnB
	Write "txnew20rtnA: ZWrite just after call to txnew20rtnB and before KILL * follows:",!
	ZWrite
	Kill *
	Write "txnew20rtnA: ZWrite just after KILL * follows:",!
	ZWrite
	Quit
txnew20rtnB
        New (a,b)
        For i=5:1:6 Set a(i)=i*3
        For i=7:1:8 Set b(i)=i*4
	Write "txnew20rtnB: ZWrite just before KILL * follows:",!
	ZWrite
        Kill *
	Write "txnew20rtnB: ZWrite just after KILL * follows:",!
        ZWrite
        Quit

;
; txnew 21: xnew scenario where variable is inherited across xnew but recreated to a completely different variable.
;
txnew21
	New
        Set a=0,depth=0
        Do txnew21rtnA
        Do txnew21disp
        Quit
txnew21rtnA;
        New (a)
        Set depth=a+1,a=depth
        Do txnew21disp
        If (depth<2) Do txnew21rtnA Quit
        Set *a=g
        Do txnew21disp
        Quit
txnew21disp;
        Write !,"ZWRITE output at XNEW depth = ",depth,!
        Write "-----------------------------------------",!
        Zwrite
        Quit

;
; txtp 1: Test changes made to var inside nested TStart separated by xnew are restored
;      	  correctly.
;
txtp1
	New
	Write "Starting TP transaction",!
	Set a=1,b=2,c=3,*d=a,maxrestarts=2
	Do refcntchk("a","2/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do refcntchk("d","2/0")
	TStart *
	Write "------ Var settings just inside TSTART *",!
	ZWrite
	Do refcntchk("a","3/1")
	Do refcntchk("b","2/1")
	Do refcntchk("c","2/1")
	Do refcntchk("d","3/1")
	Set a=a+1,b=b+1,c=c+1,*e=b,*h(1)=b,*i=h(1)
	Write "---- Current var settings before XNEW:",!
	ZWrite
	Do refcntchk("a","3/1")
	Do refcntchk("b","5/2")
	Do refcntchk("c","2/1")
	Do refcntchk("d","3/1")
	Do refcntchk("e","5/2")
	Do refcntchk("h","2/1")
	Do refcntchk("i","5/2")
	Do
	. Write "---- Performing NEW",!
	. New (a,c,e,maxrestarts)
	. Do refcntchk("a","4/2")
	. Do refcntchk("c","3/2")
	. Do refcntchk("e","6/3")
	. TStart *
	. Set b=42,f=24,a=a+1
	. If $TRestart<maxrestarts Do
	. . Write "Values just prior to restart",!
	. . ZWrite
	. . Do refcntchk("a","4/2")
	. . Do refcntchk("b","2/1")
	. . Do refcntchk("c","3/2")
	. . Do refcntchk("f","2/1")
	. . Write "-- Restarting transaction NOW!",!
	. . TRestart
	. TCommit
	TCommit
	Write "****** Final values:",!
	ZWrite
	Do refcntchk("a","2/0")
	Do refcntchk("b","4/1")
	Do refcntchk("c","1/0")
	Do refcntchk("d","2/0")
	Do refcntchk("e","4/1")
	Do refcntchk("h","1/0")
	Do refcntchk("i","4/1")
	Quit

;
; txtp 2: Test changes made to vars inside nested TStarts separated by xnew - which is
;         not undone but must be unwound correctly during restarts.
;
txtp2
	New
	Write "Initial values set",!
	Set a=1,b=2,c=3,*d=a,*d(1)=a,maxrestarts=2
	Do refcntchk("a","3/1")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do refcntchk("d","3/1")
	Write "Starting TP transaction",!
	TStart *
	Write "Var settings just inside TSTART *",!
	ZWrite
	Do refcntchk("a","4/2")
	Do refcntchk("b","2/1")
	Do refcntchk("c","2/1")
	Do refcntchk("d","4/2")
	New d,j
	Set d=11,*j=d
	Set a=a+1,b=b+1,c=c+1,*e=b,*h(1)=b,*i=h(1)
	Write "Current var settings before XNEW:",!
	ZWrite
	Do refcntchk("a","4/2")
	Do refcntchk("b","5/2")
	Do refcntchk("c","2/1")
	Do refcntchk("d","2/0")
	Do refcntchk("e","5/2")
	Do refcntchk("h","2/1")
	Do refcntchk("i","5/2")
	Do refcntchk("j","2/0")
 	New (a,c,e,maxrestarts)
	Set zz=99,*zz(1)=c
	Do refcntchk("a","5/3")
	Do refcntchk("c","4/3")
	Do refcntchk("e","6/3")
	Do refcntchk("zz","1/0")
	TStart *
	Set b=42,f=24
	Do refcntchk("a","5/3")
	Do refcntchk("b","2/1")
	Do refcntchk("c","4/3")
	Do refcntchk("e","6/3")
	Do refcntchk("f","2/1")
	Do refcntchk("zz","2/1")
	Set *zz(2)=a,*a(1)=e,*a(2)=zz,*b(1)=zz,*b(2)=f,*b(3)=q,q=2222
	Write "Current var settings after XNEW/TSTART*:",!
	ZWrite
	Do refcntchk("a","6/4")
	Do refcntchk("b","2/1")
	Do refcntchk("c","5/4")
	Do refcntchk("e","7/4")
	Do refcntchk("f","3/2")
	Do refcntchk("q","3/2")
	Do refcntchk("zz","4/3")
	If $TRestart<maxrestarts Write "****** TRestart-ing NOW !!",!!
	TRestart:$TRestart<maxrestarts
	TRollback ($TLEVEL-1)
	TCommit
	Write !,"****** Final values:",!
	ZWrite
	Do refcntchk("a","4/2")
	Do refcntchk("b","1/0")
	Do refcntchk("c","3/2")
	Do refcntchk("e","6/3")
	Do refcntchk("f","2/1")
	Do refcntchk("q","2/1")
	Do refcntchk("zz","3/2")
	Quit

;
; txtp 3: For this test, check that var modified inside a nested tstart* that is passed
;      	  through an xnew and has containers modified to point to local data gets the
; 	  whole thing passed back when restarting while $TLEVEL=2. Vary the disposition
;	  of the internal and external TP transactions between commit and rollback.
;
txtp3
	New
	Do txtp3a(0,0)		; Rollback internal and external TP transactions
	Do txtp3a(0,1)		; Rollback internal, commit external
	Do txtp3a(1,0)		; Commit internal, rollback external
	Do txtp3a(1,1)		; Commit internal and external TP transactions
	Quit
txtp3a(cmt1,cmt2)
	New (cmt1,cmt2)
	Write "Start of txtp3a with parm values (",cmt1,",",cmt2,")",!
  	Set maxrestart1=1,maxrestart2=3
	Set a=1,z=2,*a(1)=z,*z(1)=y,y=3,c=0
	Set b=20
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","1/0")
	Do refcntchk("y","2/1")
	Do refcntchk("z","2/1")
	Kill *y,*z
	Do refcntchk("y","1/0")
	Do refcntchk("z","1/0")
	TStart *
	Write !,"------------- Starting values just inside first TStart *",!
	ZWrite
	Do refcntchk("a","2/1")
	Do refcntchk("b","2/1")
	Do refcntchk("c","2/1")
	Do refcntchk("y","2/1")
	Do refcntchk("z","2/1")
	;
	; Garbage collect to see what happens
	;
	Write !,"Recovering lv_vals",!
	Set x=$View("LV_GCOL")
	Write !,"Recovered lv_vals: ",x,!
	;
	Set z=21,y=22,*b(2)=z,*z(2)=y
	Kill *y,*z
	Do refcntchk("a","2/1")
	Do refcntchk("b","2/1")
	Do refcntchk("c","2/1")
	Do refcntchk("y","1/0")
	Do refcntchk("z","1/0")
	Set c=30
	Do
	. New (a,b,c,maxrestart1,maxrestart2,cmt1,cmt2)
	. Write !,"Exclusive NEW (passthru a,b,c,e,maxrestart1/2)",!
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","3/2")
	. Do refcntchk("c","3/2")
	. Set d=40,*d(3)=c,*c(3)=d
	. Write !,"Created d(3) container pointing to c and c(3) pointing to d",!
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","3/2")
	. Do refcntchk("c","4/3")
	. Do refcntchk("d","2/1")
	. TStart *
	. Write !,"Inner TSTART * fired up",!
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","3/2")
	. Do refcntchk("c","4/3")
	. Do refcntchk("d","3/2")
	. Set *z=a(1),*z(5)=d,*z(6)=c
	. Write !,"Created z(6) container pointing to c",!
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","3/2")
	. Do refcntchk("c","5/4")
	. Do refcntchk("d","4/3")
	. Do refcntchk("z","4/3")
	. Kill *z
	. If $TRestart<maxrestart1 Do
	. . Write !,"Values just before Restart #1 ($TLevel=",$TLevel,")",!
	. . ZWrite
	. . Write !,"Restart point #1 ocurring NOW!!",!
	. . TRestart
	. Write !,"Begin nested TP level ",$Select(cmt1:"commit",1:"rollback"),!
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","3/2")
	. Do refcntchk("c","5/4")
	. Do refcntchk("d","4/3")
	. Xecute $Select(cmt1:"TCommit",1:"TRollback -1")
	. Do refcntchk("a","3/2")
	. Do refcntchk("b","3/2")
	. Do refcntchk("c","5/4")
	. Do refcntchk("d","3/2")
	. Write !,"Nested TP ",$Select(cmt1:"committed",1:"rolled back"),!
	. ZWrite
	. If $TRestart<maxrestart2 Do
	. . Write !,"Values just before Restart #2 ($TLevel=",$TLevel,")",!
	. . ZWrite
	. . Write !,"Restart point #2 ocurring NOW!!",!
	. . TRestart
	;
	; Pop XNEW
	;
	Write !,"XNEW has been popped",!
	Do refcntchk("a","2/1")
	Do refcntchk("b","2/1")
	Do refcntchk("c","4/3")
	Write !,"Starting TP level ",$Select(cmt2:"commit",1:"rollback")," - before values:",!
	ZWrite
	Xecute $Select(cmt1:"TCommit",1:"TRollback -1")
	Write !,"Outer TP level",$Select(cmt2:"committed",1:"rolled back"),!
	Write:(0<$TLevel) "FAIL -- $TLEVEL should be zero but is ",$TLevel,!
	Write !,"-------- Final values:",!
	ZWrite
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","3/2")
	;
	; Garbage collect to see what happens
	;
	Write !,"Recovering lv_vals",!
	Set x=$View("LV_GCOL")
	Write !,"Recovered lv_vals: ",x,!
	;
	; Redo reference checks in case cleanup affected any counts
	;
	Do refcntchk("a","1/0")
	Do refcntchk("b","1/0")
	Do refcntchk("c","3/2")
	ZWrite
	Write !,"Exiting now",!
	Quit

;
; txtp 4: When XNEW happens in 2ndary stackframe (same rtn, diff location), it doesn't
;         give the stackframe its own l_symtab but an XNEW will create one. But our
;         unwinding for the TP restart will unwind the l_symtab too. Verify operation.
;
txtp4
	New
	Set a=1,b=2,c=3
	Do
	. TStart (a,b)
	. Write "---- View after TStart ----",!
	. ZWrite
	. Set a=10,b=20,c=30,d=40
	. New (b,c,d)
	. Set a=100,b=200,c=300,d=400
	. Write "---- View after XNEW ----",!
	. ZWrite
	. TRestart:$TRestart<2
	. TCommit
	. Write "---- Popping stack ----",!
	ZWrite
	Quit

;
; txtp 5: Similar test to txnew20 but also uses a TP wrapper and some restarts to test nested
;         xnews passing various things through along with a multi-level restart.
;
txtp5
	New
        For i=1:1:1 Set a(i)=(i*1),aa(i)=(i*10),*aa(2)=a,aaa(i)=(i*100),*aaa(2)=aa,*a(2)=aaa
	TStart (a,aa,aaa):Serial
	Write "ZWrite just after TSTART and before call to txtp5rtnA follows:",!
        ZWrite
        Do txtp5rtnA
	Write "ZWrite just after call to txtp5rtnA follows:",!
        ZWrite
	TCommit
        Quit
txtp5rtnA
        New (a,aa)
        For i=3:1:3 Set b(i)=(i*2),aa(i)=(i*10),bbb(i)=(i*100)
	Set *c=a
	Write "txtp5rtnA: ZWrite just before call to txtp5rtnB follows:",!
        ZWrite
	Do txtp5rtnB
	Write "txtp5rtnA: ZWrite just after call to txtp5rtnB and before KILL * follows:",!
	ZWrite
	Kill *
	Write "txtp5rtnA: ZWrite just after KILL * and just before potential TRESTART follows:",!
	ZWrite
	TRestart:($trestart<2)
	Write "txtp5rtnA: TRESTART bypassed",!
	Quit
txtp5rtnB
        New (a,b)
        For i=5:1:5 Set a(i)=i*3
        For i=7:1:7 Set b(i)=i*4
	Write "txtp5rtnB: ZWrite just before KILL * follows:",!
	ZWrite
        Kill *
	Write "txtp5rtnB: ZWrite just after KILL * and just before potential TRESTART follows:",!
        ZWrite
	TRestart:($trestart<1)
	Write "txtp5rtnB: TRESTART bypassed",!
        Quit

;
; Routine to check total and container reference counts and compare against expected.
;
refcntchk(var,refs)
	New rfs
	Set rfs=$View("LV_REF",var)_"/"_$View("LV_CREF",var)
	If rfs'=refs Write !,"*** FAIL *** ",$Stack($Stack(-1)-1,"PLACE"),": Var '",var,"' has refcnts ",rfs," but refcnts of ",refs," were expected",!
	Quit
