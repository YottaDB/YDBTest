;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; waittimeout.m
	;
	; Test socket timeouts in various use cases
	;
	if '$DATA(^configasalongvariablename78901("portno"))  do
	. write !,"Usage: ^configasalongvariablename78901(""portno"") needs to be set to the port number to be used!",!
	. halt
	if '$DATA(^configasalongvariablename78901("delim"))  do
	. write !,"Usage: ^configasalongvariablename78901(""delim"") needs to be set to the delimiter to be used!",!
	. halt
	if '$DATA(^configasalongvariablename78901("hostname"))  do
	. write !,"Usage: ^configasalongvariablename78901(""hostname"") needs to be set to the hostname to be used!",!
	. halt
	;
	set slist=$piece($text(scenarios),";",2)
	for  set scenario=$piece(slist,",",$incr(snum))  quit:scenario=""  do
	. write !,scenario_" started",!
	. do @scenario
	. write scenario_" completed",!
	write !,"Done.",!
	halt

scenarios ;listentimeout,readtimeout,readwaittimeout,notimeout,notimeoutwait,opentimeout;,defqueueoverflow,queueoverflow

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

listentimeout
	; Test timeout on wait for listening socket.
	; we want a listen wait timeout, so set it short
	do startserver("server_cwt","connection wait timeout",,0,1)
	do serverendwait("server_cwt")
	quit

readtimeout
	; Test timeout on socket read
	do startserver("server_rt","read timeout",,1)
	; we want a read timeout, so keep it short
	do startclient("client_rt","read timeout","readone(1)")
	do clientendwait("client_rt")
	do serverendwait("server_rt",1)
	quit

readwaittimeout
	; Test timeout on wait for reading socket
	do startserver("server_rwt","read wait timeout",,1)
	; we want a wait timeout, so keep it short
	do startclient("client_rwt","read wait timeout","waitandreadone(1)")
	do clientendwait("client_rwt")
	do serverendwait("server_rwt",1)
	quit

notimeout
	; Test that read does not time out when there is data to read
	do startserver("server_nt","no timeout","writeone",1)
	do startclient("client_nt","no timeout","readone(60)")
	do clientendwait("client_nt")
	do serverendwait("server_nt",1)
	quit

notimeoutwait
	; Test that wait on read socket does not time out when there is data to read
	do startserver("server_ntw","no timeout with wait","writeone",1)
	do startclient("client_ntw","no timeout with wait","waitandreadone(60)")
	do clientendwait("client_ntw")
	do serverendwait("server_ntw",1)
	quit

opentimeout
	; Test timeout on open of listening socket.
	do startserver("server_ot_1","open timeout 1",,1)
	do startclient("client_ot","open timeout",,1)
	; we want an open timeout, so set it short
	do startserver("server_ot_2","open timeout 2",,,1,,0)
	do serverendwait("server_ot_2")
	do serverendwait("server_ot_1",1)
	do clientendwait("client_ot",1)
	quit

defqueueoverflow
	; Test having more clients connecting than the default queue length
	new clients,i
	set clients=25
	do startserver("server_defqofl","default queue overflow","lsofme",1)
	for i=1:1:clients do startclient("client_defqofl_"_i,"default queue overflow client "_i,"lsofme",1)  hang 1
	for i=1:1:clients do clientendwait("client_defqofl_"_i,i)
	do serverendwait("server_defqofl")
	quit

queueoverflow
	; Test having more clients connecting than the specified queue length
	new clients,i
	set clients=25,qlen=5
	do startserver("server_qofl","queue overflow","lsofme",1,,qlen)
	for i=1:1:clients do startclient("client_qofl_"_i,"queue overflow client "_i,"lsofme",1)  hang 1
	for i=1:1:clients do clientendwait("client_qofl_"_i,i)
	do serverendwait("server_qofl")
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readone(timeout)
	new x
	read x:timeout
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on read at "_$ZPOSITION,!  zwrite err  halt
	quit

writeone
	write "blahblahblah",!
	quit

wait(timeout)
	write /wait(timeout)
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on wait at "_$ZPOSITION,!  zwrite err  halt
	quit

waitandreadone(timeout)
	do wait(timeout)
	do readone(timeout)
	quit

lsofme
	zsystem "lsof -p "_$job
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

