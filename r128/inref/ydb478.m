;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019-2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb478	;
	; Drive ydb478 for each of the (maximum) of 64 signals currently defined on Linux. Note on Linux, the signals
	; 20, 21, and 22 (TSTP, TTIN, TTOU) cause process suspension so avoid those. If this test ever runs on alternate
	; platforms with different numbers, this part of the test will need to be changed.
	; Signal 23 is SIGURG which Go programs see a lot so may be something Go-ish but the spurious nature of this
	; signal means rare failures in this test when it spuriously pops before the program sends it so we avoid it.
	;
	new signum,rslt,signame
	set $etrap="zshow ""*"" zhalt 1"
	write "**********************",!
	for signum=1:1:64 do
	. quit:(9=signum)				; Bypass signal 9 (SIGKILL) as it is uncatchable (and kills our test)
	. quit:(20<=signum)&(23>=signum)		; Bypass signals 20-23 (SIGTSTP, SIGTTIN, SIGTTOU, SIGURG) - cause problems
	. quit:(13=signum)				; Bypass 13 (SIGPIPE) as it hangs up Go
	. quit:(19=signum)				; Bypass 19 (SIGSTOP) as it is uncatchable
	. quit:(27=signum)				; Bypass 27 (SIGPROF) as it hangs up Go
	. quit:(32=signum)!(33=signum)!(34=signum)	; Bypass signals 32-34 (34 as of Go 1.16) as they cause Go to hang
	. ; Find signal name for signum by using bash kill -L <signum>
	. do pipecmd("bash -c ""kill -l "_signum_"""",.rslt)
	. set signame=$select(1=rslt(0):"SIG"_rslt(1),1:"SIGunknown")
	. ; signame name acquired
	. write "Driving ydb478 ",signame," (",signum,"):",!
	. zsystem "ydb478 "_signum
	. write "**********************",!
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
