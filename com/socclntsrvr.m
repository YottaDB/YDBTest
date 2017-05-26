socclntsrvr(unicode)	;;; socclntsrvr.m
	;   test client server usage of the socket device
	;	The test starts up a server and waits for client connections or service requests
	;	three different kinds of services
	;	a) time server: client will get time from the server, and the time should not 
	;	   differ from the time on client a lot
	;	b) host server: client will get the name of the host, and it actually should be the
	;	   same as where the client is at
	;	c) echo server: client should get whatever it wrote to the server
	;
	; ----------------------------------- configure the test ----------------------------------------------
	i '$d(^configasalongvariablename78901("portno"))   w !,"Usage: ^configasalongvariablename78901(""portno"") needs to be set to the port number to be used!",!  q
	i '$d(^configasalongvariablename78901("delim"))    w !,"Usage: ^configasalongvariablename78901(""delim"") needs to be set to the delimiter to be used!",!  q
	i '$d(^configasalongvariablename78901("hostname")) w !,"Usage: ^configasalongvariablename78901(""hostname"") needs to be set to the hostname to be used!",!  q
	i '$d(^configasalongvariablename78901("jobnum"))     s ^configasalongvariablename78901("jobnum")=5	; default job number
	i '$d(^configasalongvariablename78901("iteration"))  s ^configasalongvariablename78901("iteration")=10  ; default number of operations each client does
	i '$d(^configasalongvariablename78901("naprange"))   s ^configasalongvariablename78901("naprange")=5	; default sleep time range for clients
	; ------------------------ initialize counters and conclusion global  ----------------------------------
	s ^configasalongvariablename78901("jobfinished","client")=0,^configasalongvariablename78901("jobfinished","server")=0,^count=0
	i $d(^configasalongvariablename78901("conclusion"))  k ^configasalongvariablename78901("conclusion")
	i $d(^error)  k ^error
	; ------------------------ job off clients after grabbing the sync lock --------------------------------
	l +^itemasalongvariablename45678901
	set jmaxwait=0
	i $ZVersion'["VMS"  do ^job("client^socclntsrvr",^configasalongvariablename78901("jobnum"),unicode)
	e  f i=1:1:^configasalongvariablename78901("jobnum")  d  
	. job @("client(unicode):(nodetached:startup=""startup.com"":out=""client"_i_".out"":err=""client"_i_".err"")")
	; ------------------------ start the server up and release the lock to activate clients ----------------
	s portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim"),tcpdevasalongvariablename678901="server$"_$j,timeout=30
	o tcpdevasalongvariablename678901:(ZLISTEN=portno_":TCP":attach="server":zbfsize=4096:delim=^configasalongvariablename78901("delim")):timeout:"SOCKET"
	e  d error("server","FAILED to open the socket device at "_$zpos)  q
	u tcpdevasalongvariablename678901
	w /listen(5)
	l -^itemasalongvariablename45678901
	; ------------------------------------------- service --------------------------------------------------
	s cnt=0,done=0
	f  d   q:done'=0
	. ;;; are we done yet or is there an error
	. i ^configasalongvariablename78901("jobfinished","server")=^configasalongvariablename78901("jobnum")  s done=1  q
	. i cnt=3600  s done=1  q
	. i $d(^error)  s done=1  q
	. ;;; do real work here
	. s cnt=cnt+1
	. u tcpdevasalongvariablename678901
	. w /wait(3)
	. s key=$key
	. i $l(key)=0  d log("server","WAIT TIMEOUT: nothing new")  q
	. d log("server","WAIT GOT: "_key)
	. s action=$piece(key,"|",1),handle=$piece(key,"|",2),rhost=$piece(key,"|",3)
	. i action="CONNECT"  d log("server","ESTABLISHED CONNECTION: "_handle)  q
	. i action="READ"  d
	. . d log("server","DATA AVAILABLE: "_handle)
	. . r x:5
	. . e  d error("server","How could we get a timeout here?")  q
	. . i $zeof  d	 q		; lost connection
	. . . d log("server","CLOSED CONNECTION: "_handle)
	. . . s ^configasalongvariablename78901("jobfinished","server")=^configasalongvariablename78901("jobfinished","server")+1
	. . . c tcpdevasalongvariablename678901:socket=handle
	. . s service=$extract(x,1,4)
	. . i service="ECHO"  d   q
	. . . ; u 0   w x,!,$extract(x,5,999),!   
	. . . u tcpdevasalongvariablename678901
	. . . d log("server",service_" requested")
	. . . w $extract(x,5,999),!
	. . . d log("server",service_" served")
	. . i service="TIME"  d   q
	. . . d log("server",service_" requested")
	. . . w $H,!
	. . . d log("server",service_" served")
	. . i service="HOST"  d   q
	. . . d log("server",service_" requested")
	. . . w ^configasalongvariablename78901("hostname"),!  
	. . . d log("server",service_" served")
	. . d error("server","Service "_service_" unknown!!!")
	c tcpdevasalongvariablename678901
	; ------------------------------------------- conclude the test ----------------------------------------
	u 0  w !,$s($d(^error):"FAIL",1:"PASS"),!
	i $ZVersion'["VMS"  do wait^job
	q 
