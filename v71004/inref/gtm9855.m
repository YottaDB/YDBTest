;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm9855 ;
	new s,result,test,za
	write "# Job a child process that connects to a LOCAL socket on which the parent listens",!
	set s="socket"
	open s:(LISTEN="socket1:LOCAL":ATTACH="handle1")::"SOCKET"
	set jmaxwait=0  ; do not wait for child process to finish in "do ^job" invocation below
	do ^job("child^gtm9855",1,"""""")
	use s
	write /wait     ; when this command returns, a connection has been accepted
	use $principal
	write !,"# Case 1: READ * times out before the child sends anything",!
	use s
	read *result:0
	set test=$test
	use $principal
	write "# Expect READ * to return -1, as before, with $TEST=0",!
	write "# Result: "_result_" ($TEST: "_test_")",!
	write !,"# Case 2: The child closes its end of the connection, so READ * fails",!
	use s
	write "x"       ; tell the child to close its end
	read *result:60
	set test=$test,za=$za
	close s
	use $principal
	write "# Expect READ * to return -1 (previously 0), with $TEST=1 and $ZA=9",!
	write "# Result: "_result_" ($TEST: "_test_", $ZA: "_za_")",!
	do wait^job     ; wait for child process to die before returning to caller
	quit

child   ;
	new s,x
	set s="socket"
	open s:(CONNECT="socket1:LOCAL")::"SOCKET"
	use s
	read *x:60      ; wait for the parent to send a character
	close s
	quit
