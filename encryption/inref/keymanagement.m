;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script employed in the encryption/key_management test.
; It attempts simple device and database operations with the
; specified keys and IVs as provided by the driver script.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

keymanagement
	new INTERRUPTED,CASE,OPERATION,KEYNAME,ALTKEYNAME,IV
	set INTERRUPTED=0
	set $zinterrupt="set INTERRUPTED=1"
	set CASE=+$piece($zcmdline," ",1)
	set OPERATION=$piece($zcmdline," ",2)
	set KEYNAME=$piece($zcmdline," ",3)
	set ALTKEYNAME=$piece($zcmdline," ",4)
	set IV=$piece($zcmdline," ",5)
	do @("test"_CASE)
	quit

test1
test4
	new i
	do:("db"=OPERATION) db(KEYNAME)
	do:("device"=OPERATION) device(KEYNAME,IV)
	write "done",!
	for i=1:2 quit:INTERRUPTED  hang 0.5 if (i>=30) write "TEST-E-FAIL, Did not receive an interrupt in 30 seconds." zhalt 1
	do:("db"=OPERATION) db(ALTKEYNAME)
	do:("device"=OPERATION) device(ALTKEYNAME,IV)
	write "done2",!
	quit

test2
test5
	new i
	do:("db"=OPERATION) db(KEYNAME)
	do:("device"=OPERATION) device(KEYNAME,IV)
	write "done",!
	for i=1:2 quit:INTERRUPTED  hang 0.5 if (i>=30) write "TEST-E-FAIL, Did not receive an interrupt in 30 seconds." zhalt 1
	do:("db"=OPERATION) device(ALTKEYNAME,IV)
	do:("device"=OPERATION) db(ALTKEYNAME)
	write "done2",!
	quit

test3
	new i
	do:("db"=OPERATION) db(KEYNAME)
	do:("device"=OPERATION) device(KEYNAME,IV)
	write "done",!
	for i=1:2 quit:INTERRUPTED  hang 0.5 if (i>=30) write "TEST-E-FAIL, Did not receive an interrupt in 30 seconds." zhalt 1
	do:("db"=OPERATION) db(KEYNAME)
	do:("device"=OPERATION) device(KEYNAME,IV)
	write "done2",!
	quit

test6
	do:("db"=OPERATION) db(KEYNAME),device(KEYNAME,IV)
	do:("device"=OPERATION) device(KEYNAME,IV),db(KEYNAME)
	write "done",!
	quit

test7
test8
	write @("^"_KEYNAME)@(CASE),!
	write "done",!
	quit

test9
test10
	new i
	do db(KEYNAME)
	write "done",!
	for i=1:2 quit:INTERRUPTED  hang 0.5 if (i>=30) write "TEST-E-FAIL, Did not receive an interrupt in 30 seconds." zhalt 1
	do db(ALTKEYNAME)
	write "done2",!
	quit

db(global)
	set @("^"_global)@(CASE)=$horolog
	quit

device(keyname,iv)
	new device
	set device=$$^%RANDSTR(12,,"A")
	open device:(newversion:key=keyname_" "_iv)
	use device
	write $horolog,!
	close device
	quit
