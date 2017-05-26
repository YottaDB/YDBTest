	;;; online2.m
	;===============================================================
update	n
	set unix=$ZV'["VMS"
	l +^lock1
	f i=0:1:120 l +^lock2:0 q:'$T  l -^lock2  h 1
	i  s ^config("conclusn")="ERROR: Tired of waiting for backup to start."  q
	f i=0:1:^config("largnum")  s ^update(i)=$P($H,",",2),^counter=i q:^config("backupdone")<i
	i i=^config("largnum"),^config("backupdone")'<i  s ^config("conclusn")="FAILED: update process finishes before the backup process, increase largnum"
	s ^config("updatedone")=i
	q
	;===============================================================
backup	n
	set unix=$ZV'["VMS"
	f i=0:1:120 l +^lock1:0 q:'$T  l -^lock1  h 1
	i  s ^config("conclusn")="ERROR: Tired of waiting for update to start."  q
	l +^lock2
	f i=0:1:120  q:^counter>100  h 1
	i i=120  s ^config("conclusn")="ERROR: Tired of waiting for update to start 2."  q
	s ^backup("start")=^counter,startime=$H,^backup("start","time")=startime
	if 'unix zsy "@online2b.com"
	else  do
	.	zsy "$gtm_tst/$tst/u_inref/wait_and_trace_backup.csh >&! wait_for_backup.logx & ; $gtm_exe/mupip backup -i -dbg -o -t=1 DEFAULT online2.inc >& backup_output.outx"
	.	if $zsystem write "TEST-E-EXEC Error in execution of backup related scripts"
	s ^backup("end")=^counter+100,endtime=$H,^backup("end","time")=endtime
	s dif=$$^difftime(endtime,startime)
	s ^backup("lasted")=^backup("end")-^backup("start"),^backup("lasted","time")=dif
	s ^config("backupdone")=^backup("end")
	if unix do
	.	zsy "$gtm_tst/com/wait_for_stack_trace_allusers.csh >&! wait_for_stack.logx"
	.	if $zsystem write "TEST-E-EXEC Error in execution of wait_for_stack_trace_allusers"
	s ^backupfinished=1
	q
	;===============================================================
verify	n
	set unix=$ZV'["VMS"
	s maxutime=0,ups=0,updwaitingforlongtime=0
	if ^backup("lasted","time")=0 s ^backup("lasted","time")=1
	; 1/5th of the backup time
	s backupmaxwait=^backup("lasted","time")/^config("threshld","times")
	s maxwaitallowed=$select(backupmaxwait>^config("threshld","basetime"):backupmaxwait,1:^config("threshld","basetime"))
	f i=^backup("start"):1:^backup("end")  d
	.	s temp=^update(i)-^update(i-1)
	.	s:temp<0 temp=temp+86400
	.	s:maxutime<temp maxutime=temp
	.	s:temp>maxwaitallowed updwaitingforlongtime=updwaitingforlongtime+1
	.	s:temp=0 ups=ups+1
	.	s:temp'=0 ^ups(^update(i-1))=ups,ups=0
	; for faster machine maxutime and ^backup("lasted","time") could be zero
	if maxutime=0 s maxutime=1
        s ^config("maxutime")=maxutime
	; if for at least 2 updates the inter-update interval is greater than maxwaitallowed, signal failure
	; One update can take a long time(say 30 sec), due to system load. 
	; To ward off spurious failures and since sys hiccups take place over long intervals,check 2 updates
	i updwaitingforlongtime>1 s ^config("conclusn")="FAILED: The update interval is too long."
        s ^config("updatepersecondduringbackup")=^backup("lasted")/^backup("lasted","time")
	i ^config("updatepersecondduringbackup")<^config("threshld","updatepersecondduringbackup")  s ^config("conclusn")="FAILED: Not enough updates per second during backup"
	q
	;===============================================================
main	n
	; test configuration
	SET $ZT="SET $ZT="""" g ERROR^online2"
	set unix=$ZV'["VMS"
	s timeout=3600						; time to wait
	s debug="FALSE"						; when debugging, set to "TRUE"
	s ^config("timeout")=timeout				; save a copy
	s ^config("threshld","times")=5				; max interupdate time !> 1/5 backup run time
	s ^config("threshld","basetime")=20			; with the min of 20 sec
	s ^config("largnum")=1000000				; number of updates (atlhxit1 : 10 seconds)
	if 'unix d
	. s ^config("threshld","updatepersecondduringbackup")=10; decision threshold
	else  d
	. s ^config("threshld","updatepersecondduringbackup")=20	; decision threshold
	s ^config("threshld","times")=5				; decision threshold
	s ^config("conclusn")="PASSED"				; assume we can pass 
	s ^config("backupdone")=^config("largnum")		; flag for backup status
	s ^config("updatedone")="FALSE"				; flag for updater status
	s ^counter=0                            		; update/backup communication
	s ^clr="U $p:(X=0:Y=0:CLEARSCREEN)"
	; start testing
	f i=0:1:^config("largnum")  s ^update(i)=172800
	if 'unix do
	. job backup^online2:(det:out="online2b.log":gbl="online2.gld":err="online2b.err":startup="startup.com")
	. job update^online2:(det:out="online2u.log":gbl="online2.gld":err="online2u.err":startup="startup.com")
	else  do
	. job backup^online2:(out="online2b.log":gbl="online2.gld":err="online2b.err")
	. job update^online2:(out="online2u.log":gbl="online2.gld":err="online2u.err")

	f k=0:1:timeout  d  q:$d(^config("maxutime"))'=0
	.	i ^config("conclusn")'="PASSED"  q
	.	i ^config("updatedone")'="FALSE",$D(^backupfinished)  d verify^online2  q
	. 	h 1
	.	i debug="TRUE"  x ^clr  w "time : ",k
	i k=timeout s ^config("conclusn")="ERROR: Tired of waiting for update and backup to finish. Update done: "_^config("updatedone")_"backupfinished: "_$D(^backupfinished)
	w ^config("conclusn")
	i ^config("conclusn")'="PASSED"  zwr ^config   zwr ^backup
	q
	;===============================================================
ERROR	zshow "*"
	q
