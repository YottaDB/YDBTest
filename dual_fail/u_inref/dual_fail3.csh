#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : DUAL SITE FAILURE : CASE 3
#
#	Case 3
#
#-----------------------------------------------|---------------------------------------
#                	 A 			|     	       B
#-----------------------------------------------|---------------------------------------
#    P (d - 100, R = 95)			|      	S (d - 95, R = 95)
#     	X					|	P (96 - 150, R = 95)
#     	X					|	    X
#     	X					|	P (151 - 200, R = 95)
#     S (B = min(95, 95) = 95, LT = 96 - 100)	|	P (201 - d, R = 95)
#-----------------------------------------------|---------------------------------------
#
#
$gtm_tst/com/dbcreate.csh mumps 9 $rand_args 2000 4096 2000

setenv portno `$sec_shell "$sec_getenv; cat $SEC_DIR/portno"`
setenv start_time `cat start_time`
echo "GTM Process starts..."
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "" noerror

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_PRI_A_CRASH:"
$gtm_tst/com/primary_crash.csh


# QUICK FAIL OVER #
# For a Quick Fail Over we need to shut down the secondary
# Before that wait for the backlog to clear. Else we can get time out errors in shutting down of passive server
# do dse buffer_flush before invoking shutdown, to avoid this failure
echo "Shutdown RCVR on (B) ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" ""''"" "buffer_flush"< /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
echo "DO QUICK FAIL OVER..."
$DO_FAIL_OVER


# NEW PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP1:"" < /dev/null"
# restart gtm
echo "Multi-process Multi-region GTM starts on primary (B)..."
$pri_shell "$pri_getenv; setenv gtm_test_jobid 1; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count SRC $test_sleep_sec "'""'" noerror"


# NEW PRIMARY SIDE (B) CRASH
$pri_shell "$pri_getenv; $gtm_tst/com/primary_crash.csh"

# RESTART PRIMARY SIDE (B)
if ($?test_debug) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl*' cp nozip"
endif
setenv start_time `date +%H_%M_%S`
echo "Doing rollback on (B):"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'echo mupip_rollback.csh -losttrans=lost1.glo >>&! rollback1.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback1.log;$grep "successful" rollback1.log'
echo "Restarting Primary (B) ..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh "AFTER_PRI_B_UP2:" < /dev/null"



# RESTART SECONDARY (A)
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl*' cp nozip
endif
echo "Doing Rollback on side A"
echo "mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo >>&! rollback2.log" >>&! rollback2.log
$gtm_tst/com/mupip_rollback.csh -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log
$grep "successful" rollback2.log
$gtm_tst/com/RCVR.csh "." $portno $start_time >&!  START_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; setenv gtm_test_jobid 2; cd $PRI_SIDE; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh +$test_tn_count_short SRC $test_sleep_sec_short "'""'" noerror"

echo "Now GTM process ends"
$pri_shell "$pri_getenv; setenv gtm_test_jobid 2; cd $PRI_SIDE; $gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
