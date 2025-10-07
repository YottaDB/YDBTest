;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-8793 - Test we get new EXITSTATUS error when script defined by ydb_procstuckexec is driven and returns non-zero code
;
; Test methodology:
;
;    1. Create database, initialize $ydb_procstuckexec to drive 'noexistPSE.csh' (a non-existent script)
;    2. Start a DSE session in a pipe so we can control what happens.
;    3. In the DSE session do a 'crit -seize' command.
;    4. Drive '$ydb_dist/yottadb -run ^%XCMD "set ^x=1" in a pipe.
;    5. Wait 30 seconds, and the procstuckexec should fire when the MUTEXLCKALERT occurs then wait 60 more seconds
;       for slow and/or loaded systems to react to the timeout.
;    6. Verify the EXITSTATUS error was sent to syslog from thejobbed off process.
;    7. Stop the sub-processes and wait them to go away before exiting.
;
gtm8793
	; Initialization
	set debug=0
	set outFile="gtm8793_syslog_extract.txt"
	set ydbPipeOpen=0
	; setup array of the messages we want to see in the reference file (EXITSTATUS and its friends)
	set msg(0)=3
	set msg(1)="STUCKACT"	      	      	 ; This is typically the first message seen in this situation
	set msg(2)="EXITSTATUS"			 ; Typcally the 2nd message
	set msg(3)="MUTEXLCKALERT"		 ; .. and the 3rd
	; Start test
	write "# Test GTM-8793 - Verify that if the script defined by ydb_procstuckexec fails, we get an EXITSTATUS error in syslog",!
	write "#",!
	write "# Spawning DSE process and seizing the critical section",!
	set dsePipe="DSEPIPE"
	open dsePipe:(command="$ydb_dist/dse")::"PIPE"
	use dsePipe
	set dsePID=$key				; Not really DSE PID but the shell running it
	write "crit -seize",!			; Should grab crit for our DEFAULT region
	use $p
	; Wait for crit to be seized (it happens asynchronous to us) for a max of 30 seconds
	for i=1:1:30 set gotCrit=$$^%PEEKBYNAME("node_local.in_crit","DEFAULT") quit:(0'=gotCrit)  hang 1
	if (0=gotCrit) do
	. write "FAILURE - crit never got seized",!!
	. zshow "*"
	. zhalt 1
	write !
	write "# Spawning YDB process to attempt update, get stuck waiting for crit, and eventually get a",!
	write "# MUTEXLCKALERT warning.",!
	; Note the command we execute below prints the processID of the ydb process so use that to set ydbPID.
	set ydbPipe="YDBPIPE"
	open ydbPipe:(command="$ydb_dist/yottadb -run ^%XCMD 'write $job,! set ^x=1'")::"PIPE"
	set ydbPipeOpen=1
	use ydbPipe
	read ydbPID
	use $p
	write !,"# Wait for MUTEXLCKALERT error to occur which should then drive the ydb_procstuckexec defined script",!
	write "# (that does not exist) which should cause an immediate EXITSTATUS error in the syslog. Since we can't wait",!
	write "# specifically for the error, wait up to 90 seconds (30 second timeout plus 60 seconds for slow/loaded systems)",!
	write "# extracting the syslog every 5 seconds so we can stop relatively quickly after the error occurs on faster systems.",!
	hang 20	       	    		   	; Wait at least this long before we record the start time we are interested in
	; Now (hopefully about 10 seconds before everything pops), record the time we will use to feed into
	; com/getoper.csh to extract all messages since this time after the rest of the wait (total 90 seconds).
	set logStart=$zdate($H,"MON DD 24:60:SS","Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec") ; Record time before start hang job
	hang 11			       		; Hang the rest of time till MUTEXLCKALERT plus 1 sec for processing before
						; we start checking the syslog for the errors.
	; Hang the rest of the time in 5 second intervals looking for our errors as well as verifying our processes are
	; still alive.
	set (error,found)=0
	for i=0:1:14 do  quit:found!error  hang 5
	. set found=$$checkForEXITSTATUS(i) quit:found
	. set:(0'=$zsigproc(ydbPID,0)) error=1
	. set:(0'=$zsigproc(dsePID,0)) error=1
	if error do				; We ended early due to one of our processes going away
	. write "FAILURE - One of our processes exited early - surviving process:",!
	. zsystem "ps -ef | $grep -E """_ydbPID_"|"_dsePID_""""
	. write !
	. do dumplogs
	. write !
	. zshow "*"
	. zhalt 1
	; We never found the EXITSTATUS error and timed out
	if 'found do
	. write "FAILURE - Timed out waiting for EXITSTATUS and its two friends (STUCKACT and MUTEXLCKALERT) to be seen in syslog",!
	. write !
	. do dumplogs
	. write !
	. zshow "*"
	. zhalt 1
	write !,"# Done with sub-processes now, tell DSE to quit, should allow termination of ydbPipe as well.",!
	use dsePipe
	write "crit -release",!
	write "quit",!
	use $p
	write !,"# Wait for DSE and M sub-processes to finish",!
	close dsePipe
	close ydbPipe
	set ydbPipeOpen=0
	for pid=dsePID,ydbPID do
	. for  quit:(0'=$zsigproc(pid,0))  hang .25	; Wait for this process to go away
	write "# Done"
	quit

; Routine to dump the logs of the two sub-processes (if they exist) so we can find the errors if any when we are in an
; error situation - something didn't work so dump the output of these two sub-processes to see if they contributed to it.
dumplogs
	new done,line
	write !,"Any output from the yottadb sub-process shown below:",!
	set done=0
	for  use ydbPipe do  use ydbPipe quit:($ZEOF!done)
	. read line:30					; After 30 seconds, timeout
	. if 0=$test set done=1 quit
	. quit:$zeof
	. use $p
	. write line,!
	use $p
	write !,"Any output from the dse sub-process shown below:",!
	set done=0
	for  use dsePipe do  use dsePipe quit:($ZEOF!done)
	. read line:30					; After 30 seconds, timeout
	. if 0=$test set done=1 quit
	. quit:$zeof
	. use $p
	. write line,!
	quit

; Routine to extract from the syslog for this test to see if we have an EXITSTATUS message yet. To be truthfull, we are
; actually looking the (3 at this time) messages that also come out with the EXITSTATUS as we want all of them to be
; shown in the reference file.
checkForEXITSTATUS(iteration)
	new i,foundCnt,pidText,foundMsg,msgIndx,msgFound,msgName
	write:debug "Entering checkforEXITSTATUS(",iteration,")",!
	; First, if we are not on the first iteration, remove the existing extract
	zsystem:(0'=iteration) "rm -f "_outFile_">& /dev/null"
	; First, extract from the system log everything from our start point until right now.
	zsystem "$gtm_tst/com/getoper.csh """_logStart_""" """" "_outFile	; Do extract from test start till now
	if 0'=$zsystem do
	. write !,"Grab from syslog failed with rc ",$zsystem," - terminating",!!
	. do dumplogs
	. write !
	. zshow "*"
	. zhalt 1
	; Open our extract file looking for the errors. We must find all of them to be complete
	open outFile
	set pidText="["_ydbPID_"]"
	set foundCnt=0
	kill foundMsg					; Sequentially indexed errors contains message name in order they occurred
	kill msgFound					; Indexed by message name containing full message from log
	for cnt=0:1 do  quit:$zeof!(msg(0)=foundCnt)
	. use outFile
	. read line
	. quit:$zeof
	. use $p
	. write:debug "Line ",cnt,": ",line,!
	. for msgIndx=1:1:msg(0) do  quit:(msg(0)=foundCnt)	; See which (if any) of our messages can be found in this line
	. . set msgName=msg(msgIndx)
	. . if ((line[pidText)&(line[msgName)&(""=$get(msgFound(msgName),""))) do
	. . . set msgFound(msgName)=line
	. . . set foundCnt=foundCnt+1
	. . . set foundMsg(foundCnt)=msgName
	. . . set msgIndx=msg(0)			; Force loop exit to get next line - only one error per line
	. zwrite:(debug&$data(foundMsg)) foundMsg
	. zwrite:(debug&$data(msgFound)) msgFound
	. zwrite:debug foundCnt
	. write:debug !
	. use outFile
	; Now, if we have all three, print them out in the order they appeared
	close outFile
	use $p
	quit:(msg(0)'=foundCnt) 0			; We did not find the errors yet - return false
	; We did find all 3 messages in the log - write them out in the order they appeared. Note we only write out the
	; meat of the message sans the syslog prefix and suffix.
	write "SUCCESS - Found the 3 required messages (including EXITSTATUS) in "_outFile_":",!
	for msgIndx=1:1:msg(0) write $zpiece($zpiece(msgFound(foundMsg(msgIndx)),": ",2,99)," -- generated",1),!
	write:debug "Exiting checkforEXITSTATUS",!
	quit 1
