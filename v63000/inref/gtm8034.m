;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Show that using the same file name for output and error does not cause the
; JOB command to fail when view "JOBPID":1 is in effect
gtm8034
	new $ETRAP
	set $ETRAP="use $p write $zstatus,! set $ecode="""""
	view "JOBPID":1
	job ^%XCMD:(cmdline="write ""PASS"",!":output="xcmd.out":error="xcmd.out")
	set file="xcmd.out."_$zjob
	set waitstatus=$$FUNC^waitforfilecreate(file,30,1)
	quit:waitstatus
	open file
	use file:follow
	for  read line quit:$length(line)
	use $p
	write line,!
	halt
