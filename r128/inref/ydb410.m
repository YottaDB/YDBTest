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
;
ydb410	;
	; Drive ydb410 for each of the (maximum) of 64 signals currently defined on Linux. Note on Linux, the signals
	; 20, 21, and 22 (TSTP, TTIN, TTOU) cause process suspension so avoid those. If this test ever runs on alternate
	; platforms with different numbers, this part of the test will need to be changed.
	;
	new signum,rslt,signame
	set $etrap="zshow ""*"" zhalt 1"
	for signum=1:1:64 do
	. quit:(20<=signum)&(22>=signum)	; Bypass signals 20-22
	. ; Find signal name for signum by using bash kill -L <signum>
	. do pipecmd("bash -c ""kill -l "_signum_"""",.rslt)
	. set signame=$select(1=rslt(0):"SIG"_rslt(1),1:"SIGunknown")
	. ; signame name acquired
	. write "Driving ydb410 ",signame," (",signum,"):",!
	. zsystem "ydb410 "_signum
	. if (4=signum)!(5=signum)!(6=signum)!(8=signum) do
	. . do removeCoreIfFound
	. . do removeFEFileIfFound
	. else  if (7=signum)!(11=signum) do	; These calls don't create FATAL_ERROR files unless ydb_dbglvl says to
	. . do removeCoreIfFound
	. write "**********************",!
	quit

;
; Routine to check if a core file was created for this run (one is expected). If found (and there is
; only one) remove it.
;
removeCoreIfFound
	new result,gotfilename
	do pipecmd("ls -1 core*",.result)
	set gotfilename=(1=result(0))&(1=$zlength(result(1)," "))
	if gotfilename do
	. zsystem "rm "_result(1)
	else  if (0=result(0))!('gotfilename) do
	. write "FAIL: Core file expected but not found",!
	else  do
	. write "FAIL: More than one core file unexpectedly found - they are left intact (terminating)",!
	. zhalt 1
	quit

;
; Routine to check if a FATAL_ERROR file was created for this run (one is expected). If found (and there is
; only one) remove it.
;
removeFEFileIfFound
	new result,gotfilename
	do pipecmd("ls -1 YDB_FATAL_ERROR*",.result)
	set gotfilename=(1=result(0))&(1=$zlength(result(1)," "))
	if gotfilename do
	. zsystem "rm "_result(1)
	else  if (0=result(0))!('gotfilename) do
	. write "FAIL: FATAL_ERROR file expected but not found",!
	else  do
	. write "FAIL: More than one FATAL_ERROR file unexpectedly found - they are left intact (terminating)",!
	. zhalt 1
	quit

;
; Routine to execute a command, read in the results storing them in the supplied array and setting
; the index 0 element to the count of elements in the array.
;
pipecmd(incmd,rslt)
	new cmd,pipe,olinecnt,saveio
	kill rslt			; Get rid of any old results
	set saveio=$io			; Save what IO we were using
	set pipe="cmd"
	open pipe:(shell="/bin/sh":command=incmd)::"PIPE"
	use pipe
	for olinecnt=1:1 read rslt(olinecnt) quit:$zeof
	close pipe
	set rslt(0)=olinecnt-1		; Set count of output lines
	kill rslt(olinecnt)		; Probably wasn't set but just in case
	use $io				; Restore IO device in use
