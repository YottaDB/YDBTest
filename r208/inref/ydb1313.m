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
;
; YDB#1313 : WRITE /TLS("client",timeout) and WRITE /TLS("server",timeout) on a blocking socket must time out
; when the peer sends no TLS handshake messages, and must leave the socket blocking.
;
; Each label below is run by tls_handshake_timeout-ydb1313.csh. The port is in the portno environment variable.
; The peer of each stage is a JOBbed process, which signals that it is ready by setting ^ready(stage), and
; which stops when the parent sets ^stop(stage). A silent peer waits for ^stop(stage) for at most 15 seconds,
; so that a handshake that does not time out fails after 15 seconds instead of waiting forever.
;
ydb1313	;
	write "Run one label at a time. See tls_handshake_timeout-ydb1313.csh",!
	quit
	;
clienttimeout	; WRITE /TLS("client",1) to a peer that accepts the TCP connection and never answers the handshake
	new pid,port,s,t0,el,tst
	set $etrap="do etrap^ydb1313"
	set port=$ztrnlnm("portno"),s="client"
	job silentserver(port,1):(output="silentserver.mjo":error="silentserver.mje")
	set pid=$zjob
	do waitready(1)
	open s:(connect="127.0.0.1:"_port_":TCP":attach="client"):10:"SOCKET"
	else  write "WRONG : could not connect to the peer",! do stoppeer(1,pid) quit
	use s
	do checkblocking(s,"before WRITE /TLS")
	set t0=$zut
	write /tls("client",1,"client")
	set tst=$test,el=$zut-t0
	do checktimeout("client",tst,el)
	do checkblocking(s,"after WRITE /TLS timed out")
	close s
	do stoppeer(1,pid)
	quit
	;
servertimeout	; WRITE /TLS("server",1) with a TCP client that never starts the handshake
	new key,pid,port,s,t0,el,tst
	set $etrap="do etrap^ydb1313"
	set port=$ztrnlnm("portno"),s="server"
	open s:(listen=port_":TCP":attach="listener"):10:"SOCKET"
	else  write "WRONG : could not listen on the port",! quit
	job silentclient(port,2):(output="silentclient.mjo":error="silentclient.mje")
	set pid=$zjob
	use s
	write /listen(1)
	write /wait(30)
	set key=$key
	if "CONNECT"'=$piece(key,"|") use $principal write "WRONG : no connection from the peer, $KEY is [",key,"]",! do stoppeer(2,pid) quit
	do checkblocking(s,"before WRITE /TLS")
	set t0=$zut
	write /tls("server",1,"server")
	set tst=$test,el=$zut-t0
	do checktimeout("server",tst,el)
	do checkblocking(s,"after WRITE /TLS timed out")
	close s
	do stoppeer(2,pid)
	quit
	;
handshake(timeout)	; A TLS server and a JOBbed TLS client complete the handshake, then send one line each way.
	; timeout is the timeout of both WRITE /TLS commands, or "" for none.
	new key,line,pid,port,s,stage,tst
	set $etrap="do etrap^ydb1313"
	set port=$ztrnlnm("portno"),s="server",stage=$select(""=timeout:4,1:3)
	open s:(listen=port_":TCP":attach="listener"):10:"SOCKET"
	else  write "WRONG : could not listen on the port",! quit
	; The output and error file names of a JOB must be literals, so build the JOB argument with indirection
	job @("tlsclient(port,stage,timeout):(output=""tlsclient"_stage_".mjo"":error=""tlsclient"_stage_".mje"")")
	set pid=$zjob
	use s
	write /listen(1)
	write /wait(30)
	set key=$key
	if "CONNECT"'=$piece(key,"|") use $principal write "WRONG : no connection from the peer, $KEY is [",key,"]",! do stoppeer(stage,pid) quit
	if ""=timeout write /tls("server",,"server") set tst=1
	else  write /tls("server",timeout,"server") set tst=$test
	use $principal
	if tst write "PASS : the server handshake succeeded",!
	else  write "WRONG : the server handshake timed out, expected $TEST to be 1",!
	use s
	do checkblocking(s,"after the server handshake")
	read line:30
	use $principal
	if $test,"ping from client"=line write "PASS : the server read [",line,"]",!
	else  write "WRONG : the server read [",line,"], expected [ping from client]",!
	use s
	write "pong from server",!
	do waitpeer(stage,pid)
	close s
	use $principal
	write $get(^result(stage),"WRONG : the client did not report its result"),!
	quit
	;
