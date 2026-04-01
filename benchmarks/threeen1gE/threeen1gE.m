;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

threeen1gE
	; Find the maximum number of steps for the 3n+1 problem for all integers from one through a limit.
	; See https://yottadb.com/solving-the-3n1-problem-with-yottadb/ for a general statement of the problem.
	; Assumes input is lines containing (space-separated) two integers, and an optional third integer.
	; The first integer is the largest integer whose 3n+1 sequence length is to be computed and compared.
	; The second integer is the number of parallel computation streams (processes).
	; The optional third integer is the sizes of blocks of integers on which spawned child processes operate.
	; If it is not specified, the block size is approximately the range divided by the number of parallel
	; streams.  If the block size is larger than the range divided by the number of execution streams, it is
	; reduced to that value. No input error checking is done.

	; Features used are in GT.M V6.3-000, YottaDB r1.28 and up. Compared to earlier versions of this code:
	; - Use integer subscripts and don't force number of parallel execution streams.
	; Major restructuring of code, to remove showcasing of GT.M features and to stress database access.
	; Difference from threeen1gB is that process exit time is not included in elapsed time measurement

	; At the top level, the program reads and processes input lines, one at a time.  Each line specifies
	; one problem to solve.  Since the program is designed to resume after a crash and reuse partial
	; results computed before the crash, data in the database at the beginning is assumed to be partial
	; results from the previous run.  After computing and writing results for a line, the database is
	; cleared for next line of input or next run of the program.

	; Identify this run
	set region=$view("region","^step")
	; Parameters that are always meaningful
	set dbblksz=$$^%PEEKBYNAME("sgmnt_data.blk_size",region)
	set fltrg=$$^%PEEKBYNAME("sgmnt_data.flush_trigger",region)
	set gblbuf=$$^%PEEKBYNAME("sgmnt_data.n_bts",region)
	set gtmver=$piece($zversion," ",2)
	set node=$piece($$^%PEEKBYNAME("node_local.machine_name",region),$char(0),1)
	set jnlstate=$$^%PEEKBYNAME("sgmnt_data.jnl_state",region)
	set runid=$$^%RANDSTR(1,,"A")_$$^%RANDSTR(7,,"AN")
	; Parameters that are meaningful only if journaling is on
	do:jnlstate
	. set etaper=$$^%PEEKBYNAME("sgmnt_data.epoch_taper",region)
	. set jnlsyncio=$$^%PEEKBYNAME("sgmnt_data.jnl_sync_io",region)
	. set jnltype=$$^%PEEKBYNAME("sgmnt_data.jnl_before_image",region)
	; Parameters that are meaningful for some GT.M versions, but not all
	do LIST^%PEEKBYNAME(.mnem)			; Get mnemonics for this GT.M version
	if $data(mnem("sgmnt_data.asyncio")) set asyncio=$$^%PEEKBYNAME("sgmnt_data.asyncio",region)
	; Identify locations
	set def=$zsearch($ztrnlnm("testtmp"))		; Working directory for Jobbed process *.mj[oe] files
	set:'$length(def) def=$zdirectory		; Current directory if $testtmp not defined
	set loggld=$zsearch($ztrnlnm("loggld"))		; Global directory to access database for logging results, if desired
	do:$length(loggld)				; Prepare raw (unscaled)results to log if gld provided for logging database
	. kill logrec,xref				; Precautionary kill
	. set:$length($zcmdline) logrec(runid,"cmdline")=$zcmdline,xref("cmdline",$zcmdline,runid)=""
	. set logrec(runid,"dbblksz")=dbblksz,xref("dbblksz",dbblksz,runid)=""
	. set logrec(runid,"fltrg")=fltrg,xref("fltrg",fltrg,runid)=""
	. set logrec(runid,"gblbuf")=gblbuf,xref("gblbuf",gblbuf,runid)=""
	. set logrec(runid,"gtmver")=gtmver,xref("gtmver",gtmver,runid)=""
	. set logrec(runid,"node")=node,xref("node",node,runid)=""
	. set logrec(runid,"jnlstate")=jnlstate,xref("jnlstate",jnlstate,runid)=""
	. set logrc(runid,"pgm")=$text(+0),xref("pgm",$text(+0),runid)=""
	. do:jnlstate
	. . set logrec(runid,"etaper")=etaper,xref("etaper",etaper,runid)=""
	. . set logrec(runid,"jnlsyncio")=jnlsyncio,xref("jnlsyncio",jnlsyncio,runid)=""
	. . set logrec(runid,"jnltype")=jnltype,xref("jnltype",jnltype,runid)=""
	; Loop over input, read a line (quit on end of file), process that line
	for  read input quit:$zeof!'$length(input)  do                   ; input has entire input line
	. set maxint=+$piece(input," ",1)	    			 ; maxint - 1st number is upper end of range
	. do:maxint'=$get(^limits(+$order(^limits(""),-1))) dbinit	 ; initialize database if not a crash recovery
	. set strms=+$piece(input," ",2)  		    		 ; strms  - 2nd number is number of parallel jobs
	. set blksz=+$piece(input," ",3)                                 ; blksz  - 3rd number on input line is optional blocksize
	. set tmp=maxint\strms set:'blksz!(blksz>tmp) blksz=tmp		 ; force maxint\strms>=blksz>0 so each job has some work
	. ; Define blocks of integers for child processes to work on
	. kill ^limits
	. set tmp=0
	. for i=1:1 do  quit:tmp=maxint
	. . set ^limits(i)=$increment(tmp,blksz)
	. . set:tmp>maxint (tmp,^limits(i))=maxint
	. ; Launch jobs.  Grab locks l1 and l3, atomically increment counter, compute and launch one job for each block of numbers.
	. ; Each child job locks l2(pid), decrements the counter and tries to grab lock l1(pid).
	. ; When counter is zero, all jobs have started.  Parent releases lock l1 and tries to grab lock l2.
	. ; When all children have released their l2(pid) locks, they're done and parent can gather & report results.
	. ; When all children have released locks, and parent has captured the time, it releases l3, which allows children to exit.
	. set ^count=0                                  ; Clear ^count - may have residual value if restarting from crash
	. set ^step(1)=0				; Termination condition - 1 has a zero length 3n+1 sequence
	. lock +l1,+l3                                  ; Get locks for process synchronization
	. for i=1:1:strms do
	. . if $increment(^count)                       ; Atomic increment of counter in database for process synchronization
	. . set tmp=$text(+0)_"_"_$job_"_"_i_".mj"
	. . set err=tmp_"e",out=tmp_"o"			; stderr & stdout for jobbed process
	. . set cmd="doblk(i):(error="""_err_""":output="""_out_""":default="""_def_""")"     ; Command to Job
	. . job @cmd                                    ; Job child process for next block of numbers
	. for  quit:'^count  hang 0.1                   ; Wait for processes to start (^count goes to 0 when they do)
	. lock -l1                                      ; Release lock so processes can run
	. set startat=$zut                		; Get starting time
	. ; Output timestamp and input parameters
	. write $fnumber(startat/1E6,",",6)," ",$fnumber(maxint,",",0)," ",$fnumber(strms,",",0)," ",$fnumber(blksz,",",0)
	. lock +l2                                      ; Wait for processes to finish
	. ; When parent gets lock l2, child processes have completed and parent gathers and reports results.
	. set duration=$zut-startat/1E6                 ; Compute elapsed time in seconds
	. lock -l3					; Release l3 to permit children to terminate
	. write " ",$fnumber(^longest,",",0) 		; Show largest number of steps for the range i through j
	. write " ",$fnumber(^highest,",",0)    	; Show the highest number reached during the computation
	. write " ",$fnumber(^cputime/100,",",2)	; Show total CPU time converted seconds
	. write " ",$fnumber(duration,",",3)    	; Show the elapsed time in seconds
	. write " ",$fnumber(^updates,",",0)    	; Show number of updates
	. write " ",$fnumber(^reads,",",0)      	; Show number of reads
	. set updrate=^updates/duration write " ",updrate	; Show updates/second
	. set rdrate=^reads/duration write " ",rdrate,!		; Show reads/second
	. lock -l2                             		; Release locks for next run
	. do:$length(loggld)				; Log raw (unscaled)results from this set of inputs to this run
	. . set logrec(runid,startat,"maxint")=maxint,xref("maxint",maxint,runid,startat)=""
	. . set logrec(runid,startat,"strms")=strms,xref("strms",strms,runid,startat)=""
	. . set logrec(runid,startat,"blksz")=blksz,xref("blksz",blksz,runid,startat)=""
	. . set logrec(runid,startat,"longest")=^longest,xref("longest",^longest,runid,startat)=""
	. . set logrec(runid,startat,"highest")=^highest,xref("highest",^highest,runid,startat)=""
	. . set logrec(runid,startat,"cputime")=^cputime,xref("cputime",^cputime,runid,startat)=""
	. . set logrec(runid,startat,"duration")=duration,xref("duration",duration,runid,startat)=""
	. . set logrec(runid,startat,"updates")=^updates,xref("updates",^updates,runid,startat)=""
	. . set logrec(runid,startat,"reads")=^reads,xref("reads",^reads,runid,startat)=""
	. . set logrec(runid,startat,"updrate")=updrate,xref("updrate",updrate,runid,startat)=""
	. . set logrec(runid,startat,"rdrate")=rdrate,xref("rdrate",rdrate,runid,startat)=""
	. . set:$data(asyncio) logrec(runid,startat,"asyncio")=asyncio,xref("asyncio",asyncio,runid,startat)=""
	. do dbinit                              	; Initialize database for next run
	; Log result in a database where results are accumulated.
	; Ideally, the merge would be in a transaction, but since the logging may be in a central
	; database that is accessed via GT.CM, which does not support transaction processig,
	; the code here does not use TP.
	merge ^|loggld|logrec=logrec,^|loggld|xref=xref
	quit

dbinit  ; Entryref dbinit clears database between lines
	kill ^count,^cputime,^highest,^longest,^reads,^step,^updates
	quit

; This is where Jobbed processes start
doblk(slot)					; Slot is index of ^limits() initially assigned to this process
	set (highest,longest)=0			; Start with zero highest number and longest path
	lock +l2($job)                          ; Get lock l2 that parent will wait for till this Jobbed processes exits
	if $Increment(^count,-1)                ; Decrement ^count to say this process is alive & has its lock
	lock +l1($job)                          ; Wait till parent launches and releases all processes
	; Process the next block in ^limits that does not already have a process; quit when there are no more blocks
	for  do:1=$increment(^limits(slot,1))  quit:'$data(^limits($increment(slot)))
	. set first=$select($data(^limits(slot-1)):^limits(slot-1)+1,1:1)
	. set first=1+$get(^limits(slot-1))	; first number is 1 more than number in last slot, 1 for process doing slot 1
	. set last=^limits(slot)		; last number is value in current slot
	. for current=first:1:last do		; calculate paths for integers in this block
	. . kill currpath	   		; currpath holds path to 1 for current
	. . set n=current
	. . for i=0:1 quit:$data(^step(n))  do	 ; continue till node with known sequence length is found; ^step(1) exists
	. . . set currpath(i)=n
	. . . set n=$select('(n#2):n/2,1:3*n+1)	; compute next number in sequence
	. . . set:n>highest highest=n		; see if new highest number reached by process
	. . do:$data(currpath)
	. . . set k=^step(n)
	. . . for j=i-1:-1:0 do
	. . . . set ^step(currpath(j))=$increment(k)
	. . . set:k>longest longest=k
	tstart ():transactionid="batch"		; update highest number and longest sequence found by any process
	set:highest>$get(^highest) ^highest=highest
	set:longest>$get(^longest) ^longest=longest
	tcommit
	zshow "g":dbstat			; Get database statistics
	if $increment(^reads,2+$piece(dbstat("G",0),"GET:",2)+$piece(dbstat("G",0),"DTA:",2))   ; update read statistic; +2 for this line
	if $increment(^updates,2+$piece(dbstat("G",0),"SET:",2)+$piece(dbstat("G",0),"KIL:",2)) ; update update statistic; +2 for this line
	if $increment(^cputime,$zgetjpi("","cputim"))						; accumulate CPU time statistic
	lock -l1($job),-l2($job),+l3($job)	; Release locks to indicate run complete; wait for permission from parent to exit
	lock -l3($job)				; Parent has captured elapsed time; OK for child to exit
	quit

logrun	; log results from this run
	new logrec,xref

