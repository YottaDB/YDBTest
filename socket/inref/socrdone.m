;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2007, 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [C9H04-002843] Test READ * for socket device.
;
;   - Open a socket with no delimiters.
;   - ZSHOW the device
;   - Fork off a receiver process
;   - Send and receive bytes 0 through 255
;   - Close down receiver process

	Set startshutdowntimeout=300	; For loops starting up or shutting down, do a max 5 minute wait

        Set $Ztrap="Set $Ztrap="""" Set ^done=1 Use $P ZShow ""*"" Halt"
        Set unix=$ZVersion'["VMS"

        Set ^recvractive=0
        Set ^done=0

        ; Fork off receiver
        Write "Spawning receiver process",!
        If unix Job @("receiver^socrdone():(output=""receiver.mjo"":error=""receiver.mje"")")
        Else    Job @("receiver^socrdone():(nodetached:startup=""startup.com"":output=""receiver.mjo"":error=""receiver.mje"")")
        ; Make sure at least one dot
        For i=1:1:startshutdowntimeout Write "." Quit:^recvractive=1  Hang 1
        If i>startshutdowntimeout Do
        . Write !,"FAIL TEST - Receiver did not STARTUP in the allotted time",!
        . ZSHOW "*"
	. Halt
	Else  Write !,"Receiver process active",!

        ; Connecting to the receiver
	Write "Connecting to the receiver",!
        Set portno=^config("portno"),hostname=^config("hostname")
        Set tcpdev="client$"_$j,timeout=10
        Set openarg="(connect="""_hostname_":"_portno_":TCP"""_":attach=""client"")"
        Open tcpdev:@openarg:timeout:"SOCKET"
        Write !,"Connection to receiver established",!

	For indx=0:1:255 Do  quit:^done
	. Use tcpdev
	. Write *indx
	. Read *echoed:timeout
	. Else  Do
        . . Use $P
        . . Write "Read timeout reading byte ",indx,!
        . . ZShow "*"
        . . Close tcpdev
        . . Set ^done=1
        . . Do HaltWhenRecvrStopped
	. Set ^bytes(indx)=echoed
	. If indx'=echoed Do
        . . Use $P
        . . Write "Expected byte value ",indx," but got ",echoed,!
        . . ZShow "*"
        . . Close tcpdev
        . . Set ^done=1
        . . Do HaltWhenRecvrStopped
	;
	Use $P
	If ^done Do
	. Write "Terminating early due to ^done being set",!
	. Halt

	Close tcpdev
	Set ^done=1
	Write !,"***************************",!
	Write !,"TEST PASS",!
	Write !,"Shutting down receiver process - test complete",!
	Do HaltWhenRecvrStopped

	; end of routine - this will not return


	;
	; Receiver routine..
receiver
        Set $Ztrap="Set $Ztrap="""" Use $P ZShow ""*"" Set ^recvractive=0 Set ^done=1 Halt"
	; Set up a listener and wait for connection
        Set portno=^config("portno")
        Set tcpdev="server$"_$j,timeout=30
        Set openarg="(LISTEN="""_portno_":TCP"""_":attach=""server"")"
        Open tcpdev:@openarg:timeout:"SOCKET"
	Set timeout=10	; 10 second timeout is sufficient for small packets
        Use tcpdev
        Write /listen(1)
        Set ^recvractive=1               ; signal main we are running (listening)
        Write /wait(timeout)
        Else  Do
	. Use $P
	. Write "Open to main failed during wait for connection: $zstatus=",$Zstatus,!
	. Set ^done=1
	. Halt
        Set key=$Key,childsocket=$Piece(key,"|",2),ip=$p(key,"|",3)
        Use $P
        Zwrite key
        Write !,"Receiver now connected to main process",!

	Set bytecnt=0
	;
	; This processes job is only to read in the bytes as they come in and write them
	; back out.
	Use tcpdev
	For  Quit:^done  Do
	. Read *onebyte:timeout
	. Else  If '^done Do
	. . Use $P
	. . Write "Read timeout reading byte ",bytecnt,!
	. . ZShow "*"
	. . Close tcpdev
	. . Set ^recvractive=0
	. . Set ^done=1
	. . Halt
	. Set ^read(bytecnt)=onebyte
	. If ^done Do
	. . Use $P
	. . Write "Terminating due to setting of ^done",!
	. . Close tcpdev
	. . ZShow "*"
	. . Set ^recvractive=0
	. . Halt
	. ;
	. ; Check if we got the proper byte
	. If onebyte'=bytecnt Do
	. . Use $P
	. . Write "Expected byte value ",bytecnt," but got ",onebyte,!
	. . ZShow "*"
	. . Close tcpdev
	. . Set ^recvractive=0
	. . Set ^done=1
	. . Halt
	. ;
	. ; Next job is to send the received byte back out
	. Write *onebyte
	. Set bytecnt=bytecnt+1

	; If we we didn't leave the loop quite like we wanted to. Receiver is dying so no need to
	; wait on its account..
	If ^done Do
        . Use $P
        . Write "Terminating due to setting of ^done",!
        . ZShow "*"

	; Normal close
	Close tcpdev
        Set ^recvractive=0
        Halt

; Routine to wait until the receiver process shuts down
HaltWhenRecvrStopped
        ; Make sure at least one dot
        For i=1:1:startshutdowntimeout Write "." Quit:^recvractive=0  Hang 1
	If i>startshutdowntimeout Do
	. Write !,"FAIL TEST - Receiver did not SHUTDOWN in the allotted time",!
	. ZShow "*"
        Else  Write !,"Receiver process has shutdown",!
	Halt
