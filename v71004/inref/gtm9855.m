;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm9855 ;
	new text
	write "# Job child which will have a connecting LOCAL socket, parent will have a listening LOCAL socket",!
	set ^stop=0
	set jmaxwait=0  ; do not wait for child process to finish in "do ^job" invocation below
	do ^job("child^gtm9855",1,"""""")

	set s="socket"
	open s:::"SOCKET"
	open s:(LISTEN="socket1:LOCAL":ATTACH="handle1")::"SOCKET"      ; open a listening socket
	write "# Do READ * on the child process, but timeout before any data is received to force a READ failure",!
	use s
	write /wait     ; when this command returns, a connection has been accepted
	read *result:0.001,!
	set test=$TEST
	close s
	set ^stop=1

	use $principal
	write "# Check the result of READ *. Expect -1. Previously, 0 would be issued.",!
	write "# Result: "_result_" ($TEST: "_test_")",!
	do wait^job     ; wait for child process to die before returning to caller
	quit

child   ;
	set s="socket"
	open s:::"SOCKET"
	open s:(CONNECT="socket1:LOCAL")::"SOCKET"
	use s
	for  quit:^stop=1  hang 0.01
	write "Child process pid = ",$j,!
	quit
