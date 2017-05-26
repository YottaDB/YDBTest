;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; makedmp socket client to attach to makedmp server sockets (creating devices for test report)
; In addition, do some writes so server has some trace table entries.
;
	Write "Iclient process PID ",$Job,!
	Set portno=$ZTrnlnm("socketportno")
	Set host=$ZTrnlnm("HOST")
	Set isocdev="client$"_$Job
	Set timeout=60
	Set line="SocketDataSocketDataSocketDataSocketDataSocketData"
	Set ^linelen=$Length(line)
	Write "Starting creation of socket devices",!
	For i=1:1:5 Do
	. Open isocdev_i:(Connect=host_":"_portno_":TCP":Attach="iclient"_i):timeout:"SOCKET"
	. If '$Test Write "Socket connect timeout failure - halting",!! ZShow "*" Halt
	. Use $P
	. Write "Socket dev #",i," created",!
	Write !,"Sockets all created",!
	For i=1:1:5 Do
	. Use isocdev_i
	. Write line,!
	. Use $P
	. Write "Data for socket ",i," sent",!
	ZShow "*"
	Lock ^InetSocket	; When main process exits, this lock will be released
	Quit
