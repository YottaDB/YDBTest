;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2004-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; socketdevice.m
	;   test basic functionality of the socket device with combination
	;   of different device parameter and the maintenance of $x and $y
	;   it tests the following device parameter
	;	1. ZFF/ZNOFF
	;	2. ZWIDTH
	;	3. ZLENGTH
	;	4. ZWRAP/ZNOWRAP
	;	5. FILTER with "CHARACTERS" and "NOCHARACTERS"
	;	6. FILTER with "ESCAPE" and "NOESCAPE"
	;
	if '$DATA(^configasalongvariablename78901("portno"))  write !,"Usage: ^configasalongvariablename78901(""portno"") needs to be set to the port number to be used!",!  quit
	if '$DATA(^configasalongvariablename78901("delim"))  write !,"Usage: ^configasalongvariablename78901(""delim"") needs to be set to the delimiter to be used!",!  quit
	if '$DATA(^configasalongvariablename78901("hostname"))  write !,"Usage: ^configasalongvariablename78901(""hostname"") needs to be set to the hostname to be used!",!  quit
	for i=1:1:^dataasalongvariablename45678901("total")  lock +^dataasalongvariablename45678901(i)
	set unix=$ZVERSION'["VMS"
	if unix  do
	. job client:(out="clientb.out":err="clientb.err") set pid($incr(pid))=$zjob
	. job server:(out="serverb.out":err="serverb.err") set pid($incr(pid))=$zjob
	if 'unix  do
	. job server^socdev:(detached:startup="startup.com":output="serverb.out":error="serverv.err")
	. job client^socdev:(detached:startup="startup.com":output="clientb.out":error="clientv.err")
	for i=1:1:^dataasalongvariablename45678901("total")  do
	. write !,i," starting ..."
	. lock -^dataasalongvariablename45678901(i)
	. d waitforstart(i)
	. lock +^dataasalongvariablename45678901(i)
	. write " finished "
	. d conclude
	; wait for backgrounded process to terminate before returning to caller script
	for i=1:1:pid do ^waitforproctodie(pid(i),300)
	quit
waitforstart(i)
	set maxwait=300 ; wait for 5 minutes max
	set waitinterval=1 ; wait 1 sec at a time
	for j=1:1:maxwait quit:(($data(^dataasalongvariablename45678901(i,"read","start")))&($data(^dataasalongvariablename45678901(i,"write","start"))))  hang waitinterval
	if j'<maxwait write "Timed out",! ZSHOW "*" halt
	quit
conclude
	if ^dataasalongvariablename45678901(i,"read","x","ref")'=^dataasalongvariablename45678901(i,"read","x")  write "TEST-E-FAILED x",!  zwrite ^dataasalongvariablename45678901(i,"read","x",*)  quit
	if '$DATA(^dataasalongvariablename45678901(i,"write","x","xref"))!'$DATA(^dataasalongvariablename45678901(i,"write","y","yref")) write "PASS",! quit
	;;if ^dataasalongvariablename45678901(i,"read","t","ref")'=^dataasalongvariablename45678901(i,"read","t")  write "TEST-E-FAILED $T",!  zwrite ^dataasalongvariablename45678901(i,"read","t",*)  quit
	if $DATA(^dataasalongvariablename45678901(i,"write","x","xref")) if ^dataasalongvariablename45678901(i,"write","x","xref")'=^dataasalongvariablename45678901(i,"write","x") write "TEST-E-FAILED $T",!  zwrite ^dataasalongvariablename45678901(i,"write","x",*)  quit
	if $DATA(^dataasalongvariablename45678901(i,"write","y","yref")) if ^dataasalongvariablename45678901(i,"write","y","yref")'=^dataasalongvariablename45678901(i,"write","y") write "TEST-E-FAILED $T",!  zwrite ^dataasalongvariablename45678901(i,"write","y",*)  quit
	write "PASS",!
	quit
server	;;;	the process that reads
	use $PRINCIPAL:(WIDTH=1048576)
	do consrv
	for i=1:1:^dataasalongvariablename45678901("total")  do
	. write "------------------------------------------------------------------",!
	. set t=9
	. lock +^dataasalongvariablename45678901(i,"read")			;;; waits till the driver to tell us to start
	. set ^dataasalongvariablename45678901(i,"read","start")=$H
	. xecute ^dataasalongvariablename45678901(i,"read")
	. ;write ^dataasalongvariablename45678901(i,"read"),!
	. set ^dataasalongvariablename45678901(i,"read","t")=t
	. set ^dataasalongvariablename45678901(i,"read","x")=x
	. set ^dataasalongvariablename(i,"read","t")="This is a failing data-different variable"
	. set ^dataasalongvariablename(i,"read","x")="This is a failing data-different variable"
	. if $data(longstr)  do
	. . set longstr=$$shrnkstr^shrnkfil(longstr)
	. . set rxasalongvariablename2345678901=$$shrnkstr^shrnkfil(rxasalongvariablename2345678901)
	. zwrite
	. lock					;;; tells the driver we are done with this data
	. set ^serverflag(i)="FINISHED"
	quit
