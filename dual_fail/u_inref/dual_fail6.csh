#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : DUAL SITE FAILURE : CASE 6
#
# Case 6 - Extension of case 5
#
#	                 A 				|     	       B
#-------------------------------------------------------|---------------------------------------
#     P (d - 100, R = 95)				|      	S (d - 95, R = 95)
#	     	X					|	P (96 - 150, R = 95)
#	     	X					|	    X
#     P (86 - 200, R = 86)				|	    X
#		X					|	    X
#     P (185 - 300, R = 86)				|	    X
#		X					|	    X
#		X					|	P (140 - 200, R = 95)
#     S (B = min(95, 86) = 86, LT = 86 - 300)	 	|	P (201 - d, R = 95)
#-------------------------------------------------------|---------------------------------------
#


$gtm_tst/com/dbcreate.csh mumps 9 $rand_args 2000 4096 2000

setenv portno `$sec_shell "$sec_getenv; cat $SEC_DIR/portno"`
setenv start_time `cat start_time`

# GTM Process starts in background
echo "Multi-process Multi-region GTM starts on primary (A)..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
#
# It is desirable to have at least 1500 transactions sent to secondary
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh 1500 RCVR 300"
#
# Wait for the journal seqno related entires to be hardned in the primary side. This is required because,
# the below calculations of tst_seqno* picks up the values from the replication instance file.
$gtm_tst/com/wait_for_src_slot.csh -file -intance INSTANCE2 -searchstring "Resync Sequence Number" -gt 1500
# Now that the instance file has been hardened, make sure the 1500 transactions are hardened in the journal files too
# that way a consistent rollback will restore the instance to a seqno of at lesat 1500.
$gtm_exe/mumps -run %XCMD 'view "FLUSH"'	# this avoids <dual_fail5_negative_resync> types of failures
#
# PRIMARY SIDE (A) CRASH (1st crash on A)
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH1:"
$gtm_tst/com/primary_crash.csh
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip
endif
echo "mupip_rollback.csh *"
echo "mupip_rollback.csh *" >>& consist_rollback.log
$gtm_tst/com/mupip_rollback.csh "*" >>& consist_rollback.log
$grep "successful" consist_rollback.log
echo "Save current sequence numbers to be used later:"
set tst_seqno = `$gtm_tst/com/cur_jnlseqno.csh  "RESYNC" 0`
@ tst_seqno1 = $tst_seqno - 512		# 86
@ tst_seqno2 = $tst_seqno + 512		# 185
@ tst_seqno3 = $tst_seqno + 256		# 140
@ tst_seqtarget = $tst_seqno1
echo "tst_seqno1=$tst_seqno1  tst_seqno2=$tst_seqno2 tst_seqno3=$tst_seqno3" >>&! seqnum.txt
#
# QUICK FAIL OVER #
# For a Quick Fail Over we need to shut down the secondary
# Before that wait for the backlog to clear. As one of the main assumptions in this
# test case is that in the first step the current receiver would have hardened more transactions
# than the seq num to which the primary has rolled back above. So wait for the backlog to clear
# to fulfill this condition.  Else the last test S (B = min(95, 86) = 86) could not be done.

$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_until_rcvr_backlog_clear.csh"

# The source server sometimes takes longer than 3 1/2 minutes to shutdown and causes the test to fail.
# do dse buffer_flush before invoking shutdown, to avoid this failure
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" ""''"" "buffer_flush" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
# Test the assumption mentioned above. If it is not satisfied then switch the min value.
set sec_seqno = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/last_processed_tr.csh $start_time"`
# tst_seqno1 and tst_nseqno (below) are both resync seqnos, which refer to the next seqno,
# whereas sec_seqno refers to a current seqno, so add one to sec_seqno to get it to match.
@ sec_resync = $sec_seqno + 1
if ($sec_resync < $tst_seqno1) @ tst_seqtarget = $sec_resync
echo "DO QUICK FAIL OVER..."
$DO_FAIL_OVER
#
# NEW PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/get_dse_df.csh ""CUR_JNLSEQNO:"" < /dev/null"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP1:"" < /dev/null"
#
# restart gtm
echo "Multi-process Multi-region GTM starts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "'""'" noerror"

