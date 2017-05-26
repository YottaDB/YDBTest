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
lsocpassmulti(hostname,portno)
  set s="passersockdev",sf="local.socket",$etrap="use $P  write ""TEST-E-error, unexpected condition"",!  zshow ""*""  halt",timeout=60,sockcount=20
  open s:::"SOCKET"
  open s:(LISTEN=sf_":LOCAL":DELIMITER=$c(10):ATTACH="llistener":IOERROR="TRAP")::"SOCKET"
  set llkey=$key,llstate=$piece(llkey,"|",1),llhandle=$piece(llkey,"|",2)
  do startaccepter("",s,sf,timeout,sockcount,.accpid,.lskey,.lsstate,.lshandle)
  open s:(LISTEN=portno_":TCP":DELIMITER=$c(10):ATTACH="tcplistener":IOERROR="TRAP")::"SOCKET"
  use s
  set tcplkey=$key,tcplstate=$piece(tcplkey,"|",1),tcplhandle=$piece(tcplkey,"|",2)
  ; start TCP clients and wait for connections from them
  set dopasstimeout=$piece($horolog,",",2)#2		; cheap coin flip
  set passcmd="/pass(accpid,"_$select(dopasstimeout:timeout,1:"")
  for i=1:1:sockcount  do
  . job @("tcpclient(i,hostname,portno,timeout):(OUTPUT=""tcpclient_"_i_".mjo"":ERROR=""tcpclient_"_i_".mje"")")
  . set tcpcpid(i)=$zjob
  . use s
  . write /wait(timeout)
  . else  use $P  write "TEST-E-timeout, tcp wait timeout in server",!  halt
  . set tcpskey=$key,tcpsstate=$piece(tcpskey,"|",1),tcpshandle=$piece(tcpskey,"|",2)
  . if tcpsstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected TCP key state in server",!  zshow "*"  halt
  . use s:(SOCKET=tcpshandle:DELIMITER=$c(10))  use s:IOERROR="TRAP"  write "prompt>",!  read x
  . if x'="passme"  use $P  write "TEST-E-badcmd, expected ""passme"", got "_$zwrite(x),!  zshow "*"  halt
  . use s:DETACH=tcpshandle
  . use s:SOCKET=lshandle
  . use s:IOERROR="TRAP"
  . write /pass(accpid,timeout,tcpshandle)
  . else  use $p  write "TEST-E-timeout, timeout in write /pass #"_i,!  zshow "*"  halt
  . ; test read/write after pass
  . set SOCKPASSDATAMIX=150383354
  . do:i=4		; check the fourth socket
  . . new $etrap
  . . set $etrap="zshow ""*"":trap  if (+$zstatus)=SOCKPASSDATAMIX  kill trap  set $ecode="""",$zstatus=""""  quit"
  . . write "Some random garbage",!
  . . use $P  write "TEST-E-noerror,Expected SOCKPASSDATAMIX on write",!  halt
  . do:i=3		; check the third socket
  . . new $etrap
  . . set $etrap="zshow ""*"":trap  if (+$zstatus)=SOCKPASSDATAMIX  kill trap  set $ecode="""",$zstatus=""""  quit"
  . . read x
  . . use $P  write "TEST-E-noerror,Expected SOCKPASSDATAMIX on read",!  halt
  use $p  write "Passed TCP sockets",!
  do
  . new $etrap  set $etrap=""
  . do waitforalltodie^waitforproctodie(.tcpcpid,timeout)
  . do lsofme("pass_lsof.out")
  . close s:SOCKET=lshandle
  . use $p
  . do waitforproctodie^waitforproctodie(accpid,timeout*2)
  ;
  write "Begin socket ping pong",!
  ;
  set pingcnt=20
  ; reuse tcp listener socket
  job ball(hostname,portno,timeout):(OUTPUT="ball.out":ERROR="ball.err")
  set ballpid=$zjob
  ; wait for ball to connect
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, ball serve wait timeout",!  halt
  set bskey=$key,bsstate=$piece(bskey,"|",1),bshandle=$piece(bskey,"|",2)
  if bsstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected TCP key state in server",!  zshow "*"  halt
  use s:SOCKET=bshandle
  use s:IOERROR="TRAP"
  ; reuse local listener socket
  job pong(sf,timeout,$job,pingcnt):(OUTPUT="pong.out":ERROR="pong.err")
  set pongpid=$zjob
  ; wait for pong to connect
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, pong wait timeout",!  halt
  set pskey=$key,psstate=$piece(pskey,"|",1),pshandle=$piece(pskey,"|",2)
  if psstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected LOCAL key state in server",!  zshow "*"  halt
  use s:SOCKET=pshandle
  use s:IOERROR="TRAP"
  for i=1:1:pingcnt  do
  . use s:(SOCKET=bshandle:DELIMITER=$c(10))
  . write "ping - "_i,!
  . use s:DETACH=bshandle
  . use s:SOCKET=pshandle
  . write /pass(pongpid,timeout,bshandle)
  . else  use $P  write "TEST-E-timeout, ball pass timeout in ping",!  halt
  . write /accept(.handles,pongpid,timeout,bshandle)
  . else  use $P  write "TEST-E-timeout, ball accept timeout in ping",!  halt
  . use s:ATTACH=bshandle
  close s
  use $P
  do waitforproctodie^waitforproctodie(pongpid,timeout)
  do waitforproctodie^waitforproctodie(ballpid,timeout)
  write "End lsocpassmulti",!
  ;
  halt

