;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lsocpass(hostname,portno)
  set s="passersockdev",sf="local.socket",$etrap="use $P  write ""TEST-E-error, unexpected condition"",!  zshow ""*""  halt",timeout=60,sockcount=20
  set pidpasssupported=($zversion["Linux")!($zversion["AIX")!($zversion["Solaris")
  set dopasstimeout=$piece($horolog,",",2)#2		; cheap coin flip
  set passcmd="/pass(accpid,"_$select(dopasstimeout:timeout,1:"")
  ; listen for LOCAL connections
  open s:::"SOCKET"
  open s:(LISTEN=sf_":LOCAL":DELIMITER=$c(10):ATTACH="llistener":IOERROR="TRAP")::"SOCKET"
  set llkey=$key,llstate=$piece(llkey,"|",1),llhandle=$piece(llkey,"|",2)
  ; listen for TCP connections
  open s:(LISTEN=portno_":TCP":DELIMITER=$c(10):ATTACH="tcplistener":IOERROR="TRAP")::"SOCKET"
  use s
  set tcplkey=$key,tcplstate=$piece(tcplkey,"|",1),tcplhandle=$piece(tcplkey,"|",2)
  ; start TCP clients and wait for connections from them
  for i=1:1:sockcount  do
  . job @("tcpclient(i,hostname,portno,timeout):(OUTPUT=""tcpclient_"_i_".mjo"":ERROR=""tcpclient_"_i_".mje"")")
  . set tcpcpid(i)=$zjob
  . use s
  . write /wait(timeout)
  . else  use $P  write "TEST-E-timeout, tcp wait timeout in server",!  halt
  . set tcpskey=$key,tcpsstate=$piece(tcpskey,"|",1),tcpshandle(i)=$piece(tcpskey,"|",2)
  . if tcpsstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected TCP key state in server",!  zshow "*"  halt
  . use s:(SOCKET=tcpshandle(i):DELIMITER=$c(10))  use s:IOERROR="TRAP"  write "prompt>",!  read x
  . if x'="passme"  use $P  write "TEST-E-badcmd, expected ""passme"", got "_$zwrite(x),!  zshow "*"  halt
  . use s:DETACH=tcpshandle(i)
  . set passcmd=passcmd_",tcpshandle("_i_")"
  close s:SOCKET=tcplhandle
  ; get a LOCAL socket to pass
  job @("localclient(sockcount+1,sf,timeout):(OUTPUT=""localclient.mjo"":ERROR=""localclient.mje"")")
  set loccpid=$zjob
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, local wait timeout in server",!  halt
  set locskey=$key,locsstate=$piece(locskey,"|",1),locshandle=$piece(locskey,"|",2)
  if locsstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected LOCAL key state in server",!  zshow "*"  halt
  use s:(SOCKET=locshandle:DELIMITER=$c(10))  use s:IOERROR="TRAP"  write "prompt>",!  read x
  if x'="passme"  use $P  write "TEST-E-badcmd, expected ""passme"", got "_$zwrite(x),!  zshow "*"  halt
  use s:DETACH=locshandle
  set passcmd=passcmd_",locshandle"
  ; connect to local ssh server and add socket to pass command - demonstrates handle name passing
  set passcmd=passcmd_",""ssh"""
  open s:(CONNECT="localhost:22:TCP":ATTACH="ssh":IOERROR="TRAP")::"SOCKET"
  use s:DETACH="ssh"
  use $p  write "Got TCP connections",!
  ;
  set passcmd=passcmd_")"
  ;
  if pidpasssupported  do
  . use $p  write "Test ACCEPT badpid",!
  . do startaccepter("_abad",s,sf,timeout,1,.accpid,.lskey,.lsstate,.lshandle)
  . do
  . . new accpid,$etrap
  . . set SOCKPASS=150383322
  . . set savio=$io,$etrap="zshow ""*"":trap  if (+$zstatus)=SOCKPASS  kill trap  set $ecode="""",$zstatus=""""  use $p  write ""Invalid PID on /accept produced SOCKPASS, as expected"",!  use savio  quit"
  . . use s:SOCKET=lshandle
  . . use s:IOERROR="TRAP"
  . . write @passcmd
  . . ; $TEST is valid here iff dopasstimeout is true, so the following error will only be reported when a timeout occurs
  . . else  if dopasstimeout  use $p  write "TEST-E-timeout, timeout in write "_passcmd,!  halt
  . . use $P  write "TEST-E-noerror,Expected SOCKPASS on write "_passcmd,!  use savio
  . close s:SOCKET=lshandle
  . do waitforproctodie^waitforproctodie(accpid,timeout*2)
  . ;
  . use $p  write "Test PASS badpid",!
  . do startaccepter("_pbad",s,sf,timeout,0,.accpid,.lskey,.lsstate,.lshandle)
  . set oldaccpid=accpid
  . do
  . . new accpid,$etrap
  . . set accpid=oldaccpid+1,savio=$io,$etrap="zshow ""*"":trap  if $zstatus[""PEERPIDMISMATCH""  kill trap  set $ecode="""",$zstatus=""""  use $p  write ""Invalid PID on /pass produced PEERPIDMISMATCH, as expected"",!  use savio  quit"
  . . use s:SOCKET=lshandle
  . . use s:IOERROR="TRAP"
  . . write @passcmd
  . . ; $TEST is valid here iff dopasstimeout is true, so the following error will only be reported when a timeout occurs
  . . else  if dopasstimeout  use $p  write "TEST-E-timeout, timeout in write "_passcmd,!  zshow "*"  halt
  . . use $P  write "TEST-E-noerror,Expected PEERPIDMISMATCH on write "_passcmd,!  use savio
  . close s:SOCKET=lshandle
  . do waitforproctodie^waitforproctodie(accpid,timeout*2)
  . ;
  use $p  write "Test no badpid",!
  do startaccepter("",s,sf,timeout,0,.accpid,.lskey,.lsstate,.lshandle)
  use $P  zshow "D"
  use s:SOCKET=lshandle
  use s:IOERROR="TRAP"
  ; Try bad write /pass first
  do
  . new $etrap
  . set savio=$io,$etrap="zshow ""*"":trap  if $zstatus[""NOSOCKHANDLE""  kill trap  set $ecode="""",$zstatus=""""  quit"
  . write /pass(,)
  . use $P  write "TEST-E-noerror,Expected NOSOCKHANDLE on write /pass(,)",!  use savio
  ; And make sure we get an EXPR message for a null handle
  do
  . new $etrap
  . set EXPR=150372778
  . set savio=$io,$etrap="zshow ""*"":trap  if (+$zstatus)=EXPR  kill trap  set $ecode="""",$zstatus=""""  quit"
  . write /pass(,,)
  . use $P  write "TEST-E-noerror,Expected EXPR on write /pass(,,)",!  use savio
  write @passcmd
  ; $TEST is valid here iff dopasstimeout is true, so the following error will only be reported when a timeout occurs
  else  if dopasstimeout  use $p  write "TEST-E-timeout, timeout in write "_passcmd,!  halt
  use $p  write "Passed TCP sockets",!
  do lsofme("pass_lsof.out")
  set $etrap=""
  close s:SOCKET=lshandle
  use $p
  do waitforproctodie^waitforproctodie(accpid,timeout*2)
  set lingertcppids=$$xwaitforalltodie^waitforproctodie(.tcpcpid,timeout)
  do waitforproctodie^waitforproctodie(loccpid,timeout)
  write:'lingertcppids "Clients done"
  write:lingertcppids "TCP client(s) ("_lingertcppids_") still alive"
  write !
  ; test that timeout works on the accepter end
  write !,"Testing Accept Timeout",!
  set $etrap="use $P  zshow ""*""  halt"
  job lsocaccept(sf,timeout,$job,0):(OUTPUT="lsocaccept_to.out":ERROR="lsocaccept_to.err")
  set acctopid=$zjob
  use s:IOERROR="TRAP"
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, local wait timeout in server (accept timeout)",!  halt
  set lstokey=$key,lstostate=$piece(lstokey,"|",1),lstohandle=$piece(lstokey,"|",2)
  if lstostate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected LOCAL key state in server (accept timeout)",!  zshow "*"  halt
  use $p
  write "Got LOCAL connection",!
  ; no write /pass here, so write /accept in accepter should time out
  set $etrap=""
  set lingeracctopid=$$xwaitforproctodie^waitforproctodie(acctopid,timeout*2)
  write:'lingeracctopid "Accepter done"
  write:lingeracctopid "Accepter (timeout) process ("_lingeracctopid_") still alive"
  write !
  ; Check socket file
  zsystem "test -e "_sf_" || echo TEST-E-NOTFOUND, socket file "_sf_" not found"
  close s
  zsystem "test -e "_sf_" && echo TEST-E-NOTREMOVED, socket file "_sf_" not removed after close"
  halt

startaccepter(suffix,s,sf,timeout,badpid,accpid,lskey,lsstate,lshandle)
  ; Job off an accepter and wait for a connection from it
  ;
  ;	suffix		- string to place in output filenames before extension
  ;	s		- socket to use
  ;	sf		- local socket filename
  ;	timeout		- how long to wait, or zero for no timeout
  ;	badpid		- if true, use the wrong pid for accept call
  ;	accpid		- reference argument, gets $job for accepter process
  ;	lskey		- reference argument, gets $key for connected local socket
  ;	lsstate		- reference argument, gets state of connected local socket
  ;	lshandle	- reference argument, gets handle of connected local socket
  ;
  ; start accepter with badpid
  new doacctimeout  set doacctimeout=$piece($horolog,",",2)#2		; cheap coin flip
  job @("lsocaccept(sf,"_$select(doacctimeout:timeout,1:"")_",$job,badpid):(OUTPUT=""lsocaccept"_suffix_".out"":ERROR=""lsocaccept"_suffix_".err"")")
  set accpid=$zjob
  ; wait for connection from accepter
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, local wait timeout in server",!  halt
  set lskey=$key,lsstate=$piece(lskey,"|",1),lshandle=$piece(lskey,"|",2)
  if lsstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected LOCAL key state in server",!  zshow "*"  halt
  use $p  write "Got LOCAL connection",!
  quit

lsocaccept(sf,timeout,peerpid,pidbad)
  ; Connect to a local socket and accept sockets passed from it
  ;
  ;	sf		- local socket filename
  ;	timeout		- optional timeout
  ;	peerpid		- pid to expect on the other end of the local socket connection
  ;	pidbad		- if true, use the wrong pid for accept call
  ;
  set s="acceptersockdev",$etrap="use $P  zshow ""*""  do lsofme(""accept_err_lsof_"_$job_".out"")  halt"
  open s:(CONNECT=sf_":LOCAL":ATTACH="accepter":IOERROR="TRAP":DELIMITER=$c(10)):$get(timeout):"SOCKET"
  else  use $P  write "TEST-E-timeout, local open timeout in accepter",!  halt
  use $P  zshow "D"
  use s
  if pidbad  do
  . ; test pid validation
  . set peerpid=peerpid+1,savio=$io
  . new $etrap
  . set $etrap="zshow ""*"":trap  if $zstatus[""PEERPIDMISMATCH""  kill trap  set $ecode="""",$zstatus="""""
  . set $etrap=$etrap_"  use $p  write ""Invalid PID on /accept produced PEERPIDMISMATCH, as expected"",!  use savio  quit"
  . write @("/accept(.handles,peerpid,"_$select($data(timeout):timeout,1:"")_",""passed1"",,""passed3"")")
  . use $P  write "TEST-E-noerror,Expected PEERPIDMISMATCH on accept",!  use savio
  if 'pidbad  do
  . set SOCKACCEPT=150383330,SOCKNOTPASSED=150378898,CREDNOTPASSED=150379570
  . new $etrap
  . set $etrap="zshow ""*"":trap  if ((+$zstatus)=SOCKACCEPT)!((+$zstatus)=SOCKNOTPASSED)!((+$zstatus)=CREDNOTPASSED)  kill trap  set $ecode="""",$zstatus="""""
  . ; Use $c(45) instead of "-" to prevent "-E-" from showing up in the ZSHOW "*" output, which would signal a failure
  . set $etrap=$etrap_"  use $p  write ""TEST""_$c(45)_""E""_$c(45)_""NOTPASSED, got SOCKACCEPT, SOCKNOTPASSED, or CREDNOTPASSED, giving up"",!"
  . set $etrap=$etrap_"  quit"
  . set checkpid=$piece($horolog,",",2)#2		; cheap coin flip
  . write @("/accept(.handles,"_$select(checkpid:peerpid,1:"")_","_$select($data(timeout):timeout,1:"")_",""passed1"",,""passed3"")")
  . ; $TEST is valid here iff $data(timeout) is true, so the following error will only be reported when a timeout occurs
  . else  if $data(timeout)  use $P  write "TEST-E-timeout, accept timeout in accepter",!  zshow "*"  halt
  . use $P  zwrite handles  zshow "D"
  . do lsofme("accept_lsof_"_$job_".out")
  . ; chat with passed sockets
  . for i=1:1  set h=$piece(handles,"|",i)  quit:h=""  do
  . . set xmsg="Greetings from client ("_i_")"
  . . use s:ATTACH=h
  . . use s:(SOCKET=h:DELIMITER=$c(10))
  . . use s:IOERROR="TRAP"
  . . write /wait($data(timeout))	; just to see if we can
  . . use s:SOCKET=h			; pick the right socket again
  . . read x
  . . if h'="ssh"  do
  . . . if x'=xmsg  use $P  write "TEST-E-badmsg, expected "_$zwrite(xmsg)_", got "_$zwrite(x),!  zshow "*"  halt
  . . . use s  set x="echo from server: "_x  write x,!
  . . if h="ssh"  use $P  write "SSH Server Id: "_x,!
  . . ; Pass each socket to a JOB as INPUT, with OUTPUT to different devices, and verify $JOB and $DEVICE in the child.
  . . if i#3=0  do
  . . . use s:DETACH=h
  . . . job @("checkdollarp(""checkdollarp_io_"_i_".log""):(INPUT=""SOCKET:"_h_""":OUTPUT=""SOCKET:"_h_""":ERROR=""checkdollarp_io_"_i_".err"")")
  . . . use $P
  . . . do waitforproctodie^waitforproctodie($zjob,60)
  . . if i#3=1  do
  . . . use s:DETACH=h
  . . . job @("checkdollarp(""checkdollarp_i_"_i_".log""):(INPUT=""SOCKET:"_h_""":OUTPUT=""checkdollarp_i_"_i_".out"":ERROR=""checkdollarp_i_"_i_".err"")")
  . . . use $P
  . . . do waitforproctodie^waitforproctodie($zjob,60)
  . . if i#3=2  do
  . . . use s:DETACH=h
  . . . job @("checkdollarp(""checkdollarp_ix_"_i_".log""):(INPUT=""SOCKET:"_h_""":OUTPUT=""/dev/null"":ERROR=""checkdollarp_ix_"_i_".err"")")
  . . . use $P
  . . . do waitforproctodie^waitforproctodie($zjob,60)
  . use $P  write "Correct messages received from all clients",!  zshow "D"
  halt

checkdollarp(file)
  zshow "D":zs(1,"Initial")
  set key=$KEY,handle=$piece(key,"|",2),dollarp=$P,device=$DEVICE
  set:key="" key="TEST-E-KEYEMPTY, $KEY is not defined"
  set:device="" device="TEST-E-DEVICEEMPTY, $DEVICE is not defined"
  use:handle $P:DETACH=handle
  zshow "D":zs(2,"After Detach")
  open file
  use file
  zwrite dollarp,key,device,zs
  close file
  quit

lsofme(fn)
  if $zversion["Solaris"  zsystem "pfiles "_$job_" >& "_fn
  else  zsystem "lsof -p "_$job_" >& "_fn
  quit

tcpclient(clientnum,hostname,portno,timeout)
  set s="tcpclientsockdev"
  open s:(CONNECT=hostname_":"_portno_":TCP":ATTACH="tcpclient":DELIMITER=$c(10):IOERROR="TRAP"):timeout:"SOCKET"
  else  use $P  write "TEST-E-timeout, tcp open timeout in client",!  halt
  do lsofme("tcpclient_lsof_connected_"_clientnum_".out")
  use s
  do client
  halt

localclient(clientnum,sf,timeout)
  set s="localclientsockdev"
  open s:(CONNECT=sf_":LOCAL":ATTACH="localclient":DELIMITER=$c(10):IOERROR="TRAP"):timeout:"SOCKET"
  else  use $P  write "TEST-E-timeout, local open timeout in client",!  halt
  do lsofme("localclient_lsof_connected_"_clientnum_".out")
  use s
  do client
  halt

client
  read x
  set prompt="prompt>"
  if x'=prompt  use $P  write "TEST-E-noprompt, expected "_$zwrite(prompt)_", got "_$zwrite(x),!  zshow "*"  halt
  do:$data(sf)		; test mix of read and accept on local socket
  . new $etrap
  . set SOCKPASSDATAMIX=150383354,$etrap="zshow ""*"":trap  if (+$zstatus)=SOCKPASSDATAMIX  kill trap  set $ecode="""",$zstatus=""""  quit"
  . write /accept(,,)
  . use $P  write "TEST-E-noerror,Expected SOCKPASSDATAMIX on accept",!  halt
  use s  write "passme",!
  use s  set msg="Greetings from client ("_clientnum_")"  write msg,!
  use s  read x
  set echo="echo from server: "_msg
  if x'=echo  use $P  write "TEST-E-badecho, expected "_$zwrite(echo)_", got "_$zwrite(x),!  zshow "*"  halt
  quit
