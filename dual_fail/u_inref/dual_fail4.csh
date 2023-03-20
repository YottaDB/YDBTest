#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : DUAL SITE FAILURE : CASE 4
#
#	Case 4
#
# 		A		|     	       B
#-------------------------------|---------------------------------------
#     P (d - 100, R = 95)	|      	S (d - 95, R = 95)
#     	X			|	P (96 - 150, R = 95)
#     	X			|	    X
#     P (101 - 200, R = 95)	|	    X
#     P (201 - d, R = 95)	|	S (B = min(95, 95) = 95, LT = 96 - 150)
#-------------------------------|---------------------------------------
#
#
$gtm_tst/com/dbcreate.csh mumps 9 $rand_args 2000 4096 2000

setenv portno `$sec_shell "$sec_getenv; cat $SEC_DIR/portno"`
setenv start_time `cat start_time`

# GTM Process starts in background
echo "Multi-process Multi-region GTM starts on primary (A)..."
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_PRI_A_CRASH:"
$gtm_tst/com/primary_crash.csh


# QUICK FAIL OVER #
# The source server sometimes takes longer than 3 1/2 minutes to shutdown and causes the test to fail.
# do dse buffer_flush before invoking shutdown, to avoid this failure
echo "Shut down Receiver (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" ""''"" "buffer_flush"< /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
echo "DO QUICK FAIL OVER..."
$DO_FAIL_OVER


# NEW PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP:"" < /dev/null"
# restart gtm
echo "Multi-process Multi-region GTM starts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out; if ($status) exit 1
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "'""'" noerror"


# NEW PRIMARY SIDE (B) CRASH
$pri_shell "$pri_getenv; $gtm_tst/com/primary_crash.csh"
sleep 5

# ANOTHER SWITCH OVER # (A) is primary. (B) is receiver
echo "ANOTHER SWITCH OVER # (A) is primary. (B) is receiver:"
$DO_FAIL_OVER
cd $PRI_SIDE;
$gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip
setenv start_time `date +%H_%M_%S`
echo "Rollback on primary (A):"
echo "mupip_rollback.csh -losttrans=lost1.glo " >>&! rollback1.log
$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log
$grep "successful" rollback1.log


# PRIMARY SIDE (A) UP
echo "Restarting (A) as primary..."
$gtm_tst/com/SRC.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/srcstat.csh "AFTER_PRI_A_UP"
# restart gtm
setenv gtm_test_jobid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror
# stop gtm while the rollback is running to prevent excess transaction generation
$gtm_tst/com/endtp.csh >>& endtp.out


# SECONDARY SIDE (B) UP (was primary)
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
echo "Rollback on secondary (B):"
$sec_shell "echo portno=$portno"">>&!"" $SEC_DIR/env.txt"
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'echo mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo >>&! rollback2.log'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log;$grep "successful" rollback2.log'
# restart gtm
setenv gtm_test_jobid 3
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror
echo "Restarting (B) as secondary..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "" noerror

echo "Now GTM process ends"
cd $PRI_SIDE
$gtm_tst/com/endtp.csh >>& endtp.out
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