log(side,content)
	tstart ():serial
	s ^statusasalongvariablename678901(^count,$H,side)=content,^count=^count+1
	tcommit
	q
error(side,content)
	tstart ():serial
	s ^error(^count,side)=content
	tcommit
	u $p
	zwr ^error
	q
client(unicode)  ;;;	the process that reads
	h $random(^configasalongvariablename78901("naprange"))+1 		;;; take a nap first
	S portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim"),hostname=^configasalongvariablename78901("hostname")
	S tcpdevasalongvariablename678901="client$"_$j,timeout=30,socket=hostname_":"_portno_":TCP"
	w !,"client : ",tcpdevasalongvariablename678901,!
	l +^itemasalongvariablename45678901(tcpdevasalongvariablename678901)				;;; sync with server
	o tcpdevasalongvariablename678901:(connect=socket:attach=tcpdevasalongvariablename678901:zbfsize=4096:delim=^configasalongvariablename78901("delim")):timeout:"SOCKET"
	e  d error("client","socket "_socket_" connect failed")  q
	d log("client","ESTABLISHED CONNECTION: "_socket)
	;;; take a random service request
	f i=1:1:^configasalongvariablename78901("iteration")  d  q:$d(^error)
	. u tcpdevasalongvariablename678901
	. s rn=$random(3)+1
	. s service=$select(rn=1:"TIME",rn=2:"HOST",1:"ECHO")
	. d @service
	c tcpdevasalongvariablename678901
	tstart ():serial
	s ^configasalongvariablename78901("jobfinished","client")=^configasalongvariablename78901("jobfinished","client")+1
	tcommit
	q
TIME	s ltime=$H 
	w service,!  
	r rtime:30
	e  d error("client",socket_" failed in "_service_"service, timeout")  q
	s dtime=($p(rtime,",",1)-$p(ltime,",",1))*60*60*24+$p(rtime,",",2)-$p(ltime,",",2)
	i dtime<5  s message=i_" PASS "_service_" "_socket_" "_dtime
	e  s message=i_" FAIL "_service_" "_socket_" "_dtime  d error("client",message)
	d log("client",message)
	u 0  w !,message,!
	q
HOST	w service,!
	r result:30
	e  d error("client",socket_" failed in "_service_"service, timeout")  q
	i result=hostname  s message=i_" PASS "_service_" "_socket_" "_result
	e  s message=i_" FAIL "_service_" "_socket_" "_result  d error("client",message)
	d log("client",message)
	u 0  w !,message,!
	q
ECHO	s stuff="live free or die, which state?"
	if 1=unicode  set stuff=stuff_$char(2351)_$char(2361)_$char(32)_$char(2354)_$char(2327) 
	w service_stuff,!
	r result:30
	e  d error("client",socket_" failed in "_service_"service, timeout")  q
	i result=stuff  s message=i_" PASS "_service_" "_socket
	e  s message=i_" FAIL "_service_" "_socket_" "_result  d error("client",message)
	d log("client",message)
	u 0  w !,message,! 	; ,"Should be: ",stuff,!,"Got: ",result,!
	q
