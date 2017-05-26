;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; ipv6basic.m
	;   test basic functionality of ipv6
start(testnum)
	use 0
	if '$data(^config("portno"))  write !,"Usage: ^config(""portno"") needs to be set to the port number to be used!",!  quit
	if '$data(^config("delim"))  write !,"Usage: ^config(""delim"") needs to be set to the delimiter to be used!",!  quit
	if '$data(^config("hostname",testnum))  write !,"Usage: ^config(""hostname"",testnum) needs to be set to the hostname to be used!",!  quit
	set ^servermsg="abcd"
	set ^clientmsg="efgh"
	set num=testnum
	job @("client(num):(out=""client"_num_".out"":err=""client"_num_".err"")")
	set clientjob=$zjob
	do server(num)
	use 0
	do ^waitforproctodie(clientjob,600)
	write !," finished ",!
	quit
server(testnum)	;;;	server socket without delimiter specified
	set portno=^config("portno"),delim=^config("delim")
	set tcpdev="server$"_$job,timeout=120
	open tcpdev:(LISTEN=portno_":TCP":attach="server"):timeout:"SOCKET"
	else  set ^error($Horolog,"server")="FAILED to open the socket device at "_$zposition  quit
	use tcpdev
	write /listen(1)
	write /wait(timeout)
	else  set ^error($Horolog)="FAILED to establish connection at "_$zposet  quit
	set key=$key,ip=$p(key,"|",3)
	use $P
	write !,"Server "_testnum_" connected : GTM_TEST_DEBUGINFO ",ip,!
	do showaddr
	use tcpdev
	write ^servermsg
	read y#4:timeout
	use $p
	if (y'=^clientmsg) set ^error($Horolog,"server")="FAILED to receive data from client " quit
	close tcpdev:(DESTROY);
	quit
client(testnum)  ;;;	client socket without delimiter specified
	set portno=^config("portno"),delim=^config("delim")
	set hostname=^config("hostname",testnum)
	set tcpdev="client$"_$j,timeout=120
	open tcpdev:(connect=hostname_":"_portno_":TCP":attach="client"):timeout:"SOCKET"
	else  set ^error($Horolog,"client")="FAILED to establish connection at "_$zposet  quit
	use $p write !,"Client "_testnum_" connected : ",!
	do showaddr
	use tcpdev
	write ^clientmsg
	read x#4:timeout
	use $p
	if (x'=^servermsg) set ^error($Horolog,"client")="FAILED to receive data from server " quit
	close tcpdev:(DESTROY);
	quit
showaddr ;performs a ZSHOW on the device requested
	set foundremote=0
	set prevdev=$IO
        ZSHOW "D":showtmp
	use $PRINCIPAL
        set tmp="showtmp"
        for  set tmp=$QUERY(@tmp) quit:tmp=""  do
        . if $F(@tmp,"REMOTE") write "ZSHOW ""D"" output: ",@tmp,!  set foundremote=1
	if foundremote=0 write "REMOTE NOT FOUND",!,"BEGIN Full ZSHOW ""D""",!  zwrite showtmp  write "END Full ZSHOW ""D""",!
	use prevdev
	quit
	;
