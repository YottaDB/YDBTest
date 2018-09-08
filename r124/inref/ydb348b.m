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
	write "# Setting $ZINTERRUPT to run ""do zintr"" when MUPIP INTRPT occurs",!
        set $zinterrupt="do zintr"

	write "# Open a listening socket",!
        set s="socket"
        open s:(LISTEN="socket2:LOCAL")::"SOCKET"
        use s

	use $principal write "# Jobbing off child",! use s
	set jmaxwait=0
	set ^job2=$job	; signal parent pid to child
        do ^job("child^ydb348b",1,"""""")

	use $principal write "# Waiting for socket connection from child",! use s
        write /wait     ; when this command returns, a connection has been accepted
        use s

	use $principal write "# Signal to child that parent is now ready to do a ""READ"" that can be interrupted",! use s
	set ^state="read"

	use $principal write "# READ from socket device (child will never write to this so READ will eventually cause TPTIMEOUT)",! use s
        read x

        quit

child   ;
	set ^child2=$job	; so calling script can later ensure we are dead before exiting
        set s="socket"
        open s:(CONNECT="socket2:LOCAL")::"SOCKET"
        use s
	for   quit:$get(^state)="read"  hang 0.1 ; wait until parent reaches "READ" command
	zsystem "$ydb_dist/mupip intrpt "_^job2
        ; sleep loop forever so parent can be mupip interrupted; child will terminate itself once parent terminates
        for  hang 0.1  quit:'$$^isprcalv(^job2)
        quit

zintr	;
	use $principal
	write "# Entered $ZINTERRUPT due to MUPIP INTRPT",! zwrite $ZININTERRUPT
	write "# Verify the socket device is interrupted (i.e. ZINTERRUPT does show up in ZSHOW D output of ""socket"" device)",!
	zshow "D"
	write "# CLOSE the connected socket device while still in $ZINTERRUPT code",!
        close s
	set $etrap="zwrite $zstatus halt"
	use $principal
	write "# OPEN the interrupted socket device again while in $ZINTERRUPT code. This should issue ZINTRECURSIO error",!
        open s::"SOCKET"        ; try open of a socket which had been interrupted
        quit
