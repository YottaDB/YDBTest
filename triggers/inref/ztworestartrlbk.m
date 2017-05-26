;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ztworestartrlbk
	quit

; The below M program and the journal extract below tests 2 things
; 1. If a ZTWORMHOLE is referenced by a trigger in a multi-region TP transaction,
;    then TZTWORM/UZTWORM record is written in only one region (the one that gets
;    triggered first). In the below case, set ^a(2)=2 will invoke a trigger that
;    will write a TZTWORM in AREG and not in BREG although the update ^b(2) inside
;    the same transaction also invokes a trigger that references ZTWORMHOLE.
;
; 2. In case of a TRESTART, the ZTWORMHOLE is reset to a value that existed at
;    $TLEVEL=0 (incremental restarts are not supported) and will be used subsequently
ztwormrestart
	do ^echoline
	write "TEST 1: ZTWORMHOLE reference in a multi-region TP and TRESTARTS",!
	do ^echoline
	set $ztworm="ZTWORMHOLE_1"
	set ^a(1)=1	; Should write a TZTWORM record in a.mjl
	set ^b(1)=1	; Should write a TZTWORM record in b.mjl
	tstart ():serial
	set ^a(2)=2	; Should write a TZTWORM record (=ZTWORMHOLE_1)in a.mjl
	set ^b(2)=2	; Should NOT write a TZTWORM record in b.mjl
	set $ztworm="ZTWORMHOLE_2"
	set ^b(3)=3	; Should write a UZTWORM record (=ZTWORMHOLE_2)in b.mjl
	set ^a(3)=3	; Should NOT write a UZTWORM record in a.mjl
	; The trestart should ensure that $ZTWORM is reset to ZTWORMHOLE_1
	; and does NOT hold the last ZTWORM update ZTWORMHOLE_2
	if $trestart=0  trestart
	tcommit
	quit

; The below M program tests that in case of a TROLLBACK done inside a nested TP
; transaction, only the last updated value of $ZTWORM will be maintained. In the
; below case, the ^c(4) that happens after an unconditional trollback, will
; continue to use ZTWORMHOLE_THREE as the value of $ztworm.
ztwormrlbk	;
	do ^echoline
	write "TEST 2: ZTWORMHOLE and TROLLBACKS",!
	do ^echoline
	set $ztworm="ZTWORMHOLE_ONE"
	tstart ():serial
	set ^c(1)=1
	set $ztworm="ZTWORMHOLE_2"
	tstart ():serial
	set ^c(2)=2
	set $ztworm="ZTWORMHOLE_THREE"
	set ^c(3)=3
	trollback -1	; Since we have rolled back this transaction there will not be a corresponding tcommit
	set ^c(4)=4	; After the rollback above, ztworm should still be pointing to ZTWORMHOLE_THREE
	tcommit	 ; For the outermost tstart
	quit

setup
	do text^dollarztrigger("tfile^ztworestartrlbk","ztwormrestart.trg")
	do file^dollarztrigger("ztwormrestart.trg",1)
	quit

tfile
	;;Simple trigger definition that will cause ztwormhole records to be written in the journal files (replication is must)
	;+^a(acn=:) -commands=SET -xecute="set ^x(acn,$ztworm)=$ztval"
	;+^b(acn=:) -commands=SET -xecute="set ^y(acn,$ztworm)=$ztval"
	;+^c(acn=:) -commands=SET -xecute="set ^x(acn*10,$ztworm)=$ztval"
