cnflread;
	do ^job("readjob^cnflread",6,"""""")
	quit
	;
readjob;
	SET $ZT="SET $ZT="""" g ERROR^cnflread"
	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
        W "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	set maxrange=1024
	set begstr=$o(^a(""))
        set endstr=$o(^a(""),-1)
        set begtr=$tr(begstr," ",0)
        set endtr=$tr(endstr," ",0)
        set beg=+begtr
        set end=+endtr                    
	if end>(beg+maxrange) set end=beg+maxrange
	W "Read Index:",beg,":",end,!
	;
	W "Read Outside TP:",!
	set time1=$H
	set elapsed=0
	; Do the reads of huge globals. Since the update process is also running concurrently, this will cause restarts
	; which is what caller of this M program intends to acheive. However, we have seen that, on AIX, the jobbed off
	; M programs takes a much longer time to complete in certain cases. Currently, the only reason that could cause
	; this issue is the number of global buffers that this test uses (512). Since the number of iterations the for
	; loop does is 1024 (at the max), it causes the cache to be dry cleaned a lot more frequently than one would expect.
	; Since the primary side continues to do the updates until the jobbed off programs complete, this causes lots of
	; updates to be generated which in-turn results in low disk space causing test failures. See
	; <upd_rest_long_running_jobs> for details. To avoid such long running jobbed off M programs, limit the loop so
	; that it does not run beyond 1 minute. This time window is sufficient as the for-loop iteration is no more than 1024
	; and should be done in a few seconds and yet cause restarts.
        f I=beg:1:end  quit:elapsed>60  DO
        . set dummy=$GET(^a($j(I,10)))
        . set dummy=$GET(^b($j(I,10)))
        . set dummy=$GET(^c($j(I,10)))
        . set dummy=$GET(^d($j(I,10)))
        . set dummy=$GET(^e($j(I,10)))
        . set dummy=$GET(^f($j(I,10)))
        . set dummy=$GET(^g($j(I,10)))
        . set dummy=$GET(^h($j(I,10)))
        . set dummy=$GET(^i($j(I,10)))
	. write "Time at I=",I," is : ",$H,!
	. set time2=$H
	. set elapsed=$$^difftime(time2,time1)
	w "End   Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	;
        q
ERROR	ZSHOW "*"
	IF $TLEVEL TROLLBACK
	q
