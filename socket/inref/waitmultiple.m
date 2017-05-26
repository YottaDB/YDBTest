;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;; waitmultiple.m
	;
	; Test waiting when multiple sockets in various use cases
	;
	if '$DATA(^config("portno"))  do
	. write !,"Usage: ^config(""portno"") needs to be set to the first port number or path to be used!",!
	. halt
	if '$DATA(^config("portno2"))  do
	. write !,"Usage: ^config(""portno2"") needs to be set to the second port number or path to be used!",!
	. halt
	if '$DATA(^config("delim"))  do
	. write !,"Usage: ^config(""delim"") needs to be set to the delimiter to be used!",!
	. halt
	if '$DATA(^config("hostname"))  do
	. write !,"Usage: ^config(""hostname"") needs to be set to the first hostname to be used or LOCAL!",!
	. halt
	if '$DATA(^config("hostname2"))  set ^config("hostname2")=^config("hostname")
	;
	set ^wait=0
	set slist=$piece($text(scenarios),";",2)
	for  set ^scenario=$piece(slist,",",$incr(snum))  quit:^scenario=""  do
	. write !,^scenario_" started",!
	. do @^scenario
	. write ^scenario_" completed",!
	write !,"Done.",!
	halt

scenarios ;dobufchk,doreadord,doconnpri,doconn3;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dobufchk
	; Test checking the internal buffer for data
	do startserver("server_bfc","buffer check",,1,40)
	do startclient("client_bfc","buffer check","bufchk",0,40)
	do serverendwait("server_bfc",1,120)
	do clientendwait("client_bfc",0,120)
	quit

doreadord
	; Test order of READs with two sockets
	do startserver("server_rdo","read order",,1,40)
	do startclient("client_rdo","read order","readord",0,40)
	do serverendwait("server_rdo",1,80)
	do clientendwait("client_rdo",0,80)
	quit

doconnpri
	; Test priority of connections over reads
	do startserver("server_cpr","wait order",,1,40,5)
	do startclient("client_cpr","wait order","connpri",0,40)
	do serverendwait("server_cpr",1,120)
	do clientendwait("client_cpr",0,120)
	quit

