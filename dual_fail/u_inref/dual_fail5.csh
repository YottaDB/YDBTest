#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : DUAL SITE FAILURE : CASE 5
#
#	Case 5 - Extension of case 4a
#
#	                 A 	|     	       B
#-------------------------------|---------------------------------------
# 1.     P (d - 100, R = 95)	|      	S (d - 95, R = 95)
# 2.	     	X		|	P (96 - 150, R = 95)
# 3.	     	X		|	    X
# 4.     P (86 - 200, R = 86)	|	    X
# 5.		X		|	    X
# 6.     P (185 - 300, R = 86)	|	    X
# 7.     P (301 - d, R = 86)	|	S (B = min(86, 95) = 86, LT = 86 - 150)
#-------------------------------|---------------------------------------
#

echo "=== STEP 1 ==="
$gtm_tst/com/dbcreate.csh mumps 9 $rand_args 2000 4096 2000

setenv portno `$sec_shell "$sec_getenv; cat $SEC_DIR/portno"`
setenv start_time `cat start_time`
# GTM Process starts in background
echo "Multi-process Multi-region GTM starts on primary (A)..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >&! imptp.out
#$gtm_tst/com/primary_crash.csh
#
# It is desirable to have at least 1500 transactions on the primary
$gtm_tst/com/wait_for_transaction_seqno.csh 1500 SRC 300
if (0 != "$status") then
	echo "TEST-E-TRANSACTIONS processed by the primary did not reach the expected number (1500)"
	echo "Since the rest of the test relies on this, no point in continuing it. Will exit now."
	$gtm_tst/com/endtp.csh >>& endtp.out
	$gtm_tst/com/dbcheck.csh
	exit 1
endif
# Make sure we still have the 1500 transactions after the consist rollback, below.
$gtm_exe/mumps -run %XCMD 'view "FLUSH"'	# this avoids <dual_fail5_negative_resync> types of failures
# It is desirable to have at least 1500 transactions sent to secondary
set stat = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh 1500 RCVR 300 && echo wait_ok"`
if ("wait_ok" != "$stat") then
	echo "TEST-E-TRANSACTIONS processed by the secondary did not reach the expected number (1500)"
	echo "Since the rest of the test relies on this, no point in continuing it. Will exit now."
	$gtm_tst/com/endtp.csh >>& endtp.out
	$gtm_tst/com/dbcheck.csh
	exit 1
endif
# Wait for the resync seqno to get to 1500. This is required because the below calculations of tst_seqno* picks up the values
# from the replication instance file.
$gtm_tst/com/wait_for_src_slot.csh -file -instance INSTANCE2 -maxwait 600 -searchstring "Resync Sequence Number" -gt 1500
#
# PRIMARY SIDE (A) CRASH (1st crash on A)
$gtm_tst/com/rfstatus.csh "BEFORE_PRI_A_CRASH:"
$gtm_tst/com/primary_crash.csh
$gtm_tst/com/backup_dbjnl.csh bak1
$gtm_tst/com/cur_jnlseqno.csh  "RESYNC" >& pre_rollback_syncno.txt
echo "mupip_rollback.csh *"
echo "mupip_rollback.csh *" >>& consist_rollback.log
$gtm_tst/com/mupip_rollback.csh "*" >>& consist_rollback.log
$grep "successful" consist_rollback.log
echo "Save current sequence numbers to be used later:"
set tst_seqno = `$gtm_tst/com/cur_jnlseqno.csh  "RESYNC" 0`
@ tst_seqno1 = $tst_seqno - 512		# 86
@ tst_seqno2 = $tst_seqno + 256		# 185
@ tst_seqtarget = $tst_seqno1
echo "tst_seqno1=$tst_seqno1  tst_seqno2=$tst_seqno2" >>&! seqnum.txt
if ($tst_seqno1 < 0) then
	echo "TEST-E-negativeseqno, cannot proceed with negative resync sequence number ($tst_seqno1), see <dual_fail5_negative_resync>"
	echo "TEST-E-lowjnlseq, need journal seqno at least 512 after consist_rollback"
	$grep RLBKJNSEQ consist_rollback.log
	set lost_file=`sed -n 's;.*Lost transactions extract file \([^ ]*\) created$;\1;p' consist_rollback.log`
	if ("" != "$lost_file") then
		echo "From ${lost_file}:"
		$head -n 4 $lost_file
		$tail -n 4 $lost_file
	endif
	exit 1
