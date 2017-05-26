;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
splitp(portno4,portno4x,portno6,portno6x)
	new timeout,hostn,aixnov6,$etrap
	set $etrap="set err=""splitp_trap.err""  open err  use err  zshow ""*""  halt"
	set timeout=10						; short for initial testing
	set hostn=$piece($ztrnlnm("HOST"),".",1)
	set aixnov6=(hostn["lespaul")!(hostn["pfloyd")
	do testsamesocket(timeout)
	do testdifftypes(timeout)
	do testdiffclients(timeout)
	do testdiffservers(timeout)
	quit

; Test with the same socket on input and output
testsamesocket(timeout)
	new s,lhandle,lname,shandle,chandle
	; local socket
	do getlocallistener(.s,.lhandle,.lname,timeout)
	do getlocalcon(s,lname,.shandle,.chandle,timeout)
	do testcombo("loc","loc",lhandle,lhandle,shandle,shandle,chandle,chandle,timeout)
	close s:SOCKET=lhandle
	; IPv4 socket
	do gettcplistener(portno4,.s,.lhandle,timeout)
	do gettcpcon(s,portno4,4,.shandle,.chandle,timeout)
	do testcombo("v4","v4",lhandle,lhandle,shandle,shandle,chandle,chandle,timeout)
	close s:SOCKET=lhandle
	; IPv6 socket
	if 'aixnov6 do
	. do gettcplistener(portno6,.s,.lhandle,timeout)
	. do gettcpcon(s,portno6,6,.shandle,.chandle,timeout)
	. do testcombo("v6","v6",lhandle,lhandle,shandle,shandle,chandle,chandle,timeout)
	. close s:SOCKET=lhandle
	;
	close s:DESTROY
	quit

; Test with different socket types on input and output
testdifftypes(timeout)
	new s1,lhandle1,lname1,shandle1,chandle1
	new s2,lhandle2,lname2,shandle2,chandle2
	; local input, IPv4 output
	do getlocallistener(.s1,.lhandle1,.lname1,timeout)
	do getlocalcon(s1,lname1,.shandle1,.chandle1,timeout)
	do gettcplistener(portno4,.s2,.lhandle2,timeout)
	do gettcpcon(s2,portno4,4,.shandle2,.chandle2,timeout)
	do testcombo("loc","v4",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; local input, IPv6 output
	if 'aixnov6 do
	. do getlocallistener(.s1,.lhandle1,.lname1,timeout)
	. do getlocalcon(s1,lname1,.shandle1,.chandle1,timeout)
	. do gettcplistener(portno6,.s2,.lhandle2,timeout)
	. do gettcpcon(s2,portno6,6,.shandle2,.chandle2,timeout)
	. do testcombo("loc","v6",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	. close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; IPv4 input, local output
	do gettcplistener(portno4,.s1,.lhandle1,timeout)
	do gettcpcon(s1,portno4,4,.shandle1,.chandle1,timeout)
	do getlocallistener(.s2,.lhandle2,.lname2,timeout)
	do getlocalcon(s2,lname2,.shandle2,.chandle2,timeout)
	do testcombo("v4","loc",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; IPv4 input, IPv6 output
	if 'aixnov6 do
	. do gettcplistener(portno4,.s1,.lhandle1,timeout)
	. do gettcpcon(s1,portno4,4,.shandle1,.chandle1,timeout)
	. do gettcplistener(portno6,.s2,.lhandle2,timeout)
	. do gettcpcon(s2,portno6,6,.shandle2,.chandle2,timeout)
	. do testcombo("v4","v6",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	. close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; IPv6 input, local output
	if 'aixnov6 do
	. do gettcplistener(portno6,.s1,.lhandle1,timeout)
	. do gettcpcon(s1,portno6,6,.shandle1,.chandle1,timeout)
	. do getlocallistener(.s2,.lhandle2,.lname2,timeout)
	. do getlocalcon(s2,lname2,.shandle2,.chandle2,timeout)
	. do testcombo("v6","loc",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	. close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; IPv6 input, IPv4 output
	if 'aixnov6 do
	. do gettcplistener(portno6,.s1,.lhandle1,timeout)
	. do gettcpcon(s1,portno6,6,.shandle1,.chandle1,timeout)
	. do getlocallistener(.s2,.lhandle2,.lname2,timeout)
	. do getlocalcon(s2,lname2,.shandle2,.chandle2,timeout)
	. do testcombo("v6","v4",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	. close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	;
	close s1:DESTROY,s2:DESTROY
	quit

; Test with different client connections to the same server on input and output
testdiffclients(timeout)
	new s,lhandle,lname,shandle1,chandle1,shandle2,chandle2
	; local socket
	do getlocallistener(.s,.lhandle,.lname,timeout)
	do getlocalcon(s,lname,.shandle1,.chandle1,timeout)
	do getlocalcon(s,lname,.shandle2,.chandle2,timeout)
	do testcombo("loc","loc",lhandle,lhandle,shandle1,shandle2,chandle1,chandle2,timeout)
	close s:SOCKET=lhandle
	; IPv4 socket
	do gettcplistener(portno4,.s,.lhandle,timeout)
	do gettcpcon(s,portno4,4,.shandle1,.chandle1,timeout)
	do gettcpcon(s,portno4,4,.shandle2,.chandle2,timeout)
	do testcombo("v4","v4",lhandle,lhandle,shandle1,shandle2,chandle1,chandle2,timeout)
	close s:SOCKET=lhandle
	; IPv6 socket
	if 'aixnov6 do
	. do gettcplistener(portno6,.s,.lhandle,timeout)
	. do gettcpcon(s,portno6,6,.shandle1,.chandle1,timeout)
	. do gettcpcon(s,portno6,6,.shandle2,.chandle2,timeout)
	. do testcombo("v6","v6",lhandle,lhandle,shandle1,shandle2,chandle1,chandle2,timeout)
	. close s:SOCKET=lhandle
	;
	close s:DESTROY
	quit

; Test with different client connections to different servers on input and output
testdiffservers(timeout)
	new s1,lhandle1,lname1,shandle1,chandle1
	new s2,lhandle2,lname2,shandle2,chandle2
	; local socket
	do getlocallistener(.s1,.lhandle1,.lname1,timeout)
	do getlocalcon(s1,lname1,.shandle1,.chandle1,timeout)
	do getlocallistener(.s2,.lhandle2,.lname2,timeout)
	do getlocalcon(s2,lname2,.shandle2,.chandle2,timeout)
	do testcombo("loc","loc",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; IPv4 socket
	do gettcplistener(portno4,.s1,.lhandle1,timeout)
	do gettcpcon(s1,portno4,4,.shandle1,.chandle1,timeout)
	do gettcplistener(portno4x,.s2,.lhandle2,timeout)
	do gettcpcon(s2,portno4x,4,.shandle2,.chandle2,timeout)
	do testcombo("v4","v4",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	; IPv6 socket
	if 'aixnov6 do
	. do gettcplistener(portno6,.s1,.lhandle1,timeout)
	. do gettcpcon(s1,portno6,6,.shandle1,.chandle1,timeout)
	. do gettcplistener(portno6x,.s2,.lhandle2,timeout)
	. do gettcpcon(s2,portno6x,6,.shandle2,.chandle2,timeout)
	. do testcombo("v6","v6",lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	. close s1:SOCKET=lhandle1,s2:SOCKET=lhandle2
	;
	close s1:DESTROY,s2:DESTROY
	quit

; Test client and server interaction with selected sockets
; rtype,wtype,lhandle1,lhandle2 used only to identify the test
testcombo(rtype,wtype,lhandle1,lhandle2,shandle1,shandle2,chandle1,chandle2,timeout)
	new ss,cj,id,$etrap
	set id=rtype_"_"_wtype_"_"_$select(lhandle1=lhandle2:"ss",1:"ds")_"_"_$select(chandle1=chandle2:"sc",1:"dc")
	set ss=$$^%RANDSTR()
	use $P  write "Case: "_id,!
	open ss:::"SOCKET"
	use ss:ATTACH=shandle1
	use:shandle1'=shandle2 ss:ATTACH=shandle2
	job @("client("""_id_"""):(INPUT=""SOCKET:"_chandle1_""":OUTPUT=""SOCKET:"_chandle2_""":ERROR=""client_"_id_".err"")")
	set cj=$zjob
	; Swapped shandle1/shandle2 so that client writes to server read, and vice versa.
	do server(ss,id,shandle2,shandle1,timeout)
	close ss:DESTROY
	do waitforproctodie^waitforproctodie(cj,timeout)
	quit

; Set up a listener on a LOCAL socket
; s,lhandle,lname pass-by-reference
getlocallistener(s,lhandle,lname,timeout)
	new lkey,lstate
	set s=$$^%RANDSTR()
	open s:::"SOCKET"
	open s:LISTEN=$$^%RANDSTR()_".sock:LOCAL":timeout:"SOCKET"
	else  use $P  write "TEST-E-timeout in getlocallistener",!  set lhandle="bogus",lname="/dev/null"  quit
	use s  set lkey=$key,lstate=$piece(lkey,"|",1),lhandle=$piece(lkey,"|",2),lname=$piece(lkey,"|",3)
	if lstate'="LISTENING"  use $P  write "TEST-E-badlstate in getlocallistener, "_lstate,!  set lhandle="bogus"  quit
	use $P
	quit

; Set up a connection on a LOCAL socket and return handles for both ends
; shandle,chandle pass-by-reference
getlocalcon(s,lname,shandle,chandle,timeout)
	new ckey,skey,cstate,sstate
	open s:(CONNECT=lname_":LOCAL":IOERROR="trap"):timeout:"SOCKET"
	else  use $P  write "TEST-E-timeout in getlocalcon connect",!  set shandle="bogus",chandle="bogus"  quit
	use s  set ckey=$key,cstate=$piece(ckey,"|",1),chandle=$piece(ckey,"|",2)
	if cstate'="ESTABLISHED"  use $P  write "TEST-E-badcstate in getlocalcon, "_cstate,!  set shandle="bogus",chandle="bogus"  quit
	; Accept the connection created above from the listener socket, which is also in this socket device.
	write /wait(timeout)
	else  use $P  write "TEST-E-timeout in getlocalcon wait",!  set shandle="bogus",chandle="bogus"  quit
	set skey=$key,sstate=$piece(skey,"|",1),shandle=$piece(skey,"|",2)
	if sstate'="CONNECT"  use $P  write "TEST-E-badsstate in getlocalcon, "_sstate,!  close s:SOCKET=chandle  set shandle="bogus",chandle="bogus"  quit
	use s:DETACH=shandle
	use s:DETACH=chandle
	use $P
	quit

; Set up a listener on a TCP socket
; s,lhandle pass-by-reference
gettcplistener(port,s,lhandle,timeout)
	new lkey,lstate
	set s=$$^%RANDSTR()
	open s:::"SOCKET"
	open s:(LISTEN=port_":TCP":IOERROR="trap"):timeout:"SOCKET"
	else  use $P  write "TEST-E-timeout in gettcplistener",!  set lhandle="bogus"  quit
	use s  set lkey=$key,lstate=$piece(lkey,"|",1),lhandle=$piece(lkey,"|",2)
	if lstate'="LISTENING"  use $P  write "TEST-E-badlstate in gettcplistener, "_lstate,!  set lhandle="bogus"  quit
	use $P
	quit

; Set up a connection on a TCP socket and return handles for both ends
; shandle,chandle pass-by-reference
gettcpcon(s,port,ipv,shandle,chandle,timeout)
	new host,ckey,skey,cstate,sstate
	set host=$select(ipv=4:"127.0.0.1",ipv=6:"[::1]")
	open s:(CONNECT=host_":"_port_":TCP":IOERROR="trap"):timeout:"SOCKET"
	else  use $P  write "TEST-E-timeout in gettcpcon connect",!  set shandle="bogus",chandle="bogus"  quit
	use s  set ckey=$key,cstate=$piece(ckey,"|",1),chandle=$piece(ckey,"|",2)
	if cstate'="ESTABLISHED"  use $P  write "TEST-E-badcstate in gettcpcon, "_cstate,!  set shandle="bogus",chandle="bogus"  quit
	; Accept the connection created above from the listener socket, which is also in this socket device.
	write /wait(timeout)
	else  use $P  write "TEST-E-timeout in gettcpcon wait",!  set shandle="bogus",chandle="bogus"  quit
	set skey=$key,sstate=$piece(skey,"|",1),shandle=$piece(skey,"|",2)
	if sstate'="CONNECT"  use $P  write "TEST-E-badsstate in gettcpcon, "_sstate,!  close s:SOCKET=chandle  set shandle="bogus",chandle="bogus"  quit
	use s:DETACH=shandle
	use s:DETACH=chandle
	use $P
	quit

; interact with socket device s, using readhandle for input and writehandle for output
server(s,id,readhandle,writehandle,timeout)
	new x,t,key,handle,zs,zsf,$etrap,err
	set $etrap="set err=""server_""_id_""_trap.err""  open err  use err  zshow ""*""  halt"
	set t="Albuquerque"
	use s:SOCKET=readhandle
	use s:(DELIMITER=$c(10):IOERROR="trap")
	use s:SOCKET=writehandle
	use s:(DELIMITER=$c(10):IOERROR="trap")
	zshow "D":zs  set zsf="server_"_id_"_zs.out"  open zsf  use zsf  zwrite s,readhandle,writehandle,zs  close zsf
	use s:SOCKET=writehandle
	write t,!
	write /wait(timeout)
	else  use $P  write "TEST-E-TIMEOUT in server wait",!  quit
	set key=$key,handle=$piece(key,"|",2)
	if handle'=readhandle  use $P  write "TEST-E-badhandle",!  zwrite readhandle,writehandle,handle  quit
	use s:SOCKET=readhandle
	read x:timeout
	else  use $P  write "TEST-E-TIMEOUT in server read",!  zshow "D"  quit
	use s:SOCKET=writehandle
	write $select(x=("You said, """_t_""", correct?"):"Yes.",1:"Huh? I don't understand """_x_""""),!
	quit

; interact with socket device on $P, using "id" in the filename for reporting status.
; we are using the client to test attaching and detaching the socket from $ZPIN
; $zsocket is used to get the handle for this socket.  We also get the handle for the
; socket attached to $ZPOUT.  If these handles are the same then it is not a split $P
; so only detach the socket from $ZPIN.  One or both are re-attached to test the
; capability of $ZSOCKET and USE for a split socket $PRINCIPAL.  zshow "d" is saved into
; client files as changes are made.  All these client files are of the form:
; client_..._..._.._.._zs.out
client(id)
	new cf,x,zs,zsf,$etrap
	set $etrap="set err=""client_""_id_""_trap.err""  open err  use err  zshow ""*""  halt"
	use $P:(DELIMITER=$c(10):IOERROR="trap")
	zshow "D":zs
	set zsf="client_"_id_"_zs.out" open zsf  use zsf  zwrite zs
	; get the handles for $ZPIN and $ZPOUT which will be different if a split $P
	set h1=$zsocket($ZPIN,"SOCKETHANDLE",0)
	set h2=$zsocket($ZPOUT,"SOCKETHANDLE",0)
	; detach h1 from $ZPIN
	use $ZPIN:detach=h1
	use zsf
	write "zshow ""D"" after detach from $ZPIN",!
	zshow "D"
	; if a split device then detach h2 from $ZPOUT
	if h1'=h2 do
	.	use $ZPOUT:detach=h2
	.	use zsf
	.	write "zshow ""D"" after detach from $ZPOUT",!
	.	zshow "D"
	; re-attach h1 to $ZPIN
	use $ZPIN:attach=h1
	use zsf
	write "zshow ""D"" after attach to $ZPIN",!
	zshow "D"
	; if a split device then re-attach h2 to $ZPOUT
	if h1'=h2 do
	.	use $ZPOUT:attach=h2
	.	use zsf
	.	write "zshow ""D"" after attach to $ZPOUT",!
	.	zshow "D"
	close zsf
	set cf="client_"_id_".out"
	open cf
	read x
	write "You said, """_x_""", correct?",!
	read x
	if x="Yes."  use cf  write "Good.",!
	if x'="Yes."  use cf  write "TEST-E-BAD, got: '"_x_"'",!  zshow "D"
	close cf
	quit
