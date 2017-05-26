;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start  ;
	; ------------------------
	; Initialize some variables
	; ------------------------
	use $p
	i '$d(portno) w !,"Usage: portno needs to be set to the port number to be used!",! q
	i '$d(portno2) w !,"Usage: portno needs to be set to the port number to be used!",! q
	i '$d(hostname) w !,"Usage: hostname needs to be set to the host to be used!",! q
	new repcnt,clientDev,serverDev
	set repcnt=3
	set clientDev="CLIENT$"_1
	set serverDev="SERVER$"_1
	set $etrap=""
	;
	; ------------------------
	; Perform the same operations once so they cause the normal memory allocations and we can retest
	; them later to be sure they do not leak memory
	; ------------------------
	set %=$$hostOpenET("badhost123333",80,1)
	set %=$$hostOpen("badhost123333",80,1)
	new before,after
	set (after,before)=$zrealstore
	;
	; ------------------------
	; test 1: open a socket with unresolvable host name
	; ------------------------
	;
	use $p
	set %=$$showdev(clientDev)
	write "Start Test1",!
	set before=$zrealstore
	for i=1:1:repcnt set %=$$hostOpen("badhost123333",80,1)
	set after=$zrealstore
	set %=$$showdev(clientDev)
	if before=after write "Test 1: Correct",!
	else  write "Error: ",before," ",after,!
	;
	; ------------------------
	; test 2: keep openning new devices with unsupported protocol
	; ------------------------
	;
	use $p
	write "Start Test2",!
	set clientDev="CLIENT$0",%=$$tcpOpen("localhost",5050,1)
	set before=$zrealstore
	for i=1:1:repcnt set clientDev="CLIENT$"_i,%=$$tcpOpen("localhost",5050,1)
	set after=$zrealstore
	set %=$$showdev(clientDev)
	if before=after write "Test 2: Correct",!
	else  write "Error: ",before," ",after,!
	;
	; ------------------------
	; test 3: successful open after failed opens
	; ------------------------
	;
	use $p
	write "Start Test3",!
	set before=$zrealstore
	for i=1:1:repcnt set %=$$tcpServerOpen(hostname,5050,1)
	set after=$zrealstore
	set %=$$showdev(clientDev)
	if before=after write "Test 3: Correct",!
	else  write "Error: ",before," ",after,!
	set %=$$serverOpen(hostname,portno,1)
	set %=$$showdev(serverDev)
	write "close the server device",!
	close serverDev:(DESTROY)
	set %=$$showdev(serverDev)
	;
	; ------------------------
	;  test 4: adding sockets to already opened new device
	; ------------------------
	;
	write "Test 4 start: Open one server device with two sockets",!
	set %=$$serverOpen(hostname,portno,1)
	set %=$$serverUse(hostname,portno2,1)
	use $p
	set %=$$showdev(serverDev)
	set before=$zrealstore
	for i=1:1:repcnt set %=$$tcpServerOpen(hostname,portno,1)
	set after=$zrealstore
	set %=$$showdev(serverDev)
	if before=after write "Test 4: Correct",!
	else  write "Error: ",before," ",after,!
	close serverDev:(DESTROY)
	write "Close the server device",!
	set %=$$showdev(serverDev)
	; ------------------------
	;  test 5: timeout for connecting
	; ------------------------
	if $ZVERSION'["VMS" set before=$zrealstore
	else  do
	. set %=$$hostOpen(hostname,portno,1)
	. set after=$zrealstore
	. set before=after
	for i=1:1:repcnt set %=$$hostOpen(hostname,portno,1)
	set after=$zrealstore
	if before=after write "Test 5: Correct",!
	else  write "Error: ",before," ",after,!
	set %=$$showdev(clientDev)
	quit
	;
hostOpen(host,port,timeout)
	open clientDev:(CONNECT=host_":"_port_":TCP":EXCEPTION="goto nClose":NOWRAP:ZNODELAY:MOREREADTIME=500:ZNOFF:NODELIMITER):timeout:"SOCKET"
	quit ""
	;
hostOpenET(host,port,timeout)
	set $etrap="do etTest^gtm7413"
	open clientDev:(CONNECT=host_":"_port_":TCP":IOERROR="TRAP":NOWRAP:ZNODELAY:MOREREADTIME=500:ZNOFF:NODELIMITER):timeout:"SOCKET"
	set $etrap=""
	quit ""
	;
tcpOpen(host,port,timeout) ;Open a socket with unsupported protocol
	open @("clientDev:(CONNECT="""_host_":"_port_":TKD"":EXCEPTION=""goto nClose"":NOWRAP:ZNODELAY:MOREREADTIME=500:ZNOFF:NODELIMITER):timeout:""SOCKET""")
	quit ""
	;
tcpServerOpen(host,port,timeout)
	open serverDev:(ZLISTEN=port_":TKD":EXCEPTION="goto nClose":NOWRAP:ZNODELAY:MOREREADTIME=500:ZNOFF:NODELIMITER):timeout:"SOCKET"
	quit ""
	;
serverOpen(host,port,timeout)
	open serverDev:(ZLISTEN=port_":TCP":EXCEPTION="goto nClose":NOWRAP:ZNODELAY:MOREREADTIME=500:ZNOFF:NODELIMITER):timeout:"SOCKET"
	quit ""
	;
serverUse(host,port,timeout)
	use serverDev:(ZLISTEN=port_":TCP":EXCEPTION="goto zSOerr":NOWRAP:ZNODELAY:MOREREADTIME=500:ZNOFF:NODELIMITER)
	quit ""
	;
zSOerr	close clientDev:(DESTROY)
	write $zstatus,!
	set $ecode="",$zstatus="",$zerror=""
	quit ""
	;
nClose	;Do not close the device
	write $zstatus,!
	set $ecode="",$zstatus="",$zerror=""
	quit ""
	;
etTest	set $etrap=""
	write $zstatus,!
	set $ecode="",$zstatus="",$zerror=""
	quit
	;
showdev(device) ;performs a ZSHOW on the device requested
        new (device)
	set prevdev=$IO
        ZSHOW "D":showtmp
	use $PRINCIPAL
        set tmp="showtmp"
        for  set tmp=$QUERY(@tmp) quit:tmp=""  do
        . if $F(@tmp,device) write "ZSHOW ""D"" output: ",@tmp,!
	use prevdev
        quit ""
	;