startaccepter(suffix,s,sf,timeout,clientcnt,accpid,lskey,lsstate,lshandle)
  ; Job off an accepter and wait for a connection from it
  ;
  ;	suffix		- string to place in output filenames before extension
  ;	s		- socket to use
  ;	sf		- local socket filename
  ;	timeout		- how long to wait, or zero for no timeout
  ;	clientcnt	- the number of client connections to accept
  ;	accpid		- reference argument, gets $job for accepter process
  ;	lskey		- reference argument, gets $key for connected local socket
  ;	lsstate		- reference argument, gets state of connected local socket
  ;	lshandle	- reference argument, gets handle of connected local socket
  ;
  job @("lsocaccept(sf,timeout,$job,clientcnt):(OUTPUT=""lsocaccept"_suffix_".out"":ERROR=""lsocaccept"_suffix_".err"")")
  set accpid=$zjob
  ; wait for connection from accepter
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, local wait timeout in server",!  halt
  set lskey=$key,lsstate=$piece(lskey,"|",1),lshandle=$piece(lskey,"|",2)
  if lsstate'="CONNECT"  use $P  write "TEST-E-badstate, unexpected LOCAL key state in server",!  zshow "*"  halt
  use $p  write "Got LOCAL connection",!
  quit

lsocaccept(sf,timeout,peerpid,clientcnt)
  ; Connect to a local socket and accept sockets passed from it
  ;
  ;	sf		- local socket filename
  ;	timeout		- optional timeout
  ;	peerpid		- pid to expect on the other end of the local socket connection
  ;	clientcnt	- the number of client connections to expect
  ;
  set s="acceptersockdev",$etrap="use $P  zshow ""*""  do lsofme(""accept_err_lsof_"_$job_".out"")  halt"
  set chandle="client"
  open s:(CONNECT=sf_":LOCAL":ATTACH="accepter":IOERROR="TRAP":DELIMITER=$c(10)):$get(timeout):"SOCKET"
  else  use $P  write "TEST-E-timeout, local open timeout in accepter",!  halt
  for i=1:1:clientcnt  do
  . use s
  . write /accept(.handles,peerpid,timeout,chandle)
  . else  use $P  write "TEST-E-timeout, accept timeout in accepter",!  zshow "*"  halt
  . if handles'=chandle  use $P  write "TEST-E-badhandle, expected "_$zwrite(chandle)_", got "_$zwrite(handles),!  zshow "*"  halt
  . set zhandle=$zsocket(,"sockethandle",)	; from socketpool
  . if handles'=zhandle  use $P  write "TEST-E-badzsocket, expected "_$zwrite(zhandle)_", got "_$zwrite(handles),!  zshow "*"  halt
  . set zhow=$zsocket(,"howcreated",)	; from socketpool
  . if zhow'="PASSED"  use $P  write "TEST-E-badzsocketcreated, expected PASSED, got "_$zwrite(zhow),!  zshow "*"  halt
  . ; test read/write after accept
  . set SOCKPASSDATAMIX=150383354
  . do:i=3		; check the third socket
  . . new $etrap
  . . set $etrap="zshow ""*"":trap  if (+$zstatus)=SOCKPASSDATAMIX  kill trap  set $ecode="""",$zstatus=""""  quit"
  . . write "Some random garbage",!
  . . use $P  write "TEST-E-noerror,Expected SOCKPASSDATAMIX on write",!  halt
  . do:i=4		; check the fourth socket
  . . new $etrap
  . . set $etrap="zshow ""*"":trap  if (+$zstatus)=SOCKPASSDATAMIX  kill trap  set $ecode="""",$zstatus=""""  quit"
  . . read x
  . . use $P  write "TEST-E-noerror,Expected SOCKPASSDATAMIX on read",!  halt
  . ; chat with passed socket
  . set xmsg="Greetings from client ("_i_")"
  . use s:ATTACH=chandle
  . use s:(SOCKET=chandle:DELIMITER=$c(10))
  . use s:IOERROR="TRAP"
  . read x
  . if x'=xmsg  use $P  write "TEST-E-badmsg, expected "_$zwrite(xmsg)_", got "_$zwrite(x),!  zshow "*"  halt
  . use s  set x="echo from server: "_x  write x,!
  . close s:SOCKET=chandle
  use $P  write "Correct messages received from all clients",!
  halt

