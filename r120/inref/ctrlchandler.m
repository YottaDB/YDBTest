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
;
; Try to drive an error handler inside direct mode
;
	write "Invoking mumps with $zcmdline = ",$zcmdline,!
        set savelvl=$zlevel
        set $etrap="do etraperror"
        set xstr="use $Principal:(CTRAP=$char(3):exception=""do gotctrlc^ctrlchandler"":"_$zcmdline_")"
	xecute xstr
        write "Hit ^C now",!
        hang 15
        write "We erroneously continued",!
        quit

;
; Come here during ^C ?
;
etraperror
        write "Made it to error trap",!
        break
        zgoto savelvl:exit
exit    quit

;
; Control-C handler
;
gotctrlc
        write "Made it to ctrl-C handler",!
        break
        zgoto savelvl:exit

