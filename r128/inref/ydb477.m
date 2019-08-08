;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Verify NEW $TEST works
;
ydb477
	set errors=0
	if 1		; Set $TEST to TRUE
	do settestfalse
	if '$test do
	. write "Test fail at ",$zposition," with $TEST being FALSE when it should be TRUE",!
	. set errors=errors+1
	if 0		; Set $TEST to FALSE
	do settesttrue
	if $test do
	. write "Test fail at ",$zposition," with $TEST being TRUE when it should be FALSE",!
	. set errors=errors+1
	if 0=errors write "PASS",!
	else  write "FAIL",!
	quit

;
; Routine that is entered with $TEST true, saves it, then sets it to false and returns
;
settestfalse
	new $test
	if 0		; Set $TEST FALSE
	quit		; Now see if it pops and becomes true again


;
; Routine that is entered with $TEST false, saves it, then sets it to true and returns
;
settesttrue
	new $test
	if 1		; Set $TEST TRUE
	quit		; Now see if it pops and becomes true false
