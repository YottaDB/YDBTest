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
; GVPUTFAIL regression test  7/9/93
;
; Requirements:
; These tests (putfail1 - putfail8) require the block size to be 2048 and the
; record size must be at least 1900.
;
; This test sets a global variable to larger and larger string values, until
; it becomes too large for the block to contain.  It should result in
; a %YDB-E-REC2BIG error.
;
putfail5
	New (errcnt)
	New $ZTRAP

	Kill ^PF
	Set X="1234567890"
	Set X100=X_X_X_X_X_X_X_X_X_X
	Set X300=X100_X100_X100
	Set X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	Set X5000=X1000_X1000_X1000_X1000_X1000
	Set $ZTRAP="Do err   Quit"
	For i=1:1:5000 Set ^PF=X1000_$EXTRACT(X5000,0,i)
	Halt

err
	If $PIECE($ZSTATUS,",",3)="%YDB-E-REC2BIG" Write "   PASS - putfail5",!
	Else  Write "Maximum record length:  ",i+999,!,"** FAIL - putfail5: ",$ZSTATUS,!  Set errcnt=errcnt+1
	Quit
