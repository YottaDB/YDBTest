#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
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
setenv gtm_test_maxdim 15
setenv gtm_test_parms "1,7"
setenv gtm_test_dbfill "IMPRTP"
#
# For this test buffer size is 1 MB and always keep log files
if ($LFE == "E") then
	setenv test_sleep_sec_short 30
else
	setenv test_sleep_sec_short 15
endif
setenv tst_buffsize 1048576
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 5000 8192 5000

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "=== STEP 1 ==="
echo "GTM Process starts in background..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
echo "On Primary:"
$MUPIP set -journal=enable,on,before,epoch=900,extension=0,auto=16384,alloc=16384 -reg AREG
$MUPIP set -journal=enable,on,before,epoch=30,extension=1,auto=16384 -reg EREG
$MUPIP set -journal=enable,on,before,epoch=900,auto=16384 -reg FREG
$MUPIP set -journal=enable,on,before,epoch=10,auto=16384 -reg GREG
$MUPIP set -journal=enable,on,before,epoch=30,auto=16384 -reg HREG
$MUPIP set -journal=enable,on,before,epoch=60,auto=16384 -reg DEFAULT
# Work around bug GTM-5229/<GTM_5229_NOPREVLINK_errors>
$MUPIP set -journal=enable,on,before -reg '*' >&! GTM_5229_NOPREVLINK_errors_1.out
if ($?test_replic == 1) then
	echo "On Secondary:"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=30,alloc=2048,exten=2000,auto=18048 -reg BREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=30,auto=16384 -reg CREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=900,auto=16384 -reg DREG"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before,epoch=60,auto=20000,alloc=16000,exten=200 -reg DEFAULT"
	# Work around bug GTM-5229/<GTM_5229_NOPREVLINK_errors>
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set -journal=enable,on,before -reg '*' >&! GTM_5229_NOPREVLINK_errors_2.out"
endif
$gtm_tst/com/wait_for_n_jnl.csh -lognum 10 -duration 3600 -poll 5

# Before crashing the source and receiver sides (next step), ensure the replication servers on the source and receiver side
# have connected and exchanged history records. This is necessary to prevent INSNOTJOINED errors in a later reconnect.
# Below is an explanation for why. Let us say B did not see A's history record by the time it is crashed a little later in
# this test. It would then be restarted as a primary (after a failover) without having inherited the replication configuration
# group information from A. It would then create a new replication configuration group information on its own. And so later
# when A connects as a receiver to the new primary B, it would get an INSNOTJOINED error because the group information is
# different in the instance files on both sides. Since history record information is inherited by the receiver AFTER having
# inherited the group information, waiting for the history record to be seen in the update process log file is a sure shot
# way of ensuring the group information of A is recorded in B's replication instance file before crashing B.
setenv start_time `cat start_time`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"

# PRIMARY SIDE (A) CRASH

echo "=== STEP 2 ==="
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH1:"
$gtm_tst/com/primary_crash.csh
$sec_shell "$sec_getenv; $gtm_tst/com/rcvrstat.csh "BEFORE_SEC_B_CRASH1:" < /dev/null"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
$gtm_tst/com/backup_dbjnl.csh save1 '*.dat *.mj* *.gld *.repl*' cp nozip
echo "mupip_rollback.csh -losttrans=lost1.glo * >&! rollback1.log"
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >&! rollback1.log
$grep "JNLSUCCESS" rollback1.log
##########################################################
# Catch error with the above command and don't go on
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck_filter.csh -nosprgde
if ($status) then
        echo "INTEG ERRORS SEEN. STOPPING THE TEST (1)"
        echo "The errors found (other than "kill in progress" related ones)"
        cat error.mupip
        exit
endif
source $gtm_tst/com/bakrestore_test_replic.csh
##########################################################

