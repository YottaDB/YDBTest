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
rdtcptst(timeout,longwait,port)	;
	; read command which time out in longwait sec. is tested
	new conn
	SET unix=$zv'["VMS"
	S ^flag1=0
	l +^flag1
	d ^init(timeout,longwait)
	s $ztrap="close conn  use $principal  "_$ztrap
	set hostname=$$^findhost(2)
	set conn="server"
	set ssock=port
	set csock=hostname_":"_port
	set exceptionerr="Cannot open the connection FAILED"
	set tcptmout=45
	;
	IF unix  DO
        . SET jobs="sender^rdtcptst(csock,longwait):(output=""sender.mjo"":error=""sender.mje"")"
        Else  DO
        . SET jobs="sender^rdtcptst(csock,longwait):(STARTUP=""STARTUP.COM"":output=""sender.mjo"":error=""sender.mje"")"
        J @jobs
	f  q:^flag1'=0
	; Child has ^flag2
	;
	if unix  set file=^modname_".logx" open file:append use file
	Open conn:::"SOCKET"	; create empty socket device
 	Open conn:(ZLISTEN=ssock_":TCP":exception="u $principal  w $zpos  GOTO rcverr":attach="server"):tcptmout:"SOCKET"
	if $test=0 use $P  write "Open timed out FAILED",!  h
	set iosaved=$io u conn s dev=$DEVICE u iosaved
	if dev use $P  write "Open encountered an error FAILED",!  h
	use conn
	Write /listen(1)
	Write /wait(tcptmout)
	set wkey=$key
	if unix  use file
	else  use $principal
	if wkey=""  w "Parent could not open the connection in ",tcptmout," seconds. Cannot test read command. TEST FAILED." q
	;
	l -^flag1
	l +^flag2
	; Now child and parent will continue together
	w "Parent established connection",!
	;
	tstart ():serial
	s tbegtp=$h
	w "Inside TP: Going to read from the connection",!
	if unix  close file
	use conn
	read ^toolate:longwait
	use $principal
	if $TEST=0 w "could not read from device",!
	close conn
	w "Message inside TS/TC block:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	tcommit
	w "Message after TS/TC block: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
	d ^finish
	q
sender(sock,longwait)	;
	new conn
	l +^flag2
	SET ^flag1=1
	set conn="client"
	set tcptmout=45
	SET unix=$zv'["VMS"
	if unix  set file=^modname_".logx" open file:append use file
	Open conn:::"SOCKET"	; create empty socket device
	open conn:(connect=sock_":TCP":exception="u $principal  w $zpos  goto senderr":attach="client"):tcptmout:"SOCKET"
	if $t=0  w "Sender could not open connection in ",tcptmout," sec",! q
	set iosaved=$io u conn s dev=$DEVICE u iosaved
	if dev  w "Sender encountered an error FAILED",!  h
	w "Sender Opened the connection",!
	if unix  close file
	l -^flag2
	l +^flag1
	;
	use conn
	h longwait
	use $Principal
	close conn
	w "Closed the connection",!
	q
senderr	;
	close conn
	use $Principal
	w !,"OOPPPSSS from senderr",!
	zshow "*"
	q
rcverr	;
	close conn
	use $Principal
	w !,"OOPPPSSS from rcverr",!
	zshow "*"
	q
