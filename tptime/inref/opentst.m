;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opentst(timeout,longwait,port)	;
	d ^init(timeout,longwait)
	set $ztrap="use $p  "_$ztrap
	set hostname=$$^findhost(2)
	set conn="server"
	set sock=port
	set exceptionerr="Exception:Cannot open the connection FAILED"
	tstart ():serial
	s tbegtp=$h
	Open conn:(ZLISTEN=sock_":TCP":exception="use $p  w exceptionerr  h":ioerror="TRAP"):longwait:"SOCKET"
	if $T=0 use $p  w "Connection listen timed out FAILED",!  h
	use conn
	Write /listen(1)
	Write /wait(longwait)
	s wkey=$key
	use $p
	if wkey=""  w "Listen wait timed out, FAILED",!
	close conn
	w "Message inside TS/TC block:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	tcommit
	w "Message after TS/TC block: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	d ^finish
	q
