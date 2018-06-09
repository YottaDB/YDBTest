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

	quit

socketJobPassListening
	;
	write "# Passing a LISTENing socket to a child through JOB command.",!
	write "# Expecting data below that child wrote and was read through the parent process socket",!
	; Both STDIN and STDOUT are passed to the child (through INPUT and OUTPUT jobparameters)."
	;
	set s="socket"
	open s:::"SOCKET"	; create a SOCKET device
	open s:(LISTEN="socket1:LOCAL":ATTACH="handle1")::"SOCKET"	; create a listening socket
	use s:(detach="handle1")					; move listening socket to "socketpool" device
	job childJob:(INPUT="SOCKET:handle1":OUTPUT="SOCKET:handle1")	; job a child and make it inherit
									;	the listening socket as its stdin/stdout
	open s:(CONNECT="socket1:LOCAL":DELIMITER=$c(10))::"SOCKET"	; connect to listening socket that child inherited
	use s
	for  read cmdop($incr(i))  quit:$device 	; read data written by child from the socket
	use $principal
	zwrite cmdop					; display data written by child in parent
	quit
childJob;
	; Establish a CONNECTION in the listening socket passed in as $principal
	write /wait
	; Write to this socket some data that will be read (and displayed) by the parent
	for i=1:1:2  write "socketJobPassListening : This is the child writing Line ",i," out of 2 lines",!
	quit

socketLocalPassListening
	;
	write "# Passing a LISTENing socket to a child through a LOCAL socket.",!
	write "# Expecting data below that child wrote and was read through the parent process socket",!
	; Passing a LISTENing socket to a child through a LOCAL socket
	;
	set s="socket"
	open s:::"SOCKET"	; create a SOCKET device in parent
	open s:(LISTEN="socket1:LOCAL":ATTACH="handle1")::"SOCKET"	; create a listening socket "socket1"
	use s:(detach="handle1")					; move listening socket to "socketpool" device
	job childLocal							; job off child to pass the listening socket
	open s:(LISTEN="socket2:LOCAL":ATTACH="handle2")::"SOCKET"	; create a new listening socket "socket2"
	use s
	write /wait							; establish a connection with child on "socket2"
	write /pass(,,"handle1")					; pass the listening "socket1" socket through "socket2"
									; now child owns the "socket1" listening socket
	open s:(CONNECT="socket1:LOCAL":DELIMITER=$c(10))::"SOCKET"	; connect to listening "socket1" on child
	use s
	for  read cmdop($incr(i))  quit:$device		; read data written by child from the socket
	use $principal
	zwrite cmdop					; display data written by child in parent
	quit
childLocal ;
	set s="socket"					; create a SOCKET device in child
	open s:(CONNECT="socket2:LOCAL")::"SOCKET"	; connect to "socket2" listening socket in parent
	use s
	write /accept(.handle,,,)			; accept the listening "socket1" socket from parent
	use s:(attach=handle)
	write /wait					; wait for a connection from parent to come on "socket1" listening socket
	use s:(delimiter=$c(10))			; set delimiters explicitly since they are not inherited in passed sockets
	; Write to this socket some data that will be read (and displayed) by the parent
	for i=1:1:2  write "socketLocalPassListening : This is the child writing Line ",i," out of 2 lines",!
	quit

