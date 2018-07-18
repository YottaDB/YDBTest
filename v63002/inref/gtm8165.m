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
;

tpnotacid
	tstart ():(serial:transaction="BA")
	write "ATTEMPT ",$trestart,!
	write "CRITICAL RESOURCES=",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	if $trestart>2  do
	. set sock="gtm8165.socket"
	. open sock:(LISTEN="gtm8165sock.socket:LOCAL":attach="handle")::"SOCKET"
	. use sock:(detach="handle")
	. xecute $zcmdline
	. close sock
	if $trestart<=2  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	use $p
	write "POST TRANSACTION",!
	write "CRITICAL RESOURCES=",$$^%PEEKBYNAME("node_local.in_crit","DEFAULT"),!
	quit


