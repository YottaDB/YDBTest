;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SERVER2(rdcnt)	;;; server2.m
	; Start up server, get a connection, write some data and close the data connection
server	s portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim")
	s tcpdevasalongvariablename678901="server$"_$j,timeout=30
	s:'$d(^cnt) ^cnt=0
	d log("SERVER2 START")
	u $p W !," Tcpserver being started...",!
	o tcpdevasalongvariablename678901:(LISTEN=portno_":TCP":attach="server":delimiter=delim):timeout:"SOCKET"
	i  d
	. u tcpdevasalongvariablename678901
	. s key=$Key
	. d log("Open serverport "_portno_" successfull, $key="_key)
	e  d log("Unable to open server port :"_portno)  q
	s parentsocket=$p(key,"|",2)
	u tcpdevasalongvariablename678901
	w /listen(1)
	i $P($key,"|",1)'="LISTENING"  d log("Unable to start listening")  c tcpdevasalongvariablename678901  q
	u tcpdevasalongvariablename678901
	w /wait(timeout)
	i $P($key,"|",1)'="CONNECT"  d log("Listening timed out, No connection")  c tcpdevasalongvariablename678901  q
	s key=$key
	s childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	d log("Connection established, socket="_childsocket_", ip="_ip)
	w "For the love of the game",delim,"My store by Michael Jordan",!
	if (rdcnt=4) d ^waitforread
	c tcpdevasalongvariablename678901
	q
log(str);
	l +^cnt
	s ^tcpasalongvariablename45678901(^cnt,$H,tcpdevasalongvariablename678901)=str,^cnt=^cnt+1
	s ^tcpasalongvariablename(^cnt,$H,tcpdevasalongvariablename678901)="This is not the right value"
	l
	q
