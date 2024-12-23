;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtmde421008 ;
	write "# Run DSE with 'critseize^gtmde421008' to confirm that running:",!
	write !
	write "# 1. MUPIP STOP three times does NOT act as a kill -9 when a dse process that has seized crit",!
	write "#    is sent 3 mupip stops where the 2nd and 3rd stop are spaced 60+ seconds apart",!
	set seizelen=60+$random(15)
	set seizelenFile="seizelengt60.out"
	open seizelenFile:newversionFile
	use seizelenFile
	write seizelen
	close seizelenFile
	do critseize(1,seizelen)
	write !
	write "# 2. MUPIP STOP three times acts as a kill -9 when a dse process that has seized crit",!
	write "#    is sent 3 mupip stops where the 2nd and 3rd stop are spaced < 60 seconds apart",!
	; Set a random length of time < 60 seconds for crit to be held to enhance test coverage
	; and store in a file for reference in case of test failure
	set seizelen=$random(50)
	set seizelenFile="seizelenlt60.out"
	open seizelenFile:newversionFile
	use seizelenFile
	write seizelen
	close seizelenFile
	do critseize(1,seizelen)
	write !
	write "# 3. MUPIP STOP one time terminates a dse process that has NOT seized crit",!
	do critseize(0,0)
	quit

critseize(seizeCrit,hangTime) ;
	new dsePipe,dsePid,pidFile,procAlive,dseOutFile,dseResult,dseErr
	set dsePipe="DSEPIPE"
	set dseErr="DSEERR"
	; Open a pipe to a DSE process
	write "# Open a PIPE device for a DSE process and seize crit",!
	open dsePipe:(command="$gtm_dist/dse":stderr=dseErr)::"PIPE"
	use dsePipe
	write "crit -seize",!
	use $p

	; Wait for crit to be seized (it happens asynchronous to us) for a max of 30 seconds
	for i=1:1:30 set dsePid=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT") quit:(0'=dsePid)  hang 1
	if (0=dsePid) do
	. write "# FAILURE - crit never got seized",!
	. zhalt 1
	write "# SUCCESS - Seized crit for "_dsePid,!

	; Save the PID of the DSE process for later reference
	set pidFile="dse"_seizeCrit_hangTime_".pid"
	open pidFile:newversion
	use pidFile
	write dsePid
	close pidFile

	if ('seizeCrit) do
	. ; Release the critical section if the test does not require
	. ; it to be seized. In that case, it was only seized to allow
	. ; the DSE process PID to be detected by $$^%PEEKBYNAME.
	. use dsePipe
	. write "crit -release",!
	. use $p
	. ; Wait for crit to be released (it happens asynchronous to us) for a max of 30 seconds
	. for i=1:1:30 set critOwnerPid=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT") quit:(0=critOwnerPid)  hang 1
	. if (0'=critOwnerPid) do
	. . write "# FAILURE - crit never got released",!
	. . zhalt 1
	. write "# Crit released for "_dsePid,!
	else  do
	. use $p

	; Issue one or three MUPIP STOPs to the running DSE process
	write "# Issuing first MUPIP STOP to "_dsePid,!
	zsystem "$gtm_dist/mupip stop "_dsePid
	if (seizeCrit) do
	. write "# Issuing second MUPIP STOP to "_dsePid,!
	. zsystem "$gtm_dist/mupip stop "_dsePid
	. if (hangTime>=60) do
	. . write "# Wait for > 60 seconds",!
	. else  do
	. . write "# Wait for < 60 seconds",!
	. hang hangTime
	. write "# Issue third MUPIP stop to "_dsePid,!
	. zsystem "$gtm_dist/mupip stop "_dsePid

	for i=1:1:3 set procAlive=$$^isprcalv(dsePid) quit:(0=procAlive)  hang 1
	if ((1=seizeCrit)&(60<=hangTime)) do
	. write "# Verify MUPIP STOPs did not terminate the DSE process",!
	. if (0=procAlive) do
	. . write "# FAILURE - crit unexpectedly released due to MUPIP STOP",!
	. else  do
	. . write "# SUCCESS - crit held, despite MUPIP STOP",!
	. . use dsePipe
	. . write "exit",!
	. . do ^waitforproctodie(dsePid,30)
	else  do
	. write "# Verify MUPIP STOP(s) terminated the DSE process",!
	. if (0=procAlive) do
	. . write "# SUCCESS - process successfully terminated by MUPIP STOP",!
	. else  do
	. . write "# FAILURE - process not terminated by MUPIP STOP",!

	use dsePipe
	for i=1:1  read dseResult(i):0 quit:'$test!$zeof
	zkill dseResult(i)
	do:$data(piperr)
	. use dseErr
	. for i=1:1  read dseErr(i):0 quit:'$test!$zeof
	. zkill dseErr(i)
	close dsePipe
	use $p

	; Write the DSE output to a file for later reference
	set dseOutFile="dse"_seizeCrit_hangTime_".out"
	open dseOutFile:newversionFile
	use dseOutFile
	for i=1:1  quit:'$data(dseResult(i))  write dseResult(i),!
	close dseOutFile

	set dseErrFile="dse"_seizeCrit_hangTime_".err"
	open dseErrFile:newversionFile
	use dseErrFile
	for i=1:1  quit:'$data(dseErr(i))  write dseErr(i),!
	close dseErrFile

	quit
