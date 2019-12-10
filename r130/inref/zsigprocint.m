;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This routine checks if the signal sent using $zsigproc is delivered
; Parameters: first argument available through $zcmdline is considered as signal number or name to be sent
; Result: prints the location where the signal is received
zsigprocint
	set $zinterrupt="write ""interrupt occurred at : "",$stack($stack-1,""PLACE""),! set $ztexit=1"
	write "$zinterrupt = ",$zinterrupt,!
	write "delivering interrupt",!
	if '$zsigproc($j,$zcmdline) write "interrupt sent to process",!
	set p=0
	for  do  quit:$ztexit'=0
	 . set p=p+1