# PRIMARY SIDE (A) UP
echo "=== STEP 3 ==="
echo "Restarting (A) as primary..."
setenv start_time `date +%H_%M_%S`
$gtm_tst/com/SRC.csh "on" $portno $start_time >&! START_${start_time}.out
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
$gtm_tst/com/wait_for_n_jnl.csh -lognum 13 -duration 3600 -poll 5
$MUPIP set -journal=enable,on,before,epoch=90,alloc=2048,extension=1950,auto=17648 -reg AREG
$MUPIP set -journal=enable,on,before,epoch=900,alloc=16384,extension=0,auto=16384 -reg BREG
# Work around bug GTM-5229/<GTM_5229_NOPREVLINK_errors>
$MUPIP set -journal=enable,on,before -reg '*' >&! GTM_5229_NOPREVLINK_errors_3.out
# PRIMARY SIDE (A) CRASH
echo "=== STEP 4 ==="
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH2:"
$gtm_tst/com/primary_crash.csh
$gtm_tst/com/backup_dbjnl.csh save2 '*.dat *.mj* *.gld *.repl*' cp nozip
echo "mupip_rollback.csh -losttrans=lost2.glo * >&! rollback2.log"
$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >&! rollback2.log
$grep "JNLSUCCESS" rollback2.log
##########################################################
# Catch error with the above command and don't go on
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck_filter.csh -nosprgde
if ($status) then
        echo "INTEG ERRORS SEEN. STOPPING THE TEST (2)"
        echo "The errors found (other than "kill in progress" related ones)"
        cat error.mupip

        exit
endif
source $gtm_tst/com/bakrestore_test_replic.csh
##########################################################


# PRIMARY SIDE (A) UP
echo "=== STEP 5 ==="
echo "Restarting (A) as primary..."
setenv start_time `date +%H_%M_%S`
$gtm_tst/com/SRC.csh "on" $portno $start_time >&! START_${start_time}.out
setenv gtm_test_jobid 3
$gtm_tst/com/imptp.csh >>&! imptp.out
$MUPIP set -journal=enable,on,before,epoch=900,alloc=16384,extension=0,auto=16384 -reg AREG
$gtm_tst/com/wait_for_n_jnl.csh -lognum 16 -duration 3600 -poll 5
$MUPIP set -journal=enable,on,before,epoch=900,alloc=2048,extension=1950,auto=17648 -reg BREG
# Work around bug GTM-5229/<GTM_5229_NOPREVLINK_errors>
$MUPIP set -journal=enable,on,before -reg '*' >&! GTM_5229_NOPREVLINK_errors_4.out
echo "=== STEP 6 ==="
# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH3:"
$gtm_tst/com/primary_crash.csh
$gtm_tst/com/backup_dbjnl.csh save3 '*.dat *.mj* *.gld *.repl*' cp nozip

echo "=== STEP 7 ==="
# FAIL OVER #
echo "DOING QUICK FAIL OVER..."
$DO_FAIL_OVER
echo "ROLLBACK on SIDE (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh save4 '*.dat *.mj* *.gld *.repl*' cp nozip"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'mupip_rollback.csh -losttrans=lost3.glo "*" >&! rollback3.log; \
										$grep "JNLSUCCESS" rollback3.log'

##########################################################
# Catch error with the above command and don't go on
source $gtm_tst/com/bakrestore_test_replic.csh
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_filter.csh -nosprgde" >&! pri_shell_dbcheck_filter.out
$grep 'No errors detected by integ' pri_shell_dbcheck_filter.out >& /dev/null
if ($status) then
        echo "INTEG ERRORS SEEN. STOPPING THE TEST (3)"
        echo "The errors found (other than "kill in progress" related ones)"
        cat pri_shell_dbcheck_filter.out
        exit
endif
source $gtm_tst/com/bakrestore_test_replic.csh
##########################################################

# PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "on" $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
# SECONDARY SIDE (A) UP
cd $SEC_SIDE
echo "mupip_rollback.csh -fetchresync=portno -losttrans=fetch.glo *"
$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback4.log
$grep "JNLSUCCESS" rollback4.log

##########################################################
# Catch error with the above command and don't go on
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck_filter.csh -nosprgde
if ($status) then
        echo "INTEG ERRORS SEEN. STOPPING THE TEST (4)"
        echo "The errors found (other than "kill in progress" related ones)"
        cat error.mupip
        $pri_shell "$pri_getenv;  cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh on"
        exit
endif
source $gtm_tst/com/bakrestore_test_replic.csh
##########################################################

$gtm_tst/com/RCVR.csh "on" $portno $start_time >&! RCVR_${start_time}.out
$gtm_tst/com/rfstatus.csh "AFTER_FAILOVER_DONE:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh  < /dev/null "">>&!"" imptp.out"
sleep $test_sleep_sec_short

echo "=== STEP 8 ==="
echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