endif
#
# QUICK FAIL OVER #
# For a Quick Fail Over we need to shut down the secondary
# Before that wait for the backlog to clear. As one of the main assumptions in this
# test case is that in the first step the current receiver would have hardened more transactions
# than the seq num to which the primary has rolled back above. So wait for the backlog to clear
# to fulfill this condition.  Else the last test S (B = min(95, 86) = 86) could not be done.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_backlog_clear.csh"

echo "Shut down Receiver (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
# Test the assumption mentioned above. If it is not satisfied then switch the min value.
set sec_seqno = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/last_processed_tr.csh $start_time"`
# tst_seqno1 and tst_nseqno (below) are both resync seqnos, which refer to the next seqno,
# whereas sec_seqno refers to a current seqno, so add one to sec_seqno to get it to match.
@ sec_resync = $sec_seqno + 1
if ($sec_resync < $tst_seqno1) @ tst_seqtarget = $sec_resync
echo "DO QUICK FAIL OVER..."
$DO_FAIL_OVER
#
echo "=== STEP 2 ==="
#
# NEW PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/get_dse_df.csh ""CUR_JNLSEQNO:"" < /dev/null"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP:"" < /dev/null"
#
# restart gtm
echo "Multi-process Multi-region GTM starts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "'""'" noerror"
#
# NEW PRIMARY SIDE (B) CRASH  (1st crash of B)
$pri_shell "$pri_getenv; $gtm_tst/com/primary_crash.csh"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2"
#
echo "=== STEP 3 ==="
#
# ANOTHER SWITCH OVER # (A) is primary. (B) is receiver
echo "ANOTHER SWITCH OVER # (A) is primary. (B) is receiver:"
$DO_FAIL_OVER
#
echo "=== STEP 4 ==="
# ROLLBACK ON PRIMARY SIDE (A)
cd $PRI_SIDE
setenv start_time `date +%H_%M_%S`
echo "Rollback on primary (A):"
echo "mupip_rollback.csh -resync=$tst_seqno1 -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -resync=$tst_seqno1 -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
#
# PRIMARY SIDE (A) UP
echo "Restarting (A) as primary..."
$gtm_tst/com/SRC.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_UP"
# restart gtm
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
echo "=== STEP 5 ==="
# PRIMARY SIDE (A) CRASH AGAIN
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH2:"
$gtm_tst/com/primary_crash.csh
if ($?test_debug == 1) then
        $gtm_tst/com/backup_dbjnl.csh bak3
endif
#
echo "=== STEP 6 ==="
# PRIMARY SIDE (A) UP AGAIN
setenv start_time `date +%H_%M_%S`
echo "Rollback on primary (A):"
echo "mupip_rollback.csh -resync=$tst_seqno2 -losttrans=lost2.glo " >>&! rollback2.log
$gtm_tst/com/mupip_rollback.csh -resync=$tst_seqno2 -losttrans=lost2.glo "*" >>&! rollback2.log
$grep "successful" rollback2.log
#
# PRIMARY SIDE (A) UP
echo "Restarting (A) as primary..."
$gtm_tst/com/SRC.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_RESTART2"
# restart gtm
setenv gtm_test_jobid 3
$gtm_tst/com/imptp.csh >>&! imptp.out
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
# stop gtm while the rollback is running to prevent excess transaction generation
$gtm_tst/com/endtp.csh >>& endtp.out
#
echo "=== STEP 7 ==="
# SECONDARY SIDE (B) UP (was primary)
echo "Rollback with fetchresync on secondary (B):"
$sec_shell "echo portno=$portno"">>&!"" $SEC_DIR/env.txt"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo >>&! rollback3.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback3.log;$grep "successful" rollback3.log'
#
set tst_nseqno = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/get_fetch_resync.csh rollback3.log < /dev/null"`
if ($tst_seqtarget == $tst_nseqno) then
        echo "PASSED rollback -fetchresync"
else
        echo "FAILED from rollback: tst_seqno1=$tst_seqno1 tst_seqtarget=$tst_seqtarget tst_nseqno=$tst_nseqno"
	$gtm_tst/com/endtp.csh
	$gtm_tst/com/SRC_SHUT.csh "on"
	echo "Test was forced to stop!"
	exit 1
endif
#
# restart gtm
setenv gtm_test_jobid 4
$gtm_tst/com/imptp.csh >>&! imptp.out
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
echo "Restarting (B) as secondary..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
echo "Now GTM process ends"
cd $PRI_SIDE
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
