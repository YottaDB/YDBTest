;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2008, 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mtom
	; test to demonstrate communication with another GTM process over a pipe device
	set p="test"
	; Added $ydb_dist here due to Alpine not being otherwise able to find the command as Alpine does this
	; invocation differently. ##ALPINE_TODO##
	open p:(comm="$ydb_dist/mumps -dir")::"pipe"
	zsystem "sleep 1; ps -ef | grep mumps | grep -v grep | grep $user > mtom.log"
	use p:exception="G PROB"
	; read newline
	read x
	; read YDB> without newline
	read x#4
	use $p
	write x,!
	use p
	write "set x=1",!
	; read 2 newlines
	read x,x
	; read YDB> without newline
	read x#4
	use $p
	write x,!
	use p
	write "write x,!",!
	; read newline
	read x
	use $p
	write x,!
	use p
	; read "1"
	read x
	use $p
	write x,!
	use p
	; read newline
	read x
	use p
	; read YDB> without newline
	read x#4
	use $p
	write x,!
	use p
	write "write ""hello"",!",!
	; read newline
	read x
	; read "hello"
	read x
	use $p
	write x,!
	use p
	write "halt",!
	zsystem "ps -ef | grep mumps | grep -v grep | grep $user > mtom2.log"
	close p
	quit

PROB
	set d=$device
	set z=$zstatus
	use $p
	write "device= "_d_", zstatus= "_z,!
	zsystem "ps -ef | grep mumps | grep -v grep | grep $user > mtom2.log"
	quit

