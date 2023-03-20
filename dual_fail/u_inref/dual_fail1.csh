#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : DUAL SITE FAILURE : CASE 1
#
#---------------------------------------------------------------|---------------------------------------
#		     A   					|	      B
#---------------------------------------------------------------|---------------------------------------
#	     P (d - 100, R = 95)				|      	S (d - 95, R = 95)
#	     P (101 - 150, R = 95)				|	    X
#		     	X					|	    X
#	     P (151 - 200, R = 95)				|	    X
#	     P (201 - d, R = 95)				|	S (B = min(95, 95) = 95, LT = none)
#---------------------------------------------------------------|---------------------------------------
#
setenv gtm_test_mupip_set_version "disable" # ONLINE ROLLBACK (used by -autorollback below) cannot work with V4 format databases
$gtm_tst/com/dbcreate.csh mumps 5 $rand_args 2000 4096 2000

setenv portno `$sec_shell "$sec_getenv; cat $SEC_DIR/portno"`
setenv start_time `cat start_time`

echo "GTM Process starts in background..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

# RECEIVER SIDE (B) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_SEC_B_CRASH:"
$sec_shell "$sec_getenv; $gtm_tst/com/receiver_crash.csh"
# primary continues to run and creates a backlog
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH"
$gtm_tst/com/primary_crash.csh

# PRIMARY SIDE (A) UP
$gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip
setenv start_time `date +%H_%M_%S`
echo "mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
echo "Restarting Primary (A)..."
$gtm_tst/com/SRC.csh "." $portno $start_time >& START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_RESTART"
# wait to restart gtm until after the rollback to avoid excess transactions
# no extra transactions here since the rollback does not do a fetchresync

# SECONDARY SIDE (B) UP
$sec_shell "cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo mupip_rollback.csh -losttrans=lost2.glo >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >>&! rollback2.log;$grep "successful" rollback2.log'
echo "Restart gtm..."
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "Restarting Secondary (B)..."
# Note that even though A ran more transactions after B was crashed (before crashing A), it is possible B gets rolled back
# to a higher seqno than A in rare situations (because the journal files on A were not flushed to disk as fast as those on B).
# And since we do not use -fetchresync to start the receiver, it is possible we get a REPL_ROLLBACK_FIRST error in the
# receiver server startup in case the receiver side is ahead of the source side in terms of seqno. Therefore use -autorollback
# in the receiver server startup so an automatic rollback is done in case the receiver is ahead of the source.
$sec_shell "$sec_getenv; cd $SEC_SIDE; setenv gtm_test_autorollback TRUE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
# Since it is possible in rare cases that the receiver server does an online rollback at startup (see prior comment for details)
# we need to wait for that to be done before proceeding with the "rfstatus.csh" call as otherwise we would see "%YDB-W-DBFLCORRP"
# messages in the "dse_df.log" file on the receiver side (which would cause the test framework to signal a test failure).
# Hence we wait for the history record to be seen in the update process log. That is a sure shot indication that the receiver
# server is done any needed online rollback at startup.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
echo "Now GTM process will end."
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
