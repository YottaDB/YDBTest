endtp;
	set $ETrap="set $ecode="""" goto ERROR^imptp"
	write "Start Time of endjob: ",$zdate($Horolog,"DD-MON-YEAR 24:60:SS"),!
	;
	; Signal all processes to exit the loop
	; imptp.m can be called with any values from 0 to 10 for gtm_test_dbfillid
	; fillid zero implies a request to shut down all fillids
	set ^endloop=1 ; FIXTP, rinttp and IMPTRP do not use gtm_test_dbfillid
	set fillid=+$ztrnlnm("gtm_test_dbfillid")
	if fillid>0 set ^endloop(fillid)=1
	if fillid=0 for fillid=0:1:10 set ^endloop(fillid)=1
	;
	set jobid=+$ztrnlnm("gtm_test_jobid")
	set jmaxwait=600	; Maximum 10 minutes it should be done after setting ^endloop=1 
	if $ztrnlnm("test_reorg")'="" set jmaxwait=900 
	do wait^job
	write "End Time of endjob  : ",$zdate($horolog,"DD-MON-YEAR 24:60:SS"),!
	quit
