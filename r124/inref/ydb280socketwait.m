;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb280socketwait	;
	;
	set s="soc"
        open s:::"SOCKET"
        use s
	set start=$horolog
        write /wait
	set end=$horolog
	set diff=$$^difftime(end,start)
	use $principal
	write "; We expect the elapsed time of the WRITE /WAIT to be 0 seconds. In rare cases it is possible it is 1 second",!
	write "; if we were on the edge of a 1-second rollover when the WRITE /WAIT started. So allow 1 second too.",!
	write:(diff<2) "PASS : WRITE /WAIT on a SOCKET device with NO sockets took <= 1 second as expected",!
	write:(diff'<2) "FAIL : WRITE /WAIT on a SOCKET device with NO sockets took ",diff," seconds which is > 1 second",!
        quit
