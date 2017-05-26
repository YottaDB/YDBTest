;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitforfilecreate
	; This is the command line invocation of waitforfilecreate.
	; Please read the description below. The routine returns
	; 0 for success and non-zero for failure to the shell
	set file=$piece($zcmdline," ",1)
	set maxwait=+$piece($zcmdline," ",2)
	if maxwait<1 set maxwait=10
	zhalt $$FUNC^waitforfilecreate(file,maxwait)

	; -----------------------------------------------
	; Wait for some time for a file to be created
	; INPUT
	;   file	- file to wait for
	;   maxwait	- maximum wait duration, the default is 10 seconds
	;   neederrmsg	- whether or not an error message is needed
	; OUTPUT
	;   returns 0 on success
	;   elapsed time on failure
	;
	; attempts a readonly open using the OPEN execption handler to
	; mask the file not found error and update the elapsed time
FUNC(file,maxwait,neederrmsg)
	new start,status,exception,elapsed
	if 0=$data(file) write "TEST-W-WARN : no filename supplied",! quit
	if 0=$data(maxwait) set maxwait=10
	set start=$horolog,status=1,elapsed=0
	set exception="set ecode="""" hang 1 quit"
	for  quit:(elapsed>maxwait)!(status=0)  do
	.	set elapsed=$$^difftime($horolog,start)
	.	open file:(readonly:exception=exception)
	.	set status=0
	.	close file
	do:status
	.	set status=$select(elapsed=0:1,1:elapsed)
	.	write:$data(neederrmsg) "TEST-W-WARN : ",elapsed," sec passed waiting for '",file,"'",!
	quit:($quit) status
	quit

	; THE FOLLOWING CODE DOES NOT WORK ; ; ; ; ; ; ; ; ; ; ; ;
	; if GT.M ever supports a timeout for SD, this would work
	; at the moment GT.M reports a file not found status. The
	; expectation was that GT.M would either wait for the file
	; to exist OR set $TEST
FUNC2(file,maxwait,neederrmsg)
	new start,status,elapsed
	if $data(file)<1 write "TEST-W-WARN : no filename supplied",! quit
	if $data(maxwait)<1 set maxwait=10
	set start=$horolog,status=1,elapsed=0
	open file:(readonly):maxwait
	zwrite $TEST
	set elapsed=$$^difftime($horolog,start)
	if $data(neederrmsg)&(elapsed>maxwait) do
	.	write "TEST-W-WARN : ",elapsed," sec passed waiting for '",file,"'",!
	quit:($quit) status
	quit
