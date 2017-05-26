;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7770 ; test case to show the using JOB parameters with length > 128
	; do not cause GT.M to dump core. GT.M must also reject JOB
	; parameters greater than 256 characters must be rejected due
	; to an implementation limitation that stores the string length
	; in one byte! Previously this resulted in an assert failure
	write "TEST-W-WARN: should not get here",!
	quit
	; UNIX SIG-11 at 128 char str
	; VMS SIG-11 at 197 char str
test128
	do ^echoline
	set $ETRAP="do err^gtm7770(197)"
	write "Exceed 127 characters limit, this used to core",!
	do xjob($$path(197))
	do ^echoline
	quit
	; UNIX and VMS assert fail at 256 char str
test256
	do ^echoline
	set $ETRAP="do err^gtm7770(256)"
	write "Exceed 255 characters limit, this used to assert fail",!
	do xjob($$path(256))
	do ^echoline
	quit
	; DRY
xjob(str)
	xecute "job ^gtm7770:default="""_str_$char(34)
	quit
	; Use a valid path
path(len)
	set str=$tr($justify(" ",len)," ","A")
	if $zversion["VMS" set $e(str,1)="[",$e(str,$l(str))="]"
	else  set $e(str,1)="/"
	quit str
	; error trap to catch JOBFAIL and JOBPARTOOLONG
err(len)
	set last=4
	if len=256,$zstatus["JOBPARTOOLONG" set $ecode=""
	if len=197,$zstatus["JOBFAIL" set $ecode=""
	if len=197,$zstatus["PARFILSPC" set $ecode="",last=3
	write $piece($zstatus,",",3,last),!
	quit:$ecode=""
	zwrite $zstatus
	write "TEST-F-FAIL",!
	quit
