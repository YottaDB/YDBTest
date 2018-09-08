;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
parent  ;
	write "# Setting $ZTRAP to run ""do ztrap"" when TPTIMEOUT error occurs",!
        set $ztrap="do ztrap"

	write "# Open a listening socket",!
        set s="socket"
        open s:(LISTEN="socket1:LOCAL")::"SOCKET"
        use s

	use $principal write "# Jobbing off child",! use s
	set jmaxwait=0
	set ^job1=$job	; signal parent pid to child
        do ^job("child^ydb348a",1,"""""")

	use $principal write "# Waiting for socket connection from child",! use s
        write /wait     ; when this command returns, a connection has been accepted
        use s

	use $principal write "# Setting $ZMAXTPTIME to 1 second",! use s
        set $zmaxtptime=1

	use $principal write "# Start TP transaction",! use s
        tstart ():serial

	use $principal write "# READ from socket device (child will never write to this so READ will eventually cause TPTIMEOUT)",! use s
        read x

        tcommit
        quit

child   ;
	set ^child1=$job	; so calling script can later ensure we are dead before exiting
        set s="socket"
        open s:(CONNECT="socket1:LOCAL")::"SOCKET"
        use s
        ; sleep loop forever so parent goes to $ztrap due to tptimeout ($ZMAXTPTIME is 1 second)
	; child will terminate itself once parent terminates
        for  hang 0.1  quit:'$$^isprcalv(^job1)
        quit

ztrap   ;
	use $principal
	write "# Entered $ZTRAP due to TPTIMEOUT error : $ZSTATUS = ",$ZSTATUS,!
	write "# Verify the socket device is NOT interrupted (i.e. ZINTERRUPT does not show up in ZSHOW D output of ""socket"" device)",!
	zshow "D"
	write "# CLOSE the connected socket device while still in $ZTRAP",!
        close s
	write "# OPEN the interrupted socket device again while still in $ZTRAP. This used to GTMASSERT before #348 fixes",!
        open s::"SOCKET"        ; try open of a socket which had been interrupted
        halt