silentserver(port,stage)	; accept one TCP connection and never answer the handshake
	new s
	set s="silent"
	open s:(listen=port_":TCP":attach="listener"):10:"SOCKET"
	else  quit
	use s
	write /listen(1)
	set ^ready(stage)=1
	write /wait(30)
	do waitstop(stage)
	close s
	quit
	;
silentclient(port,stage)	; connect to the server and never start the handshake
	new s
	set s="silent"
	open s:(connect="127.0.0.1:"_port_":TCP":attach="client"):30:"SOCKET"
	else  quit
	do waitstop(stage)
	close s
	quit
	;
tlsclient(port,stage,timeout)	; connect, complete the client handshake, then send one line and read one line
	new line,result,s,tst
	set s="client"
	open s:(connect="127.0.0.1:"_port_":TCP":attach="client"):30:"SOCKET"
	else  set ^result(stage)="WRONG : the client could not connect" quit
	use s
	if ""=timeout write /tls("client",,"client") set tst=1
	else  write /tls("client",timeout,"client") set tst=$test
	if 'tst set ^result(stage)="WRONG : the client handshake timed out, expected $TEST to be 1" close s quit
	if 0'=$$nonblock(s) set ^result(stage)="WRONG : the client socket is nonblocking (or its flags are unknown) after the client handshake" close s quit
	write "ping from client",!
	read line:30
	if $test,"pong from server"=line set result="PASS : the client handshake succeeded, its socket is blocking, and the client read ["_line_"]"
	else  set result="WRONG : the client read ["_line_"], expected [pong from server]"
	set ^result(stage)=result
	close s
	quit
	;
checktimeout(side,tst,el)	; WRITE /TLS must return $TEST=0 after its 1 second timeout, not after the peer gives up
	use $principal
	if 0'=tst write "WRONG : the ",side," handshake returned $TEST=",tst,", expected 0",!
	else  if (el<900000)!(el>10000000) write "WRONG : the ",side," handshake returned after ",$justify(el/1000000,0,3)," seconds, expected 0.9 to 10 seconds",!
	else  write "PASS : the ",side," handshake timed out with $TEST=0 after about 1 second",!
	quit
	;
checkblocking(s,when)	; the file descriptor of the current socket of device s must not have O_NONBLOCK set
	new nonblock,saveio
	set saveio=$io
	set nonblock=$$nonblock(s)
	use $principal
	if -1=nonblock write "WRONG : no flags for the socket in /proc/",$job,"/fdinfo",!
	else  if nonblock write "WRONG : the socket is nonblocking ",when,", expected it to be blocking",!
	else  write "PASS : the socket is blocking ",when,!
	use saveio
	quit
	;
nonblock(s)	; 1 if the file descriptor of the current socket of device s has O_NONBLOCK set, 0 if not, -1 if unknown
	new dec,fd,file,flags,i,line,saveio
	set saveio=$io
	set fd=$zsocket(s,"descriptor",$zsocket(s,"currentindex"))
	set file="/proc/"_$job_"/fdinfo/"_fd,flags=""
	open file:(readonly)
	use file
	for  read line quit:$zeof  if "flags:"=$piece(line,$char(9)) set flags=$piece(line,$char(9),2)
	close file
	use saveio
	if ""=flags quit -1
	set dec=0
	for i=1:1:$length(flags) set dec=dec*8+$extract(flags,i)
	quit dec\2048#2	; O_NONBLOCK is 04000 octal
	;
waitready(stage)	; wait for the peer to be ready
	new i
	for i=1:1:300 quit:$get(^ready(stage))  hang 0.1
	quit
	;
waitstop(stage)	; wait for the parent to set ^stop(stage), for at most 15 seconds
	new i
	for i=1:1:150 quit:$get(^stop(stage))  hang 0.1
	quit
	;
stoppeer(stage,pid)	; tell the peer to stop, then wait for it to exit
	set ^stop(stage)=1
	do waitpeer(stage,pid)
	quit
	;
waitpeer(stage,pid)	; wait for the peer to exit, for at most 60 seconds
	new i
	for i=1:1:600 quit:'$zgetjpi(pid,"isprocalive")  hang 0.1
	if $zgetjpi(pid,"isprocalive") use $principal write "WRONG : the peer of stage ",stage," did not exit",!
	quit
	;
etrap	;
	use $principal
	write "WRONG : unexpected error : ",$zstatus,!
	set $ecode=""
	halt