lsofme(fn)
  if $zversion["Solaris"  zsystem "pfiles "_$job_" >& "_fn
  else  zsystem "lsof -p "_$job_" >& "_fn
  quit

tcpclient(clientnum,hostname,portno,timeout)
  set s="tcpclientsockdev"
  open s:(CONNECT=hostname_":"_portno_":TCP":ATTACH="tcpclient":DELIMITER=$c(10):IOERROR="TRAP"):timeout:"SOCKET"
  else  use $P  write "TEST-E-timeout, tcp open timeout in client",!  halt
  do lsofme("tcpclient_lsof_connected_"_clientnum_".out")
  use s  read x
  set prompt="prompt>"
  if x'=prompt  use $P  write "TEST-E-noprompt, expected "_$zwrite(prompt)_", got "_$zwrite(x),!  zshow "*"  halt
  use s  write "passme",!
  use s  set msg="Greetings from client ("_clientnum_")"  write msg,!
  use s  read x
  set echo="echo from server: "_msg
  if x'=echo  use $P  write "TEST-E-badecho, expected "_$zwrite(echo)_", got "_$zwrite(x),!  zshow "*"  halt
  else  use $P  write echo,!
  halt


pong(sf,timeout,pingpid,pingcnt)
  set s="pongsocket",$etrap="use $P  zshow ""*""  halt"
  set ballhandle="ball"
  open s:(CONNECT=sf_":LOCAL":ATTACH="pong":IOERROR="TRAP":DELIMITER=$c(10)):timeout:"SOCKET"
  else  use $P  write "TEST-E-timeout, local open timeout in accepter",!  halt
  use s
  set lckey=$key,lcstate=$piece(lckey,"|",1),lchandle=$piece(lckey,"|",2)
  if lcstate'="ESTABLISHED"  use $P  write "TEST-E-badstate, unexpected LOCAL key state in server",!  zshow "*"  halt
  use s:SOCKET=lchandle
  use s:IOERROR="TRAP"
  for i=1:1:pingcnt  do
  . write /accept(.handles,pingpid,timeout,ballhandle)
  . else  use $P  write "TEST-E-timeout, ball accept timeout in pong",!  halt
  . use s:ATTACH=ballhandle
  . use s:(SOCKET=ballhandle:DELIMITER=$c(10))
  . write "pong - "_i,!
  . use s:DETACH=ballhandle
  . use s:SOCKET=lchandle
  . write /pass(pingpid,timeout,ballhandle)
  . else  use $P  write "TEST-E-timeout, ball pass timeout in pong",!  halt
  use $P  zshow "D"
  close s
  halt

ball(hostname,portno,timeout)
  set s="tcpclientsockdev"
  open s:(CONNECT=hostname_":"_portno_":TCP":ATTACH="tcpclient":DELIMITER=$c(10)):timeout:"SOCKET"
  else  use $P  write "TEST-E-timeout, tcp open timeout in client",!  halt
  for  do  quit:x=""
  . use s:DELIMITER=$c(10)
  . read x
  . use $P
  . write x,!
  halt
