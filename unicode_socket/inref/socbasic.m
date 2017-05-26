;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2006, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
socbasic(encoding)
	;;; socketbasic.m
	set $ZT="set $ZT="""" g ERROR^socbasic"
	i '$d(^config("portno"))  w !,"Usage: ^config(""portno"") needs to be set to the port number to be used!",!  q
	i '$d(^config("delim"))  w !,"Usage: ^config(""delim"") needs to be set to the delimiter to be used!",!  q
	i '$d(^config("hostname"))  w !,"Usage: ^config(""hostname"") needs to be set to the hostname to be used!",!  q
	Write "Starting test with """,encoding,""" encoding"
	f i=1:1:^data("total")  l +^data(i)
	set cjob="job client("""_encoding_"""):(output="""_"clientb-"_encoding_".mjo"_""":error="""_"clientb-"_encoding_".mje"_""")"
	set sjob="job server("""_encoding_"""):(output="""_"serverb-"_encoding_".mjo"_""":error="""_"serverb-"_encoding_".mje"_""")"
	xecute cjob  set clientpid=$zjob
	xecute sjob  set serverpid=$zjob
	f i=1:1:^data("total")  w !,i," starting ..."  l -^data(i)  d waitforstart(i)  l +^data(i)  w " finished "  d conclude
	zsystem "wait_for_proc_to_die.csh "_clientpid_" 300"
	zsystem "wait_for_proc_to_die.csh "_serverpid_" 300"
	q
waitforstart(i)
	set maxwait=300 ; wait for 5 minutes max
	set waitinterval=1 ; wait 1 sec at a time
	for j=1:1:maxwait quit:(($data(^data(i,"read","start")))&($data(^data(i,"write","start"))))  hang waitinterval
	if j=maxwait w "Timed out",! ZSHOW "*" halt
	quit
conclude
	i ^data(i,"read","x","ref")'=$GET(^data(i,"read","x"))  w "FAILED read x",!  zwr ^data(i,"read","x",*)  q
	i '$d(^data(i,"read","t","ref"))  w "PASS",!  q
	i ^data(i,"read","t","ref")'=$GET(^data(i,"read","t"))  w "FAILED $T",!  zwr ^data(i,"read","t",*)  q
	w "PASS",!
	q
server(encoding)	;;;	the process that writes
	set $ZT="set $ZT="""" g ERROR^socbasic"
	d consrv(encoding)
	f i=1:1:^data("total")  d
	. l +^data(i,"write")			;;; waits till the driver to tell us to start
	. write "Iter = ",i,"  ",$h,!
	. write ^data(i,"write"),!
	. s ^data(i,"write","start")=$H
	. x ^data(i,"write")		; This causes writes
	. s ^data(i,"write","end")=$H
	. u $P  write "$key=",$key,!
	. l					;;; tells the driver we are done with this item
	close tcpdev
	q
client(encoding) ;;;	the process that reads
	set $ZT="set $ZT="""" g ERROR^socbasic"
	d conclnt(encoding)
	f i=1:1:^data("total")  d
	. s t=9,x="old"				;;; initialize t and x
	. l +^data(i,"read")			;;; waits till the driver to tell us to start
	. write "Iter = ",i,"  ",$h,!
	. write ^data(i,"read"),!
	. s ^data(i,"read","start")=$H
	. x ^data(i,"read")		; Causes reads
	. s ^data(i,"read","end")=$H
	. s ^data(i,"read","t")=t	; Truth value
	. s ^data(i,"read","x")=x	; Value read
	. u tcpdev  read dummy:0  use 0		; Just to clear unread data buffer
	. u $P  write "$key=",$key,!
	. l					;;; tells the driver we are done with this item
	close tcpdev
	q
consrv(encoding)	;;;	connect server without delimiter specified
	s portno=^config("portno"),delim=^config("delim")
	s tcpdev="server$"_$j,timeout=30
	if encoding="" set openarg="(ZLISTEN="""_portno_":TCP"""_":attach=""server"":ioerror=""t"")"
	else  set openarg="(ochset="""_encoding_""":ZLISTEN="""_portno_":TCP"""_":attach=""server"":ioerror=""t"")"
	write "openarg=",openarg,!
	open tcpdev:@openarg:timeout:"SOCKET"
	e  s ^error($H,"server")="SOCBASIC-E-FAILED to open socket at "_$zpos  use 0 w "open failed : $zstatus=",$zstatus,! h
	u tcpdev
	w /listen(1)
	w /wait(timeout)
	if $key=""  s ^error($H,"server")="SOCBASIC-E-FAILED to establish connection at "_$zpos  use 0 w "open failed : $zstatus=",$zstatus,! h
	s key=$key,childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	u $P
	write "$key="  zwr key
	w !,"server connected : ",!
	q
conclnt(encoding) ;;;	connect client without delimiter specified
	S portno=^config("portno"),delim=^config("delim"),hostname=^config("hostname")
	S tcpdev="client$"_$j,timeout=30
	if encoding="" set openarg="(connect="""_hostname_":"_portno_":TCP"""_":attach=""client"":ioerror=""t"")"
	else  set openarg="(ichset="""_encoding_""":connect="""_hostname_":"_portno_":TCP"""_":attach=""client"":ioerror=""t"")"
	write "openarg=",openarg,!
	open tcpdev:@openarg:timeout:"SOCKET"
	e  s ^error($H,"client")="SOCBASIC-E-FAILED to open socket connection at "_$zpos  use 0 w "open failed : $zstatus=",$zstatus,! h
	w !,"client connected : ",!
	q
ERROR	use $P
	ZSHOW "*"
	halt
