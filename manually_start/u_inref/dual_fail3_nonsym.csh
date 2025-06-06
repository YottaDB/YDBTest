#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
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
source $gtm_tst/$tst/u_inref/setenvdualfail.csh
# For this test buffer size is 1 MB and always keep log files
setenv tst_buffsize 1048576
$gtm_tst/com/dbcreate_base.csh mumps 9 125 1000
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcreate_base.csh mumps 3 125 1000"
$gtm_tst/com/RF_START.csh
#
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "GTM Process starts..."
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep $test_sleep_sec

# PRIMARY SIDE (A) CRASH
$gtm_tst/com/rfstatus.csh "BEFORE_PRI_A_CRASH:"
$gtm_tst/com/primary_crash.csh "NO_IPCRM"

# QUICK FAIL OVER #
echo "Shutdown RCVR on (B) ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
echo "DO QUICK FAIL OVER..."
$DO_FAIL_OVER


# NEW PRIMARY SIDE (B) UP
echo "Restarting (B) as primary..."
setenv start_time `date +%H_%M_%S`
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh ""AFTER_PRI_B_UP1:"" < /dev/null"
# restart gtm
echo "Multi-process Multi-region GTM starts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; setenv gtm_test_jobid 1; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
sleep $test_sleep_sec


# NEW PRIMARY SIDE (B) CRASH
$pri_shell "$pri_getenv; $gtm_tst/com/primary_crash.csh ""NO_IPCRM"""
sleep 5

# RESTART PRIMARY SIDE (B)
if ($?test_debug) then
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/backup_dbjnl.csh bak1 '*.dat *.mjl* *.gld *.repl' cp nozip"
endif
setenv start_time `date +%H_%M_%S`
echo "Doing rollback on (B):"
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'echo $MUPIP journal -rollback -backward -losttrans=lost1.glo >>&! rollback1.log'
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP journal -rollback -backward -losttrans=lost1.glo "*" >>&! rollback1.log; $grep -w "successful" rollback1.log'
echo "Restarting Primary (B) ..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh "." $portno $start_time < /dev/null "">>&!"" START_${start_time}.out"
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh "AFTER_PRI_B_UP2:" < /dev/null"



# RESTART SECONDARY (A)
if ($?test_debug) then
	$gtm_tst/com/backup_dbjnl.csh bak2 '*.dat *.mjl* *.gld *.repl' cp nozip
endif
echo "Doing Rollback on side A"
echo "$MUPIP journal -rollback -backward -fetchresync=$portno -losttrans=fetch.glo *" >>&! rollback2.log
$MUPIP journal -rollback -backward -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback2.log
$grep -w "successful" rollback2.log
$gtm_tst/com/RCVR.csh "." $portno $start_time >&!  START_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"

echo "Multi-process Multi-region GTM restarts on primary (B)..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; setenv gtm_test_jobid 2; $gtm_tst/com/imptp.csh < /dev/null "">>&!"" imptp.out"
$pri_shell "$pri_getenv; source $gtm_tst/com/imptp_check_error.csh $PRI_SIDE/imptp.out"; if ($status) exit 1
sleep $test_sleep_sec

echo "Now GTM process ends"
$pri_shell "$pri_getenv; cd $PRI_SIDE; setenv gtm_test_jobid 2;$gtm_tst/com/endtp.csh < /dev/null "">>&!"" endtp.out"
$gtm_tst/com/dbcheck_filter.csh -extract
cd $PRI_DIR
$gtm_tst/com/checkdb.csh
