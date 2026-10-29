;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; An error in $ETRAP or $ZTRAP code after a device EXCEPTION ran in that code, for r208/trap_after_exception-ydb1329
;
ydb1329
	quit

exc	; An error in $ETRAP code after a device EXCEPTION was invoked from that code
	do run("$ETRAP","ERRWETRAP")
	quit

ztr	; An error in $ZTRAP code after a device EXCEPTION was invoked from that code
	do run("$ZTRAP","ERRWZTRAP")
	quit

run(trap,err)
	new zstatus,excn
	do excrun(1,trap)
	do report(zstatus,err,"after a device EXCEPTION ran in "_trap_" code")
	do excrun(0,trap)
	do report(zstatus,err,"without a device EXCEPTION")
	quit

excrun(dev,trap)	; The $ETRAP of this frame records $ZSTATUS and QUITs back to the caller
	new $etrap
	set zstatus="",$etrap="set zstatus=$zstatus,$ecode="""" quit"
	do excsub(dev,trap)
	quit

excsub(dev,trap)
	if "$ETRAP"=trap new $etrap set $etrap="do:dev excio write 1/0"
	else  new $ztrap set $ztrap="do:dev excio write 1/0"
	write 1/0
	quit

excio	; READ past the end of an empty file, which invokes the device EXCEPTION. The error after the EXCEPTION
	; runs this error trap code again, so open and read the file only the first time.
	new file
	set file="ydb1329exc.txt"
	if $increment(excn)=1 open file:(newversion:exception="use $principal write ""device EXCEPTION ran"",!") use file read x read x
	use $principal
	write "back in the error trap code after the device EXCEPTION, call ",excn,!
	quit

report(zstatus,err,what)
	new ok
	set ok=(zstatus[err)&(zstatus["DIVZERO")
	write $select(ok:"PASS",1:"WRONG")," : $ZSTATUS ",what," has ",err," and DIVZERO"
	write:'ok " : $ZSTATUS is ",zstatus
	write !
	quit
