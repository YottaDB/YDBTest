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
gtm8013
  set s="serversocket",sf="local.socket",timeout=60,$etrap="use $P  zshow ""*""  halt"
  open s:(LISTEN=sf_":LOCAL":DELIMITER=$c(10):ATTACH="server":IOERROR="TRAP")::"SOCKET"
  job connecter(sf,timeout)
  set conjob=$zjob
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, wait timeout in server",!  halt
  write "ping",!
  set key=$key,state=$piece(key,"|",1),handle=$piece(key,"|",2)
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, wait timeout in server",!  halt
  if $piece($key,"|",2)'=handle  do
  . set newkey=$key
  . use $P
  . write "$KEY changed from "_$zwrite(key)_" to "_$zwrite(newkey),!
  . use s:SOCKET=handle
  read x
  close s
  use $P  write x,!
  do waitforproctodie^waitforproctodie(conjob)
  halt

connecter(sf,timeout)
  set s="clientsocket",$etrap="use $P  zshow ""*""  halt"
  open s:(CONNECT=sf_":LOCAL":ATTACH="client":IOERROR="TRAP":DELIMITER=$c(10)):timeout:"SOCKET"
  else  use $P  write "TEST-E-timeout, open timeout in client",!  halt
  use s
  write /wait(timeout)
  else  use $P  write "TEST-E-timeout, wait timeout in client",!  halt
  set key=$key,state=$piece(key,"|",1),handle=$piece(key,"|",2)
  use $P  zshow "D"
  use s:SOCKET=handle
  read x
  write "echo: ",x,!
  halt
