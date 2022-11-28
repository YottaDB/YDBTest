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
; Helper M program used by r136/u_inref/ydb956.csh
;

ydb956	;
	quit

test1	;
	; See ydb956.csh (caller) for purpose of this test
	;
	write "; List all regions in current gld. Expect only 1 region (DEFAULT) to show up",!
	do reglist
	write "; Run ZSYSTEM to do [cp 2reg.gld mumps.gld]",!
	zsystem "cp 2reg.gld mumps.gld"
	write "; Run VIEW GBLDIRLOAD:$zgbldir to reload the 2-region mumps.gld",!
	view "GBLDIRLOAD":$zgbldir
	write "; List all regions again in current gld. Expect 2 regions (DEFAULT and AREG) to show up",!
	do reglist
	quit

reglist	;
	new reg
	set reg="" for  set reg=$view("GVNEXT",reg)  quit:reg=""  write "  ",reg,!
	quit

test2	;
	; See ydb956.csh (caller) for purpose of this test
	;
	write "; Switch to 1reg.gld as $ZGBLDIR temporarily"
	set $zgbldir="1reg.gld"
	write "; Run VIEW ""GBLDIRLOAD"":""""",!
	view "gbldirload":""
	write "; Run ZWRITE $ZGBLDIR. Expect mumps.gld (default gbldir due to gtmgbldir env var) to show up",!
	write "  " zwrite $ZGBLDIR
	quit

test3	;
	; See ydb956.csh (caller) for purpose of this test
	;
	set $etrap="do etr"
	view "GBLDIRLOAD":"mumps.dat"
	quit

etr	;
	write "; Verify with $ZSTATUS that a GDINVALID error was issued",!
	write "  " zwrite $zstatus
	write "; Value of $ZGBLDIR from inside error trap. Expecting it to be unaffected [i.e. mumps.gld]",!
	write "  " zwrite $ZGBLDIR
	quit