# NEW PRIMARY SIDE (B) CRASH  (1st crash of B)
$pri_shell "$pri_getenv; $gtm_tst/com/primary_crash.csh"
if ($?test_debug) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
endif
#
echo "ANOTHER SWITCH OVER # (A) is primary. (B) is receiver:"
$DO_FAIL_OVER
#
# ROLLBACK ON (A) : 1st rollback
setenv start_time `date +%H_%M_%S`
echo "Rollback on primary (A):"
echo "mupip_rollback.csh -resync=$tst_seqno1 -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -resync=$tst_seqno1 -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log
#
# PRIMARY SIDE (A) UP
echo "Restarting (A) as primary..."
$gtm_tst/com/SRC.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_UP1"
# restart gtm
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
# PRIMARY SIDE (A) CRASH AGAIN (2nd crash)
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH2:"
$gtm_tst/com/primary_crash.csh
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak3 '*.dat *.mjl*' cp nozip
endif
#
# ROLLBACK ON (A) : 2nd rollback
setenv start_time `date +%H_%M_%S`
echo "Rollback on primary (A):"
echo "mupip_rollback.csh -resync=$tst_seqno2 -losttrans=lost2.glo " >>&! rollback2.log
$gtm_tst/com/mupip_rollback.csh -resync=$tst_seqno2 -losttrans=lost2.glo "*" >>&! rollback2.log
$grep "successful" rollback2.log
#
# PRIMARY SIDE (A) UP AGAIN (2nd restart)
echo "Restarting (A) as primary..."
$gtm_tst/com/SRC.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_UP2"
# restart gtm
setenv gtm_test_jobid 3
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
# PRIMARY SIDE (A) CRASH: 3rd crash of (A)
$gtm_tst/com/srcstat.csh "BEFORE_PRI_A_CRASH3:"
$gtm_tst/com/primary_crash.csh
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak4 '*.dat *.mjl*' cp nozip
endif
#
# FAIL OVER (B) is primary and (A) is secondary #
$DO_FAIL_OVER
#
#DO ROLLBACK ON PRIMARY (B)
setenv start_time `date +%H_%M_%S`
echo "Doing rollback on (B):"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'echo mupip_rollback.csh -resync='$tst_seqno3' -losttrans=lost3.glo >>&! rollback3.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$gtm_tst/com/mupip_rollback.csh -resync='$tst_seqno3' -losttrans=lost3.glo "*" >>&! rollback3.log;$grep "successful" rollback3.log'
#
# PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh "AFTER_PRI_B_UP2:" < /dev/null"
echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "'""'" noerror"
#
# stop gtm while the rollback is running to prevent excess transaction generation
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
#
# SECONDARY SIDE (A) UP
echo "mupip_rollback.csh -fetchresync=$portno -losttrans=$SEC_SIDE/fetch.glo"  >>&! rollback4.log
$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=$SEC_SIDE/fetch.glo "*" >>&! rollback4.log
$grep "successful" rollback4.log
#
set tst_nseqno = `$gtm_tst/com/get_fetch_resync.csh rollback4.log`
if ($tst_seqtarget == $tst_nseqno) then
	echo "PASSED rollback -fetchresync"
else
	echo "FAILED from rollback: tst_seqno1=$tst_seqno1 tst_seqtarget=$tst_seqtarget tst_nseqno=$tst_nseqno"
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC_SHUT.csh ""on"""
	echo "Test was forced to stop!"
	exit 1
endif
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
#
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "'""'" noerror"
#
echo "Restarting (B) as secondary..."
$gtm_tst/com/RCVR.csh "." $portno $start_time >>&! START_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
#
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
#
echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
$gtm_tst/com/checkdb.csh