doconn3
	; Test multiple connection requests
	do startserver("server_c3","multiple connections",,1,40,5)
	do startclient("client_c3","multiple connections","conn3",0,40)
	do serverendwait("server_c3",1,120)
	do clientendwait("client_c3",0,120)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufchk	;client1 conn0 write>10 holdserver write>10 conn1 releaseserver write>10
	; server should get conn0,read0,conn1,read0,read0,read0,read1,read1
	set ^bufchk("waitstart")=^wait_"|"_$H
	set ^readhold=0,maxtries=600,tries=0,^clientdone=0
	set wait=^wait+1	; so can use naked reference
	set ^expect(wait)="CONN",^(wait+1)="READ",^(wait+2)="CONN",^(wait+3)="READ",^(wait+4)="READ",^(wait+5)="READ",^(wait+6)="READ",^(wait+7)="READ"
	open sockdev:(connect=conn0:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^bufchk(clientnum)
	set ^readonce=$H	; only read part of next write
	use sockdev w string1 set ^bufchk(clientnum,"W",1,$H)=string1
	for  quit:^readhold'=0  hang 1 quit:$increment(tries)'<maxtries
	set ^holdserver=$H_"|"_^wait
	write string2 set ^bufchk(clientnum,"W",2,$H)=string2
	open sockdev:(connect=conn1:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^bufchk(clientnum)
	set (^readhold,^holdserver)=0,^bufchk("zeroholdserver",^wait)=$H
	use sockdev:socket="client"_clientnum
	write string1 set ^bufchk(clientnum,"W",1,$H)=string1
	hang 1		; let server run
	set ^clientdone=$H
	; hang socktimeout		; let server read
	lock +^serverended("server_bfc"):socktimeout	; wait for server to finish or timeout
	else  set ^bufchk("serverendedto")=$H
	close sockdev
	set ^bufchk("waitend")=^wait_"|"_$H
	if $get(^info(^scenario,"read"))<6 do
	. use $p write "TEST-E-TOOFEW bufchk expected at least 6 READs but only got "_$get(^info(^scenario,"read"),0),!
	quit

readord	;client2 conn0 conn1 write1>10 write0>10
	; server should get conn0,conn1,read1,read1,read0,read0
	; RedHat and SuSE systems get read0,read0,read1,read1 for LOCAL sockets
	; and in some cases TCP as well
	; The difference seems to fall within defined behavior for networks
	set ^readord("waitstart")=^wait_"|"_$H,^clientdone=0
	set ^readhold=0,maxtries=600,tries=0
	set wait=^wait+1	; so can use naked reference
	set ^expect(wait)="CONN",^(wait+1)="CONN",^(wait+2)="READ",^(wait+3)="READ",^(wait+4)="READ",^(wait+5)="READ"
	open sockdev:(connect=conn0:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^readord(clientnum)
	open sockdev:(connect=conn1:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	set ^holdserver=$H_"|"_^wait
	zshow "d":^readord(clientnum)
	use sockdev:socket="client"_clientnum
	write string2 set ^readord(clientnum,"W",1,$H)=string2
	use sockdev:socket="client"_(clientnum-1)
	write string1 set ^readord(clientnum-1,"W",1,$H)=string1
	set ^holdserver=0,^readord("zeroholdserver",^wait)=$H
	hang 1		; let server run
	set ^clientdone=$H
	; hang socktimeout
	lock +^serverended("server_rdo"):socktimeout	; wait for server to finish or timeout
	else  set ^readord("serverendedto")=$H
	close sockdev
	set ^readord("waitend")=^wait_"|"_$H
	if $get(^info(^scenario,"read"))<4 do
	. use $p write "TEST-E-TOOFEW readord expected at least 4 READs but only got "_$get(^info(^scenario,"read"),0),!
	quit

connpri	;client3 conn0 write0>10 holdserver write0>10 conn1 releaseserver write0>10 write1>10
	; server should get conn0,read0,conn1,read0,read0,read0,read0,read0,read1,read1
	set ^connpri("waitstart")=^wait_"|"_$H
	set ^readhold=0,maxtries=600,tries=0,^clientdone=0
	set wait=^wait+1	; so can use naked reference
	set ^expect(wait)="CONN",^(wait+1)="READ",^(wait+2)="CONN",^(wait+3)="READ",^(wait+4)="READ",^(wait+5)="READ"
	open sockdev:(connect=conn0:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^connpri(clientnum)
	set ^readonce=$H	; only read part of next write
	use sockdev write string1 set ^connpri(clientnum,"W",1,$H)=string1
	for  quit:^readhold'=0  hang 1 quit:$increment(tries)'<maxtries
	set ^holdserver=$H_"|"_^wait
	write string2 set ^connpri(clientnum,"W",2,$H)=string2
	open sockdev:(connect=conn1:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^connpri(clientnum)
	set (^readhold,^holdserver)=0,^connpri("zeroholdserver",^wait)=$H
	use sockdev:socket="client"_(clientnum-1)
	write string1 set ^connpri(clientnum-1,"W",3,$H)=string1
	use sockdev:socket="client"_clientnum
	write string2 set ^connpri(clientnum,"W",1,$H)=string2
	hang 1			; let server run
	set ^clientdone=$H
	; hang socktimeout
	lock +^serverended("server_cpr"):socktimeout	; wait for server to finish or timeout
	else  set ^connpri("serverendedto")=$H
	close sockdev
	set ^connpri("waitend")=^wait_"|"_$H
	if $get(^info(^scenario,"read"))<4 do
	. use $p write "TEST-E-TOOFEW connpri expected at least 4 READs but only got "_$get(^info(^scenario,"read"),0),!
	quit

conn3	;client4 conn0 holdserver conn1 write1>10 conn2 write0>10 releaseserver
	; server should get conn0,,conn1,read1,conn2,read1,read0,read0
	set ^conn3("waitstart")=^wait_"|"_$H
	set ^readhold=0,maxtries=600,tries=0,^clientdone=0
	set wait=^wait+1		; so can use naked reference
	set ^expect(wait)="CONN",^(wait+1)="CONN",^(wait+2)="READ",^(wait+3)="CONN",^(wait+4)="READ",^(wait+5)="READ",^(wait+6)="READ"
	open sockdev:(connect=conn0:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^conn3(clientnum)
	open sockdev:(connect=conn1:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^conn3(clientnum)
	use sockdev:socket="client"_clientnum
	set ^readonce=$H	; only read part of next write
	write string2 set ^conn3(clientnum,"W",1,$H)=string2
	for  quit:^readhold'=0  hang 1 quit:$increment(tries)'<maxtries
	set ^holdserver=$H_"|"_^wait
	open sockdev:(connect=conn0:attach="client"_$increment(clientnum):ioerror="t"):socktimeout:"socket"
	else  use $P write "TEST-E-TIMEOUT CONNECT at "_$ZPOS_"@"_$H,! zshow "*" halt
	zshow "d":^conn3(clientnum)
	use sockdev:socket="client"_(clientnum-2)
	write string1 set ^conn3(clientnum-2,"W",2,$H)=string1
	set (^readhold,^holdserver)=0,^conn3("zeroholdserver",^wait)=$H
	hang 1				; let server run
	set ^clientdone=$H
	; hang socktimeout
	lock +^serverended("server_c3"):socktimeout	; wait for server to finish or timeout
	else  set ^conn3("serverendedto")=$H
	close sockdev
	set ^conn3("waitend")=^wait_"|"_$H
	if $get(^info(^scenario,"read"))<4 do
	. use $p write "TEST-E-TOOFEW conn3 expected at least 4 READs but only got "_$get(^info(^scenario,"read"),0),!
	quit

readone(timeout,len)
	new x,ind,pio
	if ^zeof(handle) zshow "*":err  use $p  write "TEST-E-EOFCYCLE at "_$zposition,! zwrite err halt
	if len>0 s ind="x#"_len_":"_timeout else  set ind="x:"_timeout
	read @ind
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on read at "_$ZPOSITION,!  zwrite err  halt
	set ^info(^scenario,"read",^wait,$H)=handle_"|"_$device_"|eof="_$zeof_"|zkey="_$zkey_"|"_x
	set ^info(^scenario,"read")=$get(^info(^scenario,"read"))+1
	set (^zeof(handle),^zeof(^scenario))=$zeof
	quit

writeone
	write "abcdefghijklmnopqrstuvwxyz",!
	quit

wait(timeout)
	write /wait(timeout)
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on wait at "_$ZPOSITION,!  zwrite err  halt
	set ^info($increment(^wait))=$key_"\"_$zkey_"\"_$device
	quit

waitandreadone(timeout)
	do wait(timeout)
	do readone(timeout,10)
	quit

defaultservice
	set iterations=0,waittimeout=timeout/10,clientdonetries=-1,maxdonetries=2
	set ^info(^scenario,"waitstart")=^wait_"|"_$H
	for  do  quit:quit
	. set ^holdserversave=$get(^holdserver,"notset")_"|"_^wait_"|"_tries
	. if $get(^holdserver,0)'=0 hang 1 quit:$increment(tries)<maxtries  set quit=1 quit	; honor client request for wait
	. if $get(^readhold,0)'=0 hang 1 quit:$increment(tries)<maxtries  set quit=1 quit
	. if $get(^clientdone,0)'=0,clientdonetries=-1 set clientdonetries=tries
	. set ^info(^scenario,"lockbefore",iterations,tries)=$H lock +^serverhold s ^info(^scenario,"lockafter",iterations,tries)=$H
	. use sockdev
	. set ^wait(^scenario,^wait,iterations,tries,"before")=$H
	. write /wait(waittimeout)
	. s ^info(^scenario,"unlockbefore",iterations,tries)=$H l -^serverhold s ^info(^scenario,"unlockafter",iterations,tries)=$H
	. if $key="" do   quit
	. . if $increment(tries)>maxtries set quit=1 quit
	. . if (clientdonetries'=-1),((tries-clientdonetries)'<maxdonetries) set quit=1,^info(^scenario,"clientdone",^wait,tries)=$H
	. set ^wait(^scenario,$increment(^wait),iterations,tries,"after")=$H_"|clienttries="_clientdonetries
	. set iterations=iterations+1
	. set savetries=tries,tries=0
	. set key=$key,dev=$device,za=$za,zeof=$zeof
	. set ^info(^scenario,"wait",^wait,$H)=key_"\"_$zkey_"\"_dev_"\zeof="_zeof_"\za="_za
	. set handle=$piece(key,"|",2)
	. set what=$extract(key,1,4)
	. if $get(^expect(^wait))'="",what'=^expect(^wait) use 0 write "TEST-E-UNEXPECTED at wait#"_^wait_": "_what_" when expecting "_^expect(^wait),! set quit=1 zshow "*" quit
	. if $get(^zeof(handle)) close sockdev:socket=handle set ^zeof(handle,"close")=$H quit
	. if what="READ" do
	. . do readone(waittimeout/2,len)
	. . if $get(^readonce,0)'=0 set ^readhold=$H,^readonce=0
	. else  do
	. . set ^info(^scenario,"handle",$increment(^handles),$H)=handle_"@"_^wait zshow "d":^info(^scenario,"zshowd",^handles)
	. . set ^zeof(handle)=0
	. if $get(^zeof(^scenario),0)'=0 set quit=1 quit
	set ^info(^scenario,"outofwaitloop")=$H
	close sockdev
	set ^info(^scenario,"waitend")=^wait_"|"_$H_"|"_iterations
	; zshow "*":^info(^scenario,"serverend")
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

startserver(shortname,description,serviceroutine,syncdone,timeout,qlen,sockets,maxtries,tryinterval,outfile,errfile)
	set:'$data(serviceroutine) serviceroutine=""
	set:'$data(timeout) timeout=60
	set:'$data(qlen) qlen=0
	set:'$data(sockets) sockets=2
	set:'$data(maxtries) maxtries=600
	set ^maxtries=maxtries
	set:'$data(tryinterval) tryinterval=0.1
	set:'$data(outfile) outfile=shortname_".out"
	set:'$data(errfile) errfile=shortname_".err"
	set ^serverready(shortname)=0,tries=0
	set ^info(^scenario,"startserver","start")=$H
	lock +^serverstartsync(shortname)			; block server startup
	lock:$get(syncdone) +^serverdonesync(shortname)		; block server shutdown
	if $ZVERSION'["VMS"  do
	. job @("server(shortname,timeout,serviceroutine,qlen,sockets):(out="""_outfile_""":err="""_errfile_""")")
	else  do
	. job @("server^waitmultiple(shortname,timeout,serviceroutine,qlen,sockets):(detached:startup=""startup.com"":out="""_outfile_""":err="""_errfile_""")")
	for  quit:^serverready(shortname)  quit:$increment(tries)>maxtries  hang tryinterval
	if tries>maxtries  write !,"Server startup timed out at "_$STACK($STACK(-1)-1,"PLACE"),!  halt
	lock -^serverstartsync(shortname)			; allow server to proceed
	set ^info(^scenario,"startserver","end")=$H
	quit

serverendwait(shortname,syncdone,timeout)
	set:'$data(timeout) timeout=60
	set ^info(^scenario,"serverwait","start")=$H
	lock:$get(syncdone) -^serverdonesync(shortname)		; allow server to finish
	lock +^serverrunning(shortname):timeout			; wait for server to finish
	else  write !,"Server done sync timeout at "_$stack($stack(-1)-1,"PLACE"),!  halt
	lock -^serverrunning(shortname)				; allow next server to run
	set ^info(^scenario,"serverwait","end")=$H
	quit

startclient(shortname,description,serviceroutine,syncdone,timeout,maxtries,tryinterval,outfile,errfile)
	set:'$data(timeout) timeout=60
	set:'$data(maxtries) maxtries=600
	set:'$data(serviceroutine) serviceroutine=""
	set:'$data(tryinterval) tryinterval=0.1
	set:'$data(outfile) outfile=shortname_".out"
	set:'$data(errfile) errfile=shortname_".err"
	set ^clientready(shortname)=0,tries=0
	set ^info(^scenario,"clientstart","start")=$H
	lock +^clientstartsync(shortname)			; block client startup
	lock:$get(syncdone) +^clientdonesync(shortname)		; block client shutdown
	if $ZVERSION'["VMS"  do
	. job @("client(shortname,timeout,serviceroutine):(out="""_outfile_""":err="""_errfile_""")")
	else  do
	. job @("client^waitmultiple(shortname,timeout,serviceroutine):(detached:startup=""startup.com"":out="""_outfile_""":err="""_errfile_""")")
	; wait for client ready
	for  quit:^clientready(shortname)  quit:$increment(tries)>maxtries  hang tryinterval
	lock -^clientstartsync(shortname)			; allow client to proceed
	set ^info(^scenario,"clientstart","end")=$H
	quit

clientendwait(shortname,syncdone,timeout)
	set:'$data(timeout) timeout=60
	set ^info(^scenario,"clientwait","start")=$H
	lock:$get(syncdone) -^clientdonesync(shortname)		; allow client to finish
	lock +^clientrunning(shortname):timeout			; wait for client to finish
	else  write !,"Client done sync timeout at "_$stack($stack(-1)-1,"PLACE")_" for "_shortname,!  zshow "*":^info(^scenario,"clientsyncto") halt
	lock -^clientrunning(shortname)				; allow next client to run
	set ^info(^scenario,"clientwait","end")=$H
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

server(id,socktimeout,serviceroutine,qlen,sockets)
	set $ETRAP="USE $P  WRITE ""TEST-E-ZSHOW"",! ZSHOW ""*""  HALT"
	set portno=^config("portno"),portno2=^config("portno2"),delim=^config("delim")
	set sockdev="server$"_$j
	set numsocks=$get(sockets,1)
	set (quit,tries,^handles)=0
	set maxtries=^maxtries
	set len=10,timeout=socktimeout		; pass these, timeout is for read
	set serv1=$select(^config("hostname")="LOCAL":portno_":LOCAL",1:portno_":TCP")
	set serv2=$select(^config("hostname2")="LOCAL":portno2_":LOCAL",1:portno2_":TCP")

	lock +^serverrunning(id),+^serverended(id)		; released when done (including on halt)
	set ^serverready(id)=1,lktimeout=60
	lock +^serverstartsync(id):lktimeout		; wait for permission to proceed
	else  write !,"Server start sync timeout at "_$ZPOSITION,!  halt
	open sockdev:(ioerror="TRAP"):socktimeout:"SOCKET"
	else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on server open at "_$ZPOSITION,!  zwrite err  halt
	for socknum=1:1:numsocks do
	. open sockdev:(LISTEN=@("serv"_socknum):NEW:attach="server"_socknum:ioerror="TRAP"):socktimeout:"SOCKET"
	. else  zshow "*":err  use $p  write "TEST-E-TIMEOUT on server "_socknum_" open at "_$ZPOSITION,!  zwrite err  halt
	. use sockdev
	. write:$get(qlen)>0 /listen(qlen)
	if $get(serviceroutine)="" set serviceroutine="defaultservice"
	use $PRINCIPAL
	write !,"Before service routine "_serviceroutine,!
	zshow "D"
	use sockdev
	do @serviceroutine
	lock +^serverdonesync(id):lktimeout		; wait for permission to exit
	else  set ^info(id,"serverdoneto")=$H
	set ^info(^scenario,"serverdone")=$H
	halt

client(id,socktimeout,serviceroutine)
	set $ETRAP="USE $P  ZSHOW ""*""  HALT"
	set portno=^config("portno"),delim=^config("delim"),hostname=^config("hostname")
	set portno2=^config("portno2"),hostname2=^config("hostname2")
	set clientnum=0,c="client",string1="0123456789abcdefghij",string2="klmnopqrst9876543210"
	set conn0=$select(hostname="LOCAL":portno_":LOCAL",1:hostname_":"_portno_":TCP")
	set conn1=$select(hostname2="LOCAL":portno2_":LOCAL",1:hostname2_":"_portno2_":TCP")
	set sockdev="client$"_$j
	lock +^clientrunning(id)			; released when done (including on halt)
	set ^clientready(id)=1,lktimeout=60
	lock +^clientstartsync(id):lktimeout		; wait for permission to proceed
	else  write !,"Client start sync timeout at"_$ZPOSITION,!  halt
	if $data(serviceroutine),serviceroutine'=""  do @serviceroutine
	lock +^clientdonesync(id):lktimeout		; wait for permission to exit
	set ^info(^scenario,"clientdone")=$H
	halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
