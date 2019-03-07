;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2011, 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for C9L06-003423. An application that uses WRITE /WAIT or any other non-parenthesized mnemonic
; could run into a buffer overrun condition because when WAIT is passed to iosocket_iocontrol, it is
; not null-terminated yet is parsed with a SSCANF() library call causing the SSCANF to continue scanning
; long past the argument into other areas of the string pool copying what it finds into a small buffer
; that is easily overflowed. This test fills the stringpool with "stuff" then uses WRITE /WAIT to verify
; the problem is fixed. Failures are typically sig-11s or %YDB-E-INVCTLMNE errors.
;
	Set $ETrap="Use $P ZShow ""*"" Halt"
	;
	; First task, use up a bunch of stringpool
	;
	For i=1:1:100000 Set $ZPiece(x,"X",10)="X"
	Kill x
	;
	; Stringpool should be well chewed by now. Set up socket device and job off
	; a client
	;
	Set portno=$ZTrnlnm("portno")
	Set clientpid=$ZJob
	Set tcpdev="server$"_$Job
	Set timeout=120
	Open tcpdev:(LISTEN=portno_":TCP":attach="server"):timeout:"SOCKET"
	Set jmaxwait=0		; Return immediately
	Set jdetached=1		; Run as detached
	Do ^job("SockClient^"_$Text(+0),1,portno)
	Use tcpdev
	Write /listen(1)
	;
	; For these supplementary sockets, note we do NOT specify a timeout
	; because that would defeat the purpose of the testing which makes
	; the above mentioned mnemonic parse correctly if (timeout) were
	; specified. To provide *some* sort of timeout for testing purposes,
	; we use TPTIMEOUT
	;
	;
	Set $ZMaxtptime=60
	For i=1:1:63 Do
	. TStart ():Serial
	. Write /wait
	. TCommit
	Use $P
	Write "All connections completed - PASS",!
	Do wait^job	       	; Wait for client to exit
	Quit

;
; Socket client to attach to chkbroksock server socket
;
SockClient(portno)
	Set $ETrap="ZShow ""*"" Halt"
	Write "Client process PID ",$Job,!
	Set host=$$^findhost(2)	  ; Should do right thing to find host on either VMS or *NIX
	Set tcpdev="client$"_$Job
	Set timeout=30
	Write "Starting creation of socket devices",!
	For i=1:1:63 Do
	. Open tcpdev_i:(Connect=host_":"_portno_":TCP":Attach="client"):timeout:"SOCKET"
	. If '$Test Write "Socket connect timeout failure - halting",!! ZShow "*" Halt
	. Write $ZDate($Horolog,"24:60:SS")_" Socket dev #",i," created",!
	Write !,"Sockets all created - shutting down now",!
	Quit
