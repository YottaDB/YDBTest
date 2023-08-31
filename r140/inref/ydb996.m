;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Helper M program used by r140/u_inref/ydb996.csh

	write "# -----------------------",!
	write "# Test passing a LISTENing TCP socket to a child through a LOCAL socket works",!
	write "# -----------------------",!
	set portno=$ztrnlnm("portno")
	set s="socket"
	write "# Open LISTENING TCP socket and give it a name [handle1]",!
	open s:(listen=portno_":TCP":attach="handle1")::"SOCKET"	; open LISTENING socket that will be later passed
	write "# Move LISTENING TCP socket [handle1] to socketpool device",!
	use s:(detach="handle1")					; move listening socket to "socketpool" device
	use $principal
	write "# JOB off child to pass the LISTENING TCP socket",!
	job child							; job off child to pass the listening socket
	set childpid=$zjob
	write "# Open new LISTENING LOCAL socket file named [socket2] and give it a handle name [handle2]",!
	open s:(LISTEN="socket2:LOCAL":ATTACH="handle2")::"SOCKET"	; create a new listening socket "socket2"
	write "# Wait for connection from child on socket [socket2]",!
	use s
	write /wait							; establish a connection with child on "socket2"
	use $principal write "# Pass the LISTENING TCP socket through [socket2]",! use s
	write /pass(,,"handle1")					; pass the listening "socket1" socket through "socket2"
									; now child owns the "socket1" listening socket
	use $principal
	write "# Connect to LISTENING TCP socket that has been passed to child",!
	open s:(CONNECT="[127.0.0.1]:"_portno_":TCP":attach="client1")::"SOCKET"	; connect to listening "socket1" on child
	write "# Read data writen by child process from the connected TCP socket",!
	use s:(delimiter=$c(10))
	for  read cmdop($incr(i))  quit:$device 	; read data written by child from the socket
	use $principal
	write "# Display data, written by child, in the parent process",!
	write "# Expect to see 5 lines of data and an empty 6th line",!
	zwrite cmdop					; display data written by child in parent
	write "# Wait for child pid to terminate before returning from parent",!
	do ^waitforproctodie(childpid)
	;
	write "# -----------------------",!
	write "# Test passing a LISTENing TCP socket to a child through JOB command STDIN issues SOCKNAMERR error",!
	write "# Before YDB@99c64bd4, this used to cause a SIG-11 in the child process created by the JOB command",!
	write "# -----------------------",!
        set s="socket"
        ; open a listening socket
        open s:(listen=portno_":TCP":attach="handle1"):15:"socket"
        ; move listening socket to "socketpool" device
        use s:(detach="handle1")
        ; job a child and make it inherit the listening socket as its stdin/stdout
        job child2:(INPUT="SOCKET:handle1":OUTPUT="SOCKET:handle1":ERROR="child2.mje")
        quit

child	;
	set s="socket"					; create a SOCKET device in child
	open s:(CONNECT="socket2:LOCAL")::"SOCKET"	; connect to "socket2" listening socket in parent
	use s
	; The below "write /accept" is where one used to previously see a %YDB-E-GETSOCKNAMERR error (before YDB#996 was fixed)
	write /accept(.handle,,,)			; accept the listening "socket1" socket from parent
	use s:(attach=handle)
	write /wait					; wait for a connection from parent to come on "socket1" listening socket
	use s:(delimiter=$c(10))			; set delimiters explicitly since they are not inherited in passed sockets
	; Write to this socket some data that will be read (and displayed) by the parent
	for i=1:1:5  write "This is the child writing Line ",i," out of 5 lines",!
	quit

child2	;
	quit

