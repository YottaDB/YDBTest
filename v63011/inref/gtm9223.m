;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm9223	;
	set ^portno=$zcmdline
	write "# Job off the client side of the socket",!
	job client
	write "# Run the server side of the socket in the current process.",!
	do server
	quit

server	;
	set ^pipeDoneInChild=0,^readDoneInParent=0
	set ^serverpid=$job,^childpid=$zjob
	set s="socket"
	write "# server : Open listening socket",!
	; Define $char(13) (aka newline) as delimiter so each READ done later returns with an entire line of data
	open s:(LISTEN=^portno_":TCP":delim=$char(13))::"SOCKET"
	write "# server : Establish connection with client",!
	use s
	write /wait
	use $principal write "# server : Convert non-TLS socket to a TLS socket",!  use s
	write /tls("server",,"server")
	use $principal write "# server : Wait for child to reach the point where it has opened the pipe device",!  use s
	for  quit:^pipeDoneInChild=1  hang 0.001
	use $principal
	write "# server : Now that pipe device has been opened in the child start reading data that child writes to TLS socket",!
	write "# server : Display Client device info read from client",!
	write "# server : Key things to observe in client info below are SOCKET[0], CONNECTED and TLS keywords",!
	write "# server : This used to not show up in GT.M V6.3-010 (before GTM-9223 was fixed in GT.M V6.3-011)",!
	write "####### Client device info ########",!
	; The child signals it is done with sending device info by a "Done" message so check for that.
	; But to avoid indefinite loop (e.g. if test is run with a version of the code before GTM-9223 was fixed)
	; limit iterations to 10 (we don't expect more than 8 lines or so anyways).
	use s for i=1:1:10 read msg  quit:"Done"=msg  use $principal write msg,! use s
	set ^readDoneInParent=1
	use $principal
	write "# Wait for client pid to terminate before returning from server",!
	do ^waitforproctodie($zjob)
	quit

client	;
	set s="socket"
	set hostname=$$^findhost(2)
	open s:(CONNECT=hostname_":"_^portno_":TCP":delim=$char(13))::"SOCKET"	; Open a TLS socket client side connection
	use s
	write /tls("client",,"client")				; Convert non-TLS socket to TLS socket
	open "pipedevice":(command="yes":readonly)::"PIPE"	; Open a PIPE device
	set ^pipeDoneInChild=1	; Signal parent pid that child process has opened a PIPE device after having
				; opened a TLS socket. So it can start reading what we write to TLS socket device
	zshow "d"		; Write the list of open devices in the client side through the TLS socket
	write "Done",!
	; Wait for server to read all the data that we wrote before we terminate. Or else server could sometimes
	; get a ECONNRESET error BEFORE it read all the data that we previously wrote. We have seen this ECONNRESET
	; behavior most frequently on RHEL 8 systems. And only when TLS is enabled. We suspect it is the OpenSSL's
	; handling of out-of-band data that is different in some specific versions. In any case, we address this by
	; ensuring the connection does not get reset on the client side (i.e. the client process does not terminate)
	; until the server has read all important data.
	for  quit:^readDoneInParent=1  hang 0.001
	quit
