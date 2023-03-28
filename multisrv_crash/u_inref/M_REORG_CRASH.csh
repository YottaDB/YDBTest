#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : PRIMARY SERVER CRASH, BACKLOG AND FAILOVER (6.17 and 6.18)
#
setenv test_debug 1
setenv gtm_test_maxdim 3
setenv gtm_test_parms "1,7"
setenv gtm_test_dbfill "IMPRTP"
#
# For this test buffer size is 1 MB and always keep log files
if ($LFE == "E") then
	setenv test_sleep_sec_long 120
	setenv test_sleep_sec_short 60
else
	setenv test_sleep_sec_long 60
	setenv test_sleep_sec_short 30
endif
setenv tst_buffsize 1048576
# if multiple job compliles a module at the same time, sometimes they fail. So pre-compile M code.
$gtm_exe/mumps $gtm_tst/com/npfill.m
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_exe/mumps $gtm_tst/com/npfill.m"

$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 8192

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
#
echo "=== STEP 1 ==="
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& reorg.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& reorg.out"
#
# Following extra set is done so that reorg has a lot of data to process and kill succeeds easily
echo "Huge SETs on primary..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/dbset.csh"
#
echo "Multiple M Processes starts in the background..."
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_sec_long
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH1:"
$sec_shell "$sec_getenv; $gtm_tst/com/rcvrstat.csh "BEFORE_SEC_B_CRASH1:" < /dev/null"

echo "=== STEP 2 ==="
# If one or more of the below 4 crash operations fails, exit the test. Continuing the test might result in misleading errors.
# But while exiting, care should be taken that all the other processes that are running e.g replication servers,
# background mumps process etc should be cleaned up.
# Insted of cleaning it up at every stage before exiting the test continues to perform all the 4 crashes unconditionally
# At the end checks if any of the above failed. If so, exit the test with a pointer to check the error messages above
# This is to simplify coding. Otherwise, each of the exit blocks will have to stop the processes
# that were not killed in the earlier operations.
set crash_failed = 0

# SECONDARY SIDE (B) CRASH
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/mu_reorg_crash.csh ; echo "'$status' >&! secondary_mu_reorg_crash.out
cat secondary_mu_reorg_crash.out
set reorg_crash_sec = `$tail -n 1 secondary_mu_reorg_crash.out`
if (0 != "$reorg_crash_sec") then
	echo "TEST-E-REORG_CRASH failed at the secondary side. Check mu_reorg_crash.csh logs."
	echo "Exit status : $reorg_crash_sec"
	set crash_failed = 1
endif
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh ; echo "'$status' >&! secondary_receiver_crash.out
cat secondary_receiver_crash.out
set rcvr_crash_status = `$tail -n 1 secondary_receiver_crash.out`
if (0 != "$rcvr_crash_status") then
	echo "TEST-E-RECEIVER_CRASH failed. Check the receiver_crash.csh logs."
	echo "Exit status : $rcvr_crash_status"
	set crash_failed = 1
endif

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/mu_reorg_crash.csh
set reorg_crash_primary = $status
if ($reorg_crash_primary) then
	echo "TEST-E-REORG_CRASH failed in the primary side. Check mu_reorg_crash.csh logs."
	echo "Exit status : $reorg_crash_primary"
	set crash_failed = 1
endif
$gtm_tst/com/primary_crash.csh
set primary_crash_status = $status
if ($primary_crash_status) then
	echo "TEST-E-PRIMARY_CRASH failed. Check mu_reorg_crash.csh logs."
	echo "Exit status : $primary_crash_status"
	set crash_failed = 1
endif

if (1 == "$crash_failed" ) then
	# It means one of the crash scripts above failed. No point in continuing. Print the error and exit
	echo "TEST-E-EXIT. One of the crash operations failed. Check the error messages above. Exiting test..."
	exit 1
endif

echo "=== STEP 3 ==="
# FAIL OVER #
echo "DOING FAIL OVER..."
$DO_FAIL_OVER
echo "ROLLBACK on SIDE (B)..."
if ($?test_debug == 1) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh save1 '*.mj* *.dat' cp nozip"
endif
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >&! rollback1.log;	\
						$grep "successful" rollback1.log'
##########################################################
source $gtm_tst/com/bakrestore_test_replic.csh
set stat_rem = `$pri_shell  "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_filter.csh > /dev/null; echo $status" `
if ($stat_rem) then
        echo "INTEG ERRORS SEEN. STOPPING THE TEST (3)"
	date
        cat error.mupip
        exit
endif
source $gtm_tst/com/bakrestore_test_replic.csh
##########################################################

# PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "on" $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh  < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& reorg.out"
#
# SECONDARY SIDE (A) UP
cd $SEC_SIDE
if ($?test_debug == 1) then
	$gtm_tst/com/backup_dbjnl.csh save2 '*.mj*' cp nozip
endif
echo "mupip_rollback.csh -fetchresync=portno -losttrans=fetch.glo *"
$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log
$grep "successful" rollback2.log

##########################################################
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck_filter.csh > /dev/null
if ($status) then
        echo "INTEG ERRORS SEEN. STOPPING THE TEST (4)"
	date
        cat error.mupip
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
        $pri_shell "$pri_getenv;  cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh ""."""
        exit
endif
source $gtm_tst/com/bakrestore_test_replic.csh
##########################################################

$gtm_tst/com/RCVR.csh "on" $portno $start_time >&! RCVR_${start_time}.out
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/bkgrnd_reorg.csh >>& reorg.out"
#
$gtm_tst/com/rfstatus.csh "AFTER_FAILOVER_DONE_AND_BOTH_UP:"

sleep $test_sleep_sec_short

echo "=== STEP 4 ==="
echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/close_reorg.csh >>& close_reorg.out"

# If the reorg process is crashed, an error will be printed in the log. Let us filter that out
$pri_shell "$pri_getenv; cd $PRI_SIDE; mv reorg.out reorg.outx ; $grep -v 'TEST-E-REORG Error: Either REORG was killed, or returned ERROR' reorg.outx > reorg.out"
$sec_shell "$sec_getenv; cd $SEC_SIDE; mv reorg.out reorg.outx ; $grep -v 'TEST-E-REORG Error: Either REORG was killed, or returned ERROR' reorg.outx > reorg.out"

$gtm_tst/com/rfstatus.csh "Before_TEST_stops:"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
