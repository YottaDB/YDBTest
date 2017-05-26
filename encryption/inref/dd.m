;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Helper utility for the iv_ops test to dump a fragment of a binary file.
dd
	set offset=+$piece($zcmdline," ",1)
	set length=+$piece($zcmdline," ",2)
	set file=$piece($zcmdline," ",3)
	set step=2**16
	open file:(readonly:fixed:recordsize=step:seek=offset\step)
	use file
	read line#(offset#step)
	read line#length
	close file
	write line
	set $x=0
	quit
