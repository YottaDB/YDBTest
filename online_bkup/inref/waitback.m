waitback(timeout)	;
	; Wait for backup to finish
	f i=1:1:timeout q:$GET(^mubackup)=1  h 1
	if i=timeout,$GET(^mubackup)=0 w "TEST-E-backup is running too slow",!  q
	q
