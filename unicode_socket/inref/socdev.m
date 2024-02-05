;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
; Portions Copyright (c) Fidelity National			;
; Information Services, Inc. and/or its subsidiaries.		;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

socdev(encoding)
	;;; socdev.m
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
	set $ZT="set $ZT="""" g ERROR^socdev"
	if '$DATA(^config("portno"))  write !,"Usage: ^config(""portno"") needs to be set to the port number to be used!",!  quit
	if '$DATA(^config("hostname"))  write !,"Usage: ^config(""hostname"") needs to be set to the hostname to be used!",!  quit
	Write "Starting test with """,encoding,""" encoding",!
	for i=1:1:^data("total")  lock +^data(i)
	set cjob="job client("""_encoding_"""):(output="""_"clientb-"_encoding_".mjo"_""":error="""_"clientb-"_encoding_".mje"_""")"
	set sjob="job server("""_encoding_"""):(output="""_"serverb-"_encoding_".mjo"_""":error="""_"serverb-"_encoding_".mje"_""")"
	xecute cjob set pid($incr(pid))=$zjob
	xecute sjob set pid($incr(pid))=$zjob
	for i=1:1:^data("total")  do
	. write !,i," starting ..."
	. lock -^data(i)
	. do waitforstart(i)
	. l +^data(i)
	. write " finished "
	. d conclude
	; wait for backgrounded process to terminate before returning to caller script
	for i=1:1:pid do ^waitforproctodie(pid(i),300)
	quit
waitforstart(i)
	set maxwait=300 ; wait for 5 minutes max
	set waitinterval=1 ; wait 1 sec at a time
	for j=1:1:maxwait quit:(($data(^data(i,"read","start")))&($data(^data(i,"write","start"))))  hang waitinterval
	if j'<maxwait write "Timed out",! ZSHOW "*" halt
	quit
conclude
	; stats from the last socket transfer
	write !,"total chars written = "_^data(i,"read","x","ref"),!
	write "total chars read = "_$GET(^data(i,"read","x")),!
	if ($DATA(^data(i,"read","x","bref"))) write "total bytes processed = "_$GET(^data(i,"read","x","bref")),!
	if ($DATA(^data(i,"read","x","dref"))) write "number of bytes in the delimiter = "_$GET(^data(i,"read","x","dref")),!
	;;;
	if ^data(i,"read","x","ref")'=$GET(^data(i,"read","x"))  write "TEST-E-FAILED read x",!  zwrite ^data(i,"read","x",*)  w "GET VALUE IS " w $GET(^data(i,"read","x")) w "end" quit
	if '$DATA(^data(i,"write","x","xref"))!'$DATA(^data(i,"write","y","yref")) write "PASS",! quit
	;; if ^data(i,"read","t","ref")'=$GET(^data(i,"read","t"))  write "TEST-E-FAILED $T",!  zwrite ^data(i,"read","t",*)  quit
	if $DATA(^data(i,"write","x","xref")) if ^data(i,"write","x","xref")'=^data(i,"write","x") write "TEST-E-FAILED $X",!  zwrite ^data(i,"write","x",*)  quit
	if $DATA(^data(i,"write","y","yref")) if ^data(i,"write","y","yref")'=^data(i,"write","y") write "TEST-E-FAILED $Y",!  zwrite ^data(i,"write","y",*)  quit
	write "PASS",!
	quit
server(encoding)
	;;;	the process that reads
	set $ZT="set $ZT="""" g ERROR^socdev"
	use $PRINCIPAL:(WIDTH=1048576)
	do consrv(encoding)
	for i=1:1:^data("total")  do
	. write "------------------------------------------------------------------",!
	. set t=9
	. lock +^data(i,"read")			;;; waits till the driver to tell us to start
	. write "Iter = ",i,"  ",$h,!
	. write ^data(i,"read"),!
	. s ^data(i,"read","start")=$H
	. set delim=^delim(i)
	. xecute ^data(i,"read")
	. set ^data(i,"read","t")=t
	. set ^data(i,"read","x")=x
	. u tcpdev  if '$ZEOF read dummy:0  use 0		; Just to clear unread data buffer
	. u $P   write "$key=",$key,!
	. if $data(longstr)  do
	. . if longstr='$$^ulongstr($zlength(longstr)) write "TEST failed longstr is not expected as ulongstr generates",!
	. . if rx='$$^ulongstr($zlength(rx)) write "TEST failed longstr is not expected as ulongstr generates",!
	. ;zwrite
	. lock					;;; tells the driver we are done with this data
	. set ^serverflag(i)="FINISHED"
	quit
client(encoding)
	;;;	the process that writes
	set $ZT="set $ZT="""" g ERROR^socdev"
	use $PRINCIPAL:(WIDTH=1048576)
	do conclnt(encoding)
	set x=0,y=0
	for i=1:1:^data("total")  do
	. lock +^data(i,"write")			;;; waits till the driver to tell us to start
	. write "Iter = ",i,"  ",$h,!
	. write ^data(i,"write"),!
	. s ^data(i,"write","start")=$H
	. set delim=^delim(i)
	. xecute ^data(i,"write")
	. set ^data(i,"write","x")=x
	. set ^data(i,"write","y")=y
	. u $P  write "$key=",$key,!
	. if $data(longstr)  do
	. . if longstr='$$^ulongstr($zlength(longstr)) write "TEST failed",!
	. . if rx='$$^ulongstr($zlength(rx)) write "TEST failed",!
	. . set rxasalongvariablename="This is a shorter variable.. so a different one"
	. ;zwrite
	. lock					;;; tells the driver we are done with this data
	. set ^clientflag(i)="FINISHED"
	quit
consrv(encoding)
	;;;	connect server without delimiter specified
	set portno=^config("portno")
	set tcpdev="server$"_$j,timeout=30
	set tcpdevasalongvariablename="which server?" ; this is a different variable for long names version !!!
	if encoding="" set openarg="(ZLISTEN="""_portno_":TCP"""_":attach=""server"":ioerror=""TRAP"")"
	else  set openarg="(ochset="""_encoding_""":ZLISTEN="""_portno_":TCP"""_":attach=""server"":ioerror=""TRAP"")"
	write "openarg=",openarg,!
	open tcpdev:@openarg:timeout:"SOCKET"
	else  set ^error($HOROLOG,"server")="SOCDEV-E-FAILED to open socket at "_$zpos  use 0  w "open failed : $zstatus=",$zstatus,! h
	use tcpdev
	write /listen(1)
	write /wait(timeout)
	else  set ^error($HOROLOG,"server")="SOCDEV-E-FAILED to establish connection at "_$zpos  use 0  w "open failed : $zstatus=",$zstatus,! h
	set key=$key,childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	use $PRINCIPAL
	write !,"server connected : ",key,!
	quit
conclnt(encoding)
	;;;	connect client without delimiter specified
	set portno=^config("portno"),hostname=^config("hostname")
	set tcpdev="client$"_$j,timeout=30
	if encoding="" set openarg="(connect="""_hostname_":"_portno_":TCP"""_":attach=""client"")"
	else  set openarg="(ichset="""_encoding_""":connect="""_hostname_":"_portno_":TCP"""_":attach=""client"")"
	write "openarg=",openarg,!
	open tcpdev:@openarg:timeout:"SOCKET"
	else  set ^error($H,"client")="SOCDEV-E-FAILED to establish connection at "_$zpos  use 0  w "open failed : $zstatus=",$zstatus,! h
	write !,"client connected : ",!
        set saveio=$IO use tcpdev:ioerror="TRAP" use saveio
	quit
ERROR	use $P
	ZSHOW "*"
	halt
