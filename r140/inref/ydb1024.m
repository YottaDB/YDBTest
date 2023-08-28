;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

parent  ; Example M program to demonstrate passing a LISTENing socket to a child through JOB command
        ; Both STDIN and STDOUT can be passed to the child (through INPUT and OUTPUT jobparameters).
        ;
        set s="socket"
        open s:::"SOCKET"       ; create a SOCKET device
        open s:(LISTEN="socket1:LOCAL":ATTACH="handle1")::"SOCKET"      ; create a listening socket
        use s:(detach="handle1")                                        ; move listening socket to "socketpool" device
        job child:(INPUT="SOCKET:handle1":OUTPUT="SOCKET:handle1":ERROR="a1.mje")       ; job a child and make it inherit
                                                                                        ; the listening socket as its stdin/stdout
        open s:(CONNECT="socket1:LOCAL":DELIMITER=$c(10))::"SOCKET"     ; connect to listening socket that child inherited
        use s
        for  read cmdop($incr(i)):1  quit:$device       ; read data written by child from the socket
        use $principal
        zwrite cmdop                                    ; display data written by child in parent
        quit
child   ;
        use $principal
        set $etrap="zwrite $zstatus halt"
        ; Establish a CONNECTION in the listening socket passed in as $principal
        write /wait
        ; Write to this socket some data that will be read (and displayed) by the parent
        for i=1:1:2  write "This is the child writing Line ",i," out of 3 lines through SOCKET device",!
	write "# Test OPEN using a socket type file name [/proc/PID/fd/1] does not assert fail (issues DEVOPENFAIL error)",!
        set stdout="/proc/"_$job_"/fd/1"
	set $ztrap="goto incrtrap^incrtrap"	; needed to transfer control to next M line after error in "open stdout" command
        open stdout
	write "# Also test that OPEN using the special socket type file name [&] does not assert fail and communicates better",!
	set stdout="&"
        open stdout
        use stdout
        write "This is the child writing Line 3 out of 3 lines through [&] device",!
        quit

