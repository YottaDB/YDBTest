endtp;
	SET $ZT="SET $ZT="""" g ERROR^v4imptp"
	write "Start Time of endjob: ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	;
	; Signal all processes to exit the loop
	; imptp.m can be called with any values from 0 to 10 for gtm_test_dbfillid
	set ^endloop=1  for fillid=0:1:10 set ^endloop(fillid)=1
	;
	set jobid=+$ZTRNLNM("gtm_test_jobid")
	set jmaxwait=300	; Maximum 5 minutes it should be done after setting ^endloop=1 
	if $ZTRNLNM("test_reorg")'="" set jmaxwait=900 
	d wait^job
	w "End Time of endjob  : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Q