client  ;;;	the process that writes
	use $PRINCIPAL:(WIDTH=1048576)
	do conclnt
	set x=0,y=0
	for i=1:1:^dataasalongvariablename45678901("total")  do
	. lock +^dataasalongvariablename45678901(i,"write")			;;; waits till the driver to tell us to start
	. set ^dataasalongvariablename45678901(i,"write","start")=$H
	. xecute ^dataasalongvariablename45678901(i,"write")
	. ;write ^dataasalongvariablename45678901(i,"write"),!
	. set ^dataasalongvariablename45678901(i,"write","x")=x
	. set ^dataasalongvariablename45678901(i,"write","y")=y
	. set ^dataasalongvariablename(i,"write","t")="This is a failing data-different variable though"
	. set ^dataasalongvariablename(i,"write","x")="This is a failing data-different variable though"
	. if $data(longstr)  do
	. . set longstr=$$shrnkstr^shrnkfil(longstr)
	. . set rxasalongvariablename2345678901=$$shrnkstr^shrnkfil(rxasalongvariablename2345678901)
	. . set rxasalongvariablename="This is a shorter variable.. so a different one"
	. zwrite
	. lock					;;; tells the driver we are done with this data
	. set ^clientflag(i)="FINISHED"
	; At this point, it is possible the server is still reading some data that the client wrote.
	; If we terminate now, it is possible for the server to receive a ECONNRESET from the read() system call
	; which would cause the server to read only partial data and cause a test failure. Therefore wait for
	; the server to be done with all reads before exiting from the client.
	for  quit:$get(^serverflag(i))="FINISHED"  hang 0.01
	quit
consrv	;;;	connect server without delimiter specified
	set portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim")
	set tcpdevasalongvariablename678901="server$"_$j,timeout=30
	set tcpdevasalongvariablename="which server?" ; this is a different variable for long names version !!!
	open tcpdevasalongvariablename678901:(LISTEN=portno_":TCP":attach="server":ioerror="TRAP"):timeout:"SOCKET"
	else  set now=$HOROLOG,^error(now,"server")="TEST-E-FAILED to open the socket device at "_$ZPOSITION  zshow "*":^error(now,"server")  halt
	use tcpdevasalongvariablename678901
	write /listen(1)
	write /wait(timeout)
	if $key="" set now=$HOROLOG,^error(now,"server")="TEST-E-FAILED to establish connection at "_$ZPOSITION  zshow "*":^error(now,"server")  halt
	set key=$key,childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	if $ztrnlnm("gtm_test_tls")="TRUE" do
	. write /tls("server",60,"server")
	. Set test=$test,tlsset=$$getkeyword^gethandle(tcpdevasalongvariablename678901,1,"TLS",1)
	. If (test=0)!(+$Device'=0)!(tlsset'="TLS") Do
	. . New dev,errtime Set dev=$Device,errtime=$H
	. . Set ^error(errtime,"server")="SOCDEV-E-FAILED to enable TLS: "_dev_" at "_$Zpos
	. . zshow "D":^error(errtime,"server","zshowd")
	. . Use $P Write "TLS server enable failed: "_dev,!
	. . goto err
	zshow "D":^zshowd("server")
	use $PRINCIPAL
	write !,"server connected : ",key,!
	quit
conclnt ;;;	connect client without delimiter specified
	set portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim"),hostname=^configasalongvariablename78901("hostname")
	set tcpdevasalongvariablename678901="client$"_$j,timeout=30
	open tcpdevasalongvariablename678901:(connect=hostname_":"_portno_":TCP":attach="client"):timeout:"SOCKET"
	else  set now=$HOROLOG,^error(now,"client")="TEST-E-FAILED to establish connection at "_$ZPOSITION  zshow "*":^error(now,"client")  halt
	write !,"client connected : ",!
	if $ztrnlnm("gtm_test_tls")="TRUE" do
	. set previo=$io use tcpdevasalongvariablename678901
	. write /tls("client",60)
	. Set test=$test,tlsset=$$getkeyword^gethandle(tcpdevasalongvariablename678901,0,"TLS",1)
	. If (test=0)!(+$Device'=0)!(tlsset'="TLS") Do
	. . New dev,errtime Set dev=$Device,errtime=$H
	. . Set ^error($H,"client")="SOCDEV-E-FAILED to enable TLS: "_dev_" at "_$Zpos
	. . zshow "D":^error(errtime,"client","zshowd")
	. . Use $P Write "TLS client enable failed: "_dev,!
	. . goto err
	. use previo
	zshow "D":^zshowd("client")
	set saveio=$IO use tcpdevasalongvariablename678901:ioerror="TRAP" use saveio
	quit
err	;;;;	error handler
	use $p
	zshow "*"
	halt
