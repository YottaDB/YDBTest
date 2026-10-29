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
; $ETRAP and $ZTRAP code that does a TSTART and ends without TCOMMIT or TROLLBACK, for r208/trap_tstart_hang-ydb1332
;
; $gtm_dist/mumps -run ydb1332 <case> runs the label <case>
;
ydb1332	; variants: TSTART inside error trap code, no TCOMMIT
	write "== ",$zcmdline,! do @$zcmdline
	write "back at top $tlevel=",$tlevel," $ecode=",$ecode,!
	quit
a	; $ZTRAP code does TSTART and ends
	new $ztrap set $ztrap="tstart  write ""in ztrap"",!"
	do a1
	quit
a1	write 1/0
	quit
b	; $ETRAP code does TSTART and ends
	new $etrap set $etrap="tstart  write ""in etrap"",!"
	do b1
	write "after b1",!
	quit
b1	write 1/0
	quit
c	; $ETRAP code does TSTART and clears $ECODE
	new $etrap set $etrap="tstart  write ""in etrap"",! set $ecode="""""
	do b1
	write "after b1 $tlevel=",$tlevel,!
	quit
d	; plain routine: TSTART then QUIT with an outer $ETRAP
	new $etrap set $etrap="write ""etrap: "",$zstatus,! set $ecode="""" trollback"
	do d1
	write "after d1 $tlevel=",$tlevel,!
	quit
d1	tstart  quit
e	; plain routine: TSTART then QUIT, outer $ETRAP does not end the transaction
	new $etrap set $etrap="write ""etrap: "",$zstatus,! set $ecode="""""
	do d1
	write "after d1 $tlevel=",$tlevel,!
	trollback:$tlevel
	quit
f	; TSTART then error, outer $ETRAP does not end the transaction
	new $etrap set $etrap="write ""etrap: "",$zstatus,! set $ecode="""""
	do f1
	write "after f1 $tlevel=",$tlevel,!
	trollback:$tlevel
	quit
f1	tstart  write 1/0
	quit
g	; TSTART outside the trap, trap code itself errors; the outer transaction must survive to the outer handler
	new $etrap set $etrap="write ""outer etrap $tlevel="",$tlevel,! set $ecode="""" trollback:$tlevel"
	do g1
	write "after g1 $tlevel=",$tlevel,!
	quit
g1	new $etrap set $etrap="write ""inner etrap $tlevel="",$tlevel,! write 2/0"
	tstart  set ^g=1 write 1/0
	quit
h	; trap code does its own TSTART and TCOMMIT
	new $etrap set $etrap="tstart  set ^h=$get(^h)+1 tcommit  write ""in etrap $tlevel="",$tlevel,! set $ecode="""""
	do b1
	write "after b1 $tlevel=",$tlevel," ^h=",^h,!
	quit
i	; transaction started outside, error inside, $ZTRAP handles and continues with the transaction
	set ^i=0
	tstart
	new $ztrap set $ztrap="goto i2"
	set ^i=1 write 1/0
	quit
i2	write "in i2 $tlevel=",$tlevel,! tcommit  write "after tcommit ^i=",^i,!
	quit
