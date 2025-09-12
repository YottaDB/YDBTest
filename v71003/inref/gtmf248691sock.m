;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmf248691sock	;
	; Drive one TLS SOCKET device connection and record the outcome of WRITE /TLS on each side.
	;
	; $zcmdline is the port number to use. The parent process runs the server side of the connection
	; and a JOBbed child runs the client side. Each side writes one outcome line, the parent to its
	; standard output and the child to gtmf248691sockclient.txt, so that the caller can compare two
	; runs that differ only in the TLS configuration file. That comparison, rather than any assumption
	; about what a failure looks like, is what shows whether a configuration option changed the
	; behavior of the SOCKET device or was ignored.
	new port
	set port=$piece($zcmdline," ",1)
	kill ^gtmf248691
	set ^gtmf248691("port")=port
	set ^gtmf248691("listening")=0
	; A JOB parameter value has to be a string literal, so the child always writes to the same file
	; and the caller renames it between runs
	job client:(output="gtmf248691sockclient.txt":error="gtmf248691sockclient.err")
	set ^gtmf248691("childpid")=$zjob
	do server
	; Let the child finish writing its outcome line before the caller compares the files
	new maxwait
	set maxwait=60
	do ^waitforproctodie(^gtmf248691("childpid"))
	quit
	;
server	;
	new s
	set s="sock"
	set $etrap="do trap(""server"") quit"
	open s:(LISTEN=^gtmf248691("port")_":TCP":delim=$char(13):attach="listener"):30:"SOCKET"
	if '$test do report("server","LISTEN socket not opened") quit
	set ^gtmf248691("listening")=1	; release the client, which cannot connect before this point
	use s
	write /listen(1)
	write /wait(30)
	if '$test do report("server","no connection after 30 seconds") quit
	write /tls("server",30,"server")
	do report("server","write /tls $test="_+$test_" $device="_$device)
	quit
	;
client	;
	new s,host,i
	set s="sock"
	set $etrap="do trap(""client"") quit"
	for i=1:1:3000 quit:1=$get(^gtmf248691("listening"))  hang 0.01
	if 1'=$get(^gtmf248691("listening")) do report("client","server never started listening") quit
	set host=$$^findhost(2)
	open s:(CONNECT=host_":"_^gtmf248691("port")_":TCP":delim=$char(13)):30:"SOCKET"
	if '$test do report("client","CONNECT socket not opened") quit
	use s
	write /tls("client",30,"client")
	do report("client","write /tls $test="_+$test_" $device="_$device)
	quit
	;
report(side,text)	; write the one outcome line for this side
	use $principal
	write side,": ",text,!
	quit
	;
trap(side)	; record the error instead of letting it terminate the process
	new zs
	set zs=$zstatus
	set $ecode=""
	; Drop the error code and the routine and line number, keeping only the message text, so that
	; editing this program cannot change the recorded outcome
	do report(side,"error "_$piece(zs,",",3,999))
	quit
