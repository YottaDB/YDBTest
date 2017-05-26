; While BACKUP process is waiting for KIP to reset it should take care of following factors
; 1) It should not hold crit on any regions
;	The first part of the test does "set" for a given region. If backup is holding crit "set" will have to wait until
;	BACKUP errors out and releases crit. Hence "set" operation will fail
; 2) It should inhibit future kills
;	The second part of the routine tests "KILL" on a given region. KILL should ideally wait for BACKUP to issue a
;	BACKUPKILLIP message and reset inhibit_kills counter.
checktime(maxsettime,maxkilltime,var,treg)
	set success=1 ; Default is TRUE
	; Randonmly select TP or NON-TP
	set ttype=$r(2)
	; Check time taken by set on treg
	set maxtime=maxsettime
	write "Start set in region : ",!
	set h1=$h
	if ttype=1 tstart ():serial
	set @var=1
	if ttype=1 tcommit
	write "End set in region : ",!
	set h2=$h
	set dif=$$^difftime(h2,h1)
	if dif>maxtime write "Setting global variable took too long than expected ",dif,! set success=0
	; Check time taken by KILL on treg
	set maxtime=maxkilltime
	write "Start Kill in region : ",!
	set h1=$h
	if ttype=1 tstart ():serial
	kill @var
	if ttype=1 tcommit
	set h2=$h
	write "End Kill in region : ",!
	set dif=$$^difftime(h2,h1)
	if dif<maxtime write "Kills were not inhibited, wait time is :",dif,! set success=0
	quit success
