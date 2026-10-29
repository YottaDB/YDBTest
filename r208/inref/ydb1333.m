;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; $ZTEXIT cases for r208/ztexit_tp_exit-ydb1333
;
ydb1333
	quit

ztexithalt	; HALT with $ZTEXIT true and a transaction active
	set $ztexit=1
	tstart ()
	halt

ztexitlock	; Same, while holding a LOCK
	lock ^ydb1333
	set $ztexit=1
	tstart ()
	halt

ztexitrollback	; TROLLBACK with $ZTEXIT true, without exiting. $ZINTERRUPT runs after the TROLLBACK.
	set $ztexit=1,$zinterrupt="write ""$ZINTERRUPT ran, $tlevel="",$tlevel,!"
	tstart ()
	trollback
	write "after TROLLBACK $tlevel=",$tlevel,!
	quit

ztexitcommit	; TCOMMIT with $ZTEXIT true, without exiting. $ZINTERRUPT runs after the TCOMMIT.
	set $ztexit=1,$zinterrupt="write ""$ZINTERRUPT ran, $tlevel="",$tlevel,!"
	tstart ()
	set ^ydb1333commit=1
	tcommit
	write "after TCOMMIT $tlevel=",$tlevel," ^ydb1333commit=",^ydb1333commit,!
	quit

attach	; Stay attached to the database until ^ydb1333done is set, so that the lock space outlives the exit of the
	; process that holds the LOCK. Gives up after 5 minutes so that the subtest cannot hang.
	new i
	set ^ydb1333pid=$job
	for i=1:1:3000 quit:$get(^ydb1333done)  hang 0.1
	quit

waitattach	; Wait until "attach" has the database open, then write its pid
	new i
	for i=1:1:600 quit:$get(^ydb1333pid)  hang 0.1
	write $get(^ydb1333pid),!
	quit
