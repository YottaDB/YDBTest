;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2015 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; socketbasic.m
	;   test basic functionality of the socket device
	;   it tests:
	;	1. without delimiter, r x
	;	2. without delimiter, r x#3
	;	3. without delimiter, r x:20
	;	4. without delimiter, r x#3:20
	;	5. with delimiter, r x
	;	6. with delimiter, r x#3
	;	7. with delimiter, r x:20
	;	8. with delimiter, r x#3:20
	i '$d(^configasalongvariablename78901("portno"))  w !,"Usage: ^configasalongvariablename78901(""portno"") needs to be set to the port number to be used!",!  q
	i '$d(^configasalongvariablename78901("delim"))  w !,"Usage: ^configasalongvariablename78901(""delim"") needs to be set to the delimiter to be used!",!  q
	i '$d(^configasalongvariablename78901("hostname"))  w !,"Usage: ^configasalongvariablename78901(""hostname"") needs to be set to the hostname to be used!",!  q
	f i=1:1:^itemasalongvariablename45678901("total")  l +^itemasalongvariablename45678901(i)
	job client:(out="clientb.out":err="clientb.err")
	job server:(out="serverb.out":err="serverb.err")
	f i=1:1:^itemasalongvariablename45678901("total")  w !,i," starting ..."  l -^itemasalongvariablename45678901(i)  d waitforstart(i)  l +^itemasalongvariablename45678901(i)  w " finished "  d conclude
	q
waitforstart(i)
	set maxwait=300 ; wait for 5 minutes max
	set waitinterval=1 ; wait 1 sec at a time
	for j=1:1:maxwait quit:(($data(^itemasalongvariablename45678901(i,"read","start")))&($data(^itemasalongvariablename45678901(i,"write","start"))))  hang waitinterval
	if j=maxwait w "Timed out",! ZSHOW "*" halt
	quit
conclude
	i ^itemasalongvariablename45678901(i,"read","x","ref")'=^itemasalongvariablename45678901(i,"read","x")  w "FAILED x",!  zwr ^itemasalongvariablename45678901(i,"read","x",*)  q
	i '$d(^itemasalongvariablename45678901(i,"read","t","ref"))  w "PASS",!  q
	i ^itemasalongvariablename45678901(i,"read","t","ref")'=^itemasalongvariablename45678901(i,"read","t")  w "FAILED $T",!  zwr ^itemasalongvariablename45678901(i,"read","t",*)  q
	w "PASS",!
	q
server	;;;	the process that writes
	d consrv
	f i=1:1:^itemasalongvariablename45678901("total")  d
	. l +^itemasalongvariablename45678901(i,"write")			;;; waits till the driver to tell us to start
	. s ^itemasalongvariablename45678901(i,"write","start")=$H
	. x ^itemasalongvariablename45678901(i,"write")
	. s ^itemasalongvariablename45678901(i,"write","end")=$H
	. s ^itemasalongvariablename4567890(i,"write","end")="$H- This is to confuse GTM in case of variable truncation"
	. l					;;; tells the driver we are done with this item
	q
client  ;;;	the process that reads
	d conclnt
	f i=1:1:^itemasalongvariablename45678901("total")  d
	. s t=9,x="old"				;;; initialize t and x
	. l +^itemasalongvariablename45678901(i,"read")			;;; waits till the driver to tell us to start
	. s ^itemasalongvariablename45678901(i,"read","start")=$H
	. x ^itemasalongvariablename45678901(i,"read")
	. s ^itemasalongvariablename45678901(i,"read","end")=$H
	. s ^itemasalongvariablename45678901(i,"read","t")=t
	. s ^itemasalongvariablename45678901(i,"read","x")=x
	. s ^itemasalongvariablename4567890(i,"read","x")="to catch truncation of variable name"
	. l					;;; tells the driver we are done with this item
	q
consrv	;;;	connect server without delimiter specified
	s portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim")
	s tcpdevasalongvariablename678901="server$"_$j,timeout=30,^consrv("before")=$H
	s $ztrap="set $ZT="""" s zpos=$zpos,zstatus=$zstatus,zdev=$zdevice goto err"
	o tcpdevasalongvariablename678901:(ochset="M":LISTEN=portno_":TCP":attach="server":ioerror="T"):timeout:"SOCKET"
	e  s ^error($H,"server")="FAILED to open the socket device at "_$zpos  q
	u tcpdevasalongvariablename678901
	w /listen(1)
	w /wait(timeout)
	if $key="" s ^error($H)="FAILED to establish connection at "_$zpos  g err
	s key=$key,childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	if $ztrnlnm("gtm_test_tls")="TRUE" do
	. write /tls("server",60,"server")
	. Set test=$test,tlsset=$$getkeyword^gethandle(tcpdevasalongvariablename678901,1,"TLS",1)
	. If (test=0)!(+$Device'=0)!(tlsset'="TLS") Do
	. . New dev,errtime Set dev=$Device,errtime=$H
	. . Set ^error(errtime,"server")="SOCBASIC-E-FAILED to enable TLS: "_dev_" at "_$Zpos
	. . zshow "D":^error(errtime,"server","zshowd")
	. . Use $P Write "TLS server enable failed: "_dev,!
	. . goto err
	zshow "D":^zshowd("server")
	u $P
	w !,"server connected : ",key,!
	q
conclnt ;;;	connect client without delimiter specified
	S portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim"),hostname=^configasalongvariablename78901("hostname")
	S tcpdevasalongvariablename678901="client$"_$j,timeout=30,^conclnt("before")=$H
	s $ztrap="set $ZT="""" s zpos=$zpos,zstatus=$zstatus,zdev=$zdevice goto err"
	o tcpdevasalongvariablename678901:(ichset="M":connect=hostname_":"_portno_":TCP":attach="client":ioerror="t"):timeout:"SOCKET"
	e  s ^error($H,"client")="FAILED to establish connection at "_$zpos  q
	if $ztrnlnm("gtm_test_tls")="TRUE" do
	. set previo=$io use tcpdevasalongvariablename678901
	. write /tls("client",60)
	. Set test=$test,tlsset=$$getkeyword^gethandle(tcpdevasalongvariablename678901,0,"TLS",1)
	. If (test=0)!(+$Device'=0)!(tlsset'="TLS") Do
	. . New dev,errtime Set dev=$Device,errtime=$H
	. . Set ^error($H,"client")="SOCBASIC-E-FAILED to enable TLS: "_dev_" at "_$Zpos
	. . zshow "D":^error(errtime,"client","zshowd")
	. . Use $P Write "TLS client enable failed: "_dev,!
	. . goto err
	. use previo
	zshow "D":^zshowd("client")
	w !,"client connected : ",!
	q
err	;;;;	error handler
	u $p
	zshow "*"
	halt
