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
	Write "Lclient process PID ",$Job,!
	Set socpath="local.socket"
	Set host=$ZTrnlnm("HOST")
	Set lsocdev="lclient$"_$Job
	Set timeout=60
	Set line="SocketDataSocketDataSocketDataSocketDataSocketData"
	Set ^linelen=$Length(line)
	Write "Starting creation of local socket devices",!
	For i=1:1:5 Do
	. Open lsocdev_i:(Connect=socpath_":LOCAL":Attach="lclient"_i):timeout:"SOCKET"
	. If '$Test Write "Socket connect timeout failure - halting",!! ZShow "*" Halt
	. Use $P
	. Write "Local socket dev #",i," created",!
	Write !,"Local sockets all created",!
	For i=1:1:5 Do
	. Use lsocdev_i
	. Write line,!
	. Use $P
	. Write "Data for local socket ",i," sent",!
	ZShow "*"
	Lock ^LocalSocket	; When main process exits, this lock will be released
	Quit