startserver(shortname,description,serviceroutine,syncdone,timeout,qlen,useuselisten,maxtries,tryinterval,outfile,errfile)
	set:'$data(serviceroutine) serviceroutine=""
	set:'$data(timeout) timeout=60
	set:'$data(qlen) qlen=0
	set:'$data(useuselisten) useuselisten=$piece($horolog,",",2)#2	; cheap coin flip
	set:'$data(maxtries) maxtries=600
	set:'$data(tryinterval) tryinterval=0.1
	set:'$data(outfile) outfile=shortname_".out"
	set:'$data(errfile) errfile=shortname_".err"
	set ^serverready(shortname)=0,tries=0
	lock +^serverstartsync(shortname)			; block server startup
	lock:$get(syncdone) +^serverdonesync(shortname)		; block server shutdown
	if $ZVERSION'["VMS"  do
	. job @("server(shortname,timeout,serviceroutine,qlen,useuselisten):(out="""_outfile_""":err="""_errfile_""")")
	else  do
	. job @("server^waittimeout(shortname,timeout,serviceroutine,qlen,useuselisten):(detached:startup=""startup.com"":out="""_outfile_""":err="""_errfile_""")")
	for  quit:^serverready(shortname)  quit:$increment(tries)>maxtries  hang tryinterval
	if tries>maxtries  write !,"Server startup timed out at "_$STACK($STACK(-1)-1,"PLACE"),!  halt
	lock -^serverstartsync(shortname)			; allow server to proceed
	quit

serverendwait(shortname,syncdone,timeout)
	set:'$data(timeout) timeout=60
	lock:$get(syncdone) -^serverdonesync(shortname)		; allow server to finish
	lock +^serverrunning(shortname):timeout			; wait for server to finish
	else  write !,"Server done sync timeout at "_$stack($stack(-1)-1,"PLACE"),!  halt
	lock -^serverrunning(shortname)				; allow next server to run
	quit

startclient(shortname,description,serviceroutine,syncdone,timeout,maxtries,tryinterval,outfile,errfile)
	set:'$data(timeout) timeout=60
	set:'$data(maxtries) maxtries=600
	set:'$data(serviceroutine) serviceroutine=""
	set:'$data(tryinterval) tryinterval=0.1
	set:'$data(outfile) outfile=shortname_".out"
	set:'$data(errfile) errfile=shortname_".err"
	set ^clientready(shortname)=0,tries=0
	lock +^clientstartsync(shortname)			; block client startup
	lock:$get(syncdone) +^clientdonesync(shortname)		; block client shutdown
	if $ZVERSION'["VMS"  do
	. job @("client(shortname,timeout,serviceroutine):(out="""_outfile_""":err="""_errfile_""")")
	else  do
	. job @("client^waittimeout(shortname,timeout,serviceroutine):(detached:startup=""startup.com"":out="""_outfile_""":err="""_errfile_""")")
	; wait for client ready
	for  quit:^clientready(shortname)  quit:$increment(tries)>maxtries  hang tryinterval
	lock -^clientstartsync(shortname)			; allow client to proceed
	quit

clientendwait(shortname,syncdone,timeout)
	set:'$data(timeout) timeout=60
	lock:$get(syncdone) -^clientdonesync(shortname)		; allow client to finish
	lock +^clientrunning(shortname):timeout			; wait for client to finish
	else  write !,"Client done sync timeout at "_$stack($stack(-1)-1,"PLACE")_" for "_shortname,!  halt
	lock -^clientrunning(shortname)				; allow next client to run
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

server(id,socktimeout,serviceroutine,qlen,useuselisten)
	set $ETRAP="USE $P  ZSHOW ""*""  HALT"
	set portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim")
	set tcpdevasalongvariablename678901="server$"_$j
	lock +^serverrunning(id)			; released when done (including on halt)
	set ^serverready(id)=1,lktimeout=60
	lock +^serverstartsync(id):lktimeout		; wait for permission to proceed
	else  write !,"Server start sync timeout at "_$ZPOSITION,!  halt
	if useuselisten  do
	. open tcpdevasalongvariablename678901:(ioerror="TRAP"):socktimeout:"SOCKET"
	. else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on server open at "_$ZPOSITION,!  zwrite err  halt
	. use tcpdevasalongvariablename678901:(LISTEN=portno_":TCP")
	if 'useuselisten  do
	. open tcpdevasalongvariablename678901:(LISTEN=portno_":TCP":attach="server":ioerror="TRAP"):socktimeout:"SOCKET"
	. else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on server open at "_$ZPOSITION,!  zwrite err  halt
	use tcpdevasalongvariablename678901
	write:$get(qlen)>0 /listen(qlen)
	write /wait(socktimeout)
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on server connection wait at "_$ZPOSITION,!  zwrite err  halt
	if $key=""  zshow "*":err  use $p  write "TEST-E-FAILED with unknown error at "_$ZPOSITION,!  zwrite err  halt
	set key=$key,childsocket=$p(key,"|",2),ip=$p(key,"|",3)
	use $PRINCIPAL
	write !,"server connected : ",key,!
	if $data(serviceroutine),serviceroutine'=""  use tcpdevasalongvariablename678901  do @serviceroutine
	lock +^serverdonesync(id):lktimeout		; wait for permission to exit
	halt

client(id,socktimeout,serviceroutine)
	set $ETRAP="USE $P  ZSHOW ""*""  HALT"
	set portno=^configasalongvariablename78901("portno"),delim=^configasalongvariablename78901("delim"),hostname=^configasalongvariablename78901("hostname")
	set tcpdevasalongvariablename678901="client$"_$j
	lock +^clientrunning(id)			; released when done (including on halt)
	set ^clientready(id)=1,lktimeout=60
	lock +^clientstartsync(id):lktimeout		; wait for permission to proceed
	else  write !,"Client start sync timeout at"_$ZPOSITION,!  halt
	open tcpdevasalongvariablename678901:(connect=hostname_":"_portno_":TCP":attach="client"):socktimeout:"SOCKET"
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on client connection connect at "_$ZPOSITION,!  zwrite err  halt
	write !,"client connected",!
	if $data(serviceroutine),serviceroutine'=""  use tcpdevasalongvariablename678901  do @serviceroutine
	lock +^clientdonesync(id):lktimeout		; wait for permission to exit
	halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
