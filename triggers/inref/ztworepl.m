;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Each test case places it's comment in GVNs so that they show up in
	; the journal logs
ztworepl
	write "Testing ZTWOrmhole with replication",!
	set default="abcd"
	set alt="efgh"
	set same="abcd"
	set null=""
	set ztwo=";$ztwo="
	tstart ()
	do item^dollarztrigger("tfile^ztworepl","ztworepl.trg.trigout")
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO with implicit transactions"
	set (^atest,^btest)=tcase
	set $ztwormhole=default
        set ^a1(rnd+1)="a"_ztwo_default	; trigger references ZTWO. jnl has ztworm records
        set ^b2(1)="b"_ztwo_default	; trigger DOESN'T reference ZTWO. jnl has NO ztworm records
	set tcase="Test ("_rnd_") ZTWO with implicit transactions - switch ztwo to ALT"
	set (^atest,^btest)=tcase
	set $ztwormhole=alt
	ztrigger ^aztr(ztwo_alt)	; trigger references ZTWO. jnl has ztworm records
	kill ^a1(rnd+1)			; trigger references ZTWO. jnl has ztworm records
	kill ^b2(1)			; trigger DOESN'T reference ZTWO. jnl has NO ztworm records
	kill ^atest,^btest
	set $ztwormhole=null
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") null ZTWO with implicit transactions - shouldn't see ztwo"
	set (^atest,^btest)=tcase
	set $ztwormhole=null
        set ^a1(rnd+1)="c"_ztwo_null
        set ^b2(1)="d"_ztwo_null	; trigger DOESN'T reference ZTWO
	ztrigger ^aztr(ztwo_null)
	kill ^a1(rnd+1)
	kill ^b2(1)			; trigger DOESN'T reference ZTWO
	kill ^atest,^btest
	set $ztwormhole=null
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") null ZTWO with explicit transaction"
	set $ztwormhole=null
	tstart ():serial
	set (^atest,^btest)=tcase
	set ^b2(1)="e"_ztwo_null
	set ^a1(rnd+1)="f"_ztwo_null
	set $ztwormhole=null
	set ^a1(rnd+2)="g"_ztwo_null
        set ^a1(rnd+3)="h"_ztwo_null
	ztrigger ^aztr(ztwo_null)
	kill ^atest,^btest
	tcommit
	set $ztwormhole=null
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set inside explicit transaction after non-referencing update"
	tstart ():serial
	set (^atest,^btest)=tcase
	set ^b2(rnd+1)="e"_ztwo_default
	set $ztwormhole=default		; expect ztworm at the beginning of the TP
	set ^a1(rnd+1)="f"_ztwo_default
	set ^a1(rnd+2)="g"_ztwo_default
        set ^a1(rnd+3)="h"_ztwo_default
	ztrigger ^aztr(ztwo_default)
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set inside explicit transaction after referencing update"
	tstart ():serial
	set (^atest,^btest)=tcase
	ztrigger ^aztr(ztwo_null) ; trigger references null ZTWO
	set ^b2(1)="e"
	set $ztwormhole=default	; expect ztworm in the middle of the TP
	set ^a1(rnd+1)="f"_ztwo_default
	set ^a1(rnd+2)="g"_ztwo_default
        set ^a1(rnd+3)="h"_ztwo_default
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set at the start of explicit transaction"
	tstart ():serial
	set (^atest,^btest)=tcase
	set $ztwormhole=default
	set ^a1(rnd+1)="f"_ztwo_default
	set ^a1(rnd+2)="g"_ztwo_default
        set ^a1(rnd+3)="h"_ztwo_default
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set before explicit transaction"
	set $ztwormhole=default
	tstart ():serial
	set (^atest,^btest)=tcase
	set ^a1(rnd+1)="f"_ztwo_default
	set ^a1(rnd+2)="g"_ztwo_default
        set ^a1(rnd+3)="h"_ztwo_default
	ztrigger ^aztr(ztwo_default)
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set before explicit transaction"
	set tcase=tcase_" and changed inside the transaction"
	set (^atest,^btest)=tcase
	set $ztwormhole=default
	tstart ():serial
	set ^b2(rnd+1)="e"_ztwo_default
	set ^a1(rnd+1)="f"_ztwo_default
	set ^a1(rnd+2)="g"_ztwo_default
	ztrigger ^aztr(ztwo_default)
	set $ztwormhole=alt
	set ^b2(rnd+3)="e"_ztwo_alt
        set ^a1(rnd+3)="h"_ztwo_alt
	ztrigger ^aztr(ztwo_alt)
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set before explicit transaction"
	set tcase=tcase_" and changed inside the transaction"
	set $ztwormhole=default
	tstart ():serial
	set (^atest,^btest)=tcase
	set ^a1(rnd+1)="e"_ztwo_default
	set ^a1(rnd+2)="f"_ztwo_default
	set $ztwormhole=alt
        set ^a1(rnd+3)="g"_ztwo_alt
        set ^a1(rnd+4)="h"_ztwo_alt
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	;--------------------------------------
	; vvvvvvvvvvvvvvvvvvvvvvvv Karthik, use just this test case vvvvvvvvvvvvvvvvvvvvvvvv
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set at start of explicit transaction"
	set tcase=tcase_" and changed to NULL inside the transaction"
	set tcase=tcase_" with intervening trigger references to ztwo"
	set tcase=tcase_" and restored to the original inside the transaction"
	tstart ():serial
	set $ztwormhole=default
	set (^atest,^btest)=tcase
	ztrigger ^aztr(ztwo_default)
	set ^a1(rnd+1)="f"_ztwo_default
	set ^a1(rnd+2)="g"_ztwo_default
	set $ztwormhole=null
        set ^a1(rnd+3)="h"_ztwo_null
	ztrigger ^aztr(ztwo_null)
	set $ztwormhole=default
	ztrigger ^aztr(ztwo_default)
        set ^a1(rnd+4)="h"_ztwo_default
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	; ^^^^^^^^^^^^^^^^^^^^^^^^ Karthik, use just this test case ^^^^^^^^^^^^^^^^^^^^^^^^
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set before several implicit transactions"
	set $ztwormhole=default
	set (^atest,^btest)=tcase
	set ^b2(1)=1,^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4
	;
	set tcase="Test ("_rnd_") ZTWO set to same value as prior implicit transactions"
	set tcase=tcase_" in an explicit transaction"
	tstart ():serial
	set (^atest,^btest)=tcase
	kill ^b2(1)
	kill ^a1(rnd+1)
	set $ztwormhole=default ; This should not generate an extra ZTWO entry
	kill ^a1(rnd+2)
        kill ^a1(rnd+3)
	ztrigger ^aztr(ztwo_default)
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set before several implicit transactions"
	set (^atest,^btest)=tcase
	set $ztwormhole=default
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4
	set tcase="Test ("_rnd_") ZTWO set to alt value as prior implicit transactions"
	set tcase=tcase_" in an explicit transaction"
	tstart ():serial
	set (^atest,^btest)=tcase
	ztrigger ^aztr(ztwo_default)
	set $ztwormhole=alt		; should create another ZTWO jnl rec
	kill ^a1(rnd+1)
	kill ^a1(rnd+2)
        kill ^a1(rnd+3)
	ztrigger ^aztr(ztwo_alt)
	tcommit
	set tcase="Test ("_rnd_") ZTWO unchanged for a new implicit transaction"
	set (^atest,^btest)=tcase
	ztrigger ^aztr(ztwo_alt)	; should not create another ZTWO jnl rec
	kill ^atest,^btest
	set $ztwormhole=null
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO with implicit & explicit transactions."
	set tcase=tcase_" We expect ZTWO in only the first transaction"
	set (^atest,^btest)=tcase
	set $ztwormhole=default
	ztrigger ^aztr(ztwo_default)
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4
	set (^atest,^btest)=tcase
	tstart ():serial
	ztrigger ^aztr(ztwo_default)
	kill ^a1(rnd+1)
	kill ^a1(rnd+2)
        kill ^a1(rnd+3)
	kill ^atest,^btest
	set $ztwormhole=null
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set before (im/ex)plicit transaction"
	set tcase=tcase_" and (im/ex)plicitly changed inside the explicit transaction"
	set tcase=tcase_" which includes a non ZTWO referencing zkill"
	set (^atest,^btest)=tcase
	set $ztwormhole=default		; jnl rec for 1st implicit transaction
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4,^a1(rnd+4)=5
	tstart ():serial
	kill ^a1(rnd+1)
	ztrigger ^aztrSET		; jnl rec in the middle of transaction
	kill ^a1(rnd+2)
	set $ztwormhole=alt		; jnl rec in the middle of transaction
        kill ^a1(rnd+3)
        zkill ^a1(rnd+4)
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO changed between (im/ex)plicit transaction"
	set tcase=tcase_" and changed to NULL inside the implicit transaction"
	set tcase=tcase_" with intervening trigger references to ztwo"
	set tcase=tcase_" and changed to non-NULL inside the transaction"
	set (^atest,^btest)=tcase
	set $ztwormhole=default
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4,^a1(rnd+4)=5
	ztrigger ^aztr(ztwo_default)
	tstart ():serial
	kill ^a1(rnd+1)
	kill ^a1(rnd+2)
	ztrigger ^aztrNULL
        kill ^a1(rnd+3)
	ztrigger ^aztr(ztwo_null)
	set $ztwormhole=default
        kill ^a1(rnd+4)
	ztrigger ^aztr(ztwo_default)
	ztrigger ^aztrSET		; jnl rec in the middle of transaction
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") same as before, but ZTWO should not change"
	set tcase=tcase_" after being set to NULL"
	set (^atest,^btest)=tcase
	ztrigger ^aztr(ztwo_default)
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4,^a2(4)=5	; intentionally set ^a2(4) so ^a1(rnd+4) is undefined when it is killed
	set $ztwormhole=default
	tstart ():serial
	kill ^a1(rnd+1)
	zkill ^a1(rnd+2)
	ztrigger ^aztr(ztwo_default)
	set $ztwormhole=null
        kill ^a1(rnd+3)
	ztrigger ^aztr(ztwo_null)
	set $ztwormhole=default
        kill ^a1(rnd+4)		; should NOT generate any ZTWORMHOLE record since NO KILL record is even generated
	ztrigger ^aztr(ztwo_default)
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set to null should not show up at all"
	set tcase=tcase_" even after changing inside the transaction"
	set (^atest,^btest)=tcase
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4,^a2(4)=5
	set $ztwormhole=null
	tstart ():serial
	ztrigger ^aztr(ztwo_null)
	zkill ^a1(rnd+1)
	kill ^a1(rnd+2)
	set $ztwormhole=null
        kill ^a1(rnd+3)
	ztrigger ^aztr(ztwo_null)
	set $ztwormhole=default
        kill ^a1(rnd+4)		; should NOT generate any ZTWORMHOLE record since NO KILL record is even generated
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_")"
	set (^atest,^btest)=tcase
	set ^a1(rnd+1)=2,^a1(rnd+2)=3,^a1(rnd+3)=4,^a2(4)=5	; intentionally set ^a2(4) so ^a1(rnd+4) is undefined when it is killed
	set $ztwormhole=default
	tstart ():serial
	set (^atest,^btest)=tcase_"begin explicit updates;$ztwo=abcd"
	zkill ^a1(rnd+1)
	kill ^a1(rnd+2)
	set $ztwormhole=null
	ztrigger ^aztr(ztwo_null)
	set (^atest,^btest)=tcase_"inside explicit updates;$ztwo="
        kill ^a1(rnd+3)
	set $ztwormhole=default
	set (^atest,^btest)=tcase_"last explicit updates;$ztwo=abcd"
        kill ^a1(rnd+4)		; should NOT generate any ZTWORMHOLE record since NO KILL record is even generated
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	set tcase="Test ("_$increment(rnd,10)_") ZTWO set to $char(0) and changed during an explicit transaction"
	set (^atest,^btest)=tcase
	set $ztwormhole=$char(0)
	tstart ():serial
	ztrigger ^bstart
	set ^b2(rnd+1)="e"_ztwo_"$char(0)"
	set ^a1(rnd+1)="f"_"$char(0)"
	ztrigger ^aztr(ztwo_"$char(0)")
	set $ztwormhole=default
	set ^a1(rnd+2)="g"_ztwo_default
        set ^a1(rnd+3)="h"_ztwo_default
	ztrigger ^aztr(ztwo_default)
	ztrigger ^bstop
	kill ^atest,^btest
	tcommit
	;--------------------------------------
	do ^echoline
	; Test empty and non-empty string value of $ZTWORMHOLE. Hence the for loop below.
	for ztwormval="abcd","" do
	. set tcase="Test ("_$increment(rnd,10)_") YDB#727 : Test $ZTWORMHOLE set to "_$zwrite(ztwormval)
	. set ^atest=tcase
	. set $ztwormhole=ztwormval set ^ydb727=tcase
	. set $ztwormhole=ztwormval kill ^ydb727
	. set $ztwormhole=ztwormval set ^ydb727=tcase
	. set $ztwormhole=ztwormval zkill ^ydb727
	. set $ztwormhole=ztwormval ztrigger ^ydb727
	quit

	;-------------------------------------------------------
	; trigger routines
