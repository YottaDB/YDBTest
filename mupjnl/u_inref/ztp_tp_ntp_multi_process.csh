#! /usr/local/bin/tcsh -f

# Previously, we have seen cases with slower boxes (like turtle/snail) with encryption turned ON and under heavy load, this test
# takes awful lot of time resolving ftok conflicts arising due to encryption initialization during database startup. The test
# system on getting full-timeout invocations of $gtm_procstuckexec script from GT.M triggers emails to the user sending the
# captured stack traces. To avoid this, set gtm_db_startup_max_wait to 300 seconds making it highly unlikely for the ftok conflicts
# to timeout frequently. The real code fix will happen later.
if ("ENCRYPT" == "$test_encryption") then
	setenv gtm_db_startup_max_wait 300		# Max of 5 minutes to resolve any ftok conflict
endif
echo "Test case : 13  ztp_tp_ntp_multi_process"
$gtm_tst/com/dbcreate.csh mumps 9
echo "Start Before image journaling"
$MUPIP set -journal=enable,before  -reg "*" |& sort -f 
mkdir ./save; cp *.dat ./save
sleep 2
set time1 = `date +'%d-%b-%Y %H:%M:%S'`
echo time1 = "$time1"
echo "Start the background jobs"
@ jobcnt = 1
while ($jobcnt < 11)
	($gtm_tst/$tst/u_inref/bkground.csh $jobcnt &) >& job_"$jobcnt".log
	@ jobcnt = $jobcnt + 1
end
echo "Wait for background job completion"
@ jobcnt = 1
set filelist = "job_$jobcnt.txt"
@ jobcnt = $jobcnt + 1
while ($jobcnt < 11)
	set filelist = "$filelist job_$jobcnt.txt"
	@ jobcnt = $jobcnt + 1
end
$gtm_tst/com/wait_for_log.csh -log "$filelist" -waitcreation -duration 3600
$GTM << EOF
	do wait^test13	; wait for all processes to detach from the database
EOF
mkdir db_befor_bkup; cp *.dat db_befor_bkup
echo "--------------------------------------------------------------------------------------------------"
echo mupip journal -recov -back '"*"' -since="time1"
$MUPIP journal -recov -back "*" -since=\"$time1\" >& back_recov.out
$grep "successful" back_recov.out
#expected result: all data updates are visible in the database
mkdir db_aftr_bkup; cp *.dat db_aftr_bkup
echo "--------------------------------------------------------------------------------------------------"
echo "Remove databases"
rm *.dat
cp  ./save/*.dat .
echo mupip journal -recov -forw '"*"'
$MUPIP journal -recov -forw "*" >& forw_recov.out
$grep "successful" forw_recov.out
#expected result: suuccess and all data should be visible
echo "End of test"
echo "====================================================================================================="
$gtm_tst/com/dbcheck.csh