ztworepltrig(touchztwo)
	if touchztwo set x=$ztwormhole
	quit

ydb727
	new isprimary
	set isprimary=($ztrnlnm("PWD")=$ztrnlnm("tst_working_dir"))
	if isprimary do
	. ; Set $ZTWORMHOLE only on the primary side. Use it on the secondary side
	. set $ztwormhole="dummy"	; set a dummy value for $ZTWORMHOLE first
	. set $ztwormhole=$zut		; set real value for $ZTWORMHOLE to make sure this set prevails over previous dummy set
	set ^ydb727insidetrig($increment(^ydb727insidetrig))=$ztwormhole
	quit

tfile
	;+^a1(:)    -commands=SET,KILL            -xecute="do ztworepltrig^ztworepl(1)"
	;+^b2(:)    -commands=SET,KILL            -xecute="do ztworepltrig^ztworepl(0)"
	;+^aztr(:)  -commands=ZTR                 -xecute="do ztworepltrig^ztworepl(1)"
	;+^aztrNULL -commands=ZTR                 -xecute="set $ztwormhole="""""
	;+^aztrSET  -commands=ZTR                 -xecute="set $ztwormhole=""ZTRIGGER"""
	;+^bstart   -commands=ZTR                 -xecute="set x=1"
	;+^bstop    -commands=ZTR                 -xecute="set x=0"
	;+^ydb727   -commands=SET,KILL,ZKILL,ZTR  -xecute="do ydb727^ztworepl"
